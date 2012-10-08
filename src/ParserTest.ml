open LibUtil;
open FanUtil;
open Lib;

module IdDebugParser = struct
  let name = "Camlp4DebugParser";
  let version = Sys.ocaml_version;
end;

module MakeDebugParser (Syntax : Sig.Camlp4Syntax) = struct
  include Syntax;
  open FanSig ; (* For FanToken, probably we should fix FanToken as well  *)
  module Ast = Camlp4Ast;  
  let debug_mode =
    try
      let str = Sys.getenv "STATIC_CAMLP4_DEBUG" in
      let rec loop acc i =
        try
          let pos = String.index_from str i ':' in
          loop (SSet.add (String.sub str i (pos - i)) acc) (pos + 1)
        with
        [ Not_found ->
            SSet.add (String.sub str i (String.length str - i)) acc ] in
      let sections = loop SSet.empty 0 in
      if SSet.mem "*" sections then fun _ -> True
      else fun x -> SSet.mem x sections
    with [ Not_found -> fun _ -> False ];

  let mk_debug_mode _loc = fun [ None -> <:expr< Debug.mode >>
                                 | Some m -> <:expr< $uid:m.Debug.mode >> ];

  let mk_debug _loc m fmt section args =
    let call = Expr.apply <:expr< Debug.printf $str:section $str:fmt >> args in
      <:expr< if $(mk_debug_mode _loc m) $str:section then $call else () >>;


  EXTEND Gram
    GLOBAL: expr;
    expr:
    [ [ start_debug{m};  `LIDENT section;  `STRING (fmt,_) ;
        LIST0 expr Level "."{args};  end_or_in{x} ->
      match (x, debug_mode section) with
      [ (None,   False) -> <:expr< () >>
      | (Some e, False) -> e
      | (None, _) -> mk_debug _loc m fmt section args
      | (Some e, _) -> <:expr< let () = $(mk_debug _loc m fmt section args) in $e >> ]
    ] ]
    end_or_in:
    [ [ "end" -> None
      | "in"; expr{e} -> Some e
    ] ]
    start_debug:
    [ [ `LIDENT "debug" -> None
      | `LIDENT "camlp4_debug" -> Some "Camlp4"
    ] ]
  END;

end;

module IdGrammarParser = struct
  let name = "Camlp4GrammarParser";
  let version = Sys.ocaml_version;
end;

let string_of_patt patt =
  let buf = Buffer.create 42 in
  let () =
    Format.bprintf buf "%a@?"
      (fun fmt p -> Pprintast.pattern fmt (Ast2pt.patt p)) patt in
  (* let () = Format.bprintf buf "%a@?" pp#patt patt in *)
  let str = Buffer.contents buf in
  if str = "" then assert False else str;
  
module MakeGrammarParser (Syntax : Sig.Camlp4Syntax) = struct
  include Syntax;
  module Ast = Camlp4Ast;
  open FanSig;
  module MetaAst = Ast.Meta.Make Lib.Meta.MetaGhostLoc ;
  let split_ext = ref False;
  type loc = FanLoc.t;
  type name 'e = { expr : 'e; tvar : string; loc : loc };
  type styp =
    [ STlid of loc and string
    | STapp of loc and styp and styp
    | STquo of loc and string
    | STself of loc and string
    | STtok of loc
    | STstring_tok of loc
    | STtyp of Ast.ctyp ] ;

  type text 'e 'p =
    [ TXmeta of loc and string and list (text 'e 'p) and 'e and styp
    | TXlist of loc and bool and symbol 'e 'p and option (symbol 'e 'p)
    | TXnext of loc
    | TXnterm of loc and name 'e and option string
    | TXopt of loc and text 'e 'p
    | TXtry of loc and text 'e 'p
    | TXrules of loc and list (list (text 'e 'p) * 'e)
    | TXself of loc
    | TXkwd of loc and string
    | TXtok of loc and 'e and string
         (** The first is the match function expr,
             the second is the string description.
             The description string will be used for
             grammar insertion and left factoring.
             Keep this string normalized and well comparable. *) ]
  and entry 'e 'p =
    { name : name 'e; pos : option 'e; levels : list (level 'e 'p) }
  and level 'e 'p =
    { label : option string; assoc : option 'e; rules : list (rule 'e 'p) }
  and rule 'e 'p = { prod : list (symbol 'e 'p); action : option 'e }
  and symbol 'e 'p = { used : list string; text : text 'e 'p;
                       styp : styp; pattern : option 'p } ;

  type used = [ Unused | UsedScanned | UsedNotScanned ];

  let _loc = FanLoc.ghost;
  (* let gm = "Camlp4Grammar__"; *)
  (* let grammar_module_name = ref <:ident< Gram >>; *)
  let grammar_module_name = ref <:ident< $(uid:"")>> ;
  let gm () = !grammar_module_name;
    
  let mark_used modif ht n =
    try
      let rll = Hashtbl.find_all ht n in
      List.iter
        (fun [ (({contents=Unused} as r), _)   ->  begin 
            r := UsedNotScanned; modif := True;
          end
          |  _ -> () ])
        rll
    with
    [ Not_found -> () ] ;

  let  mark_symbol modif ht symb =
    List.iter (fun e -> mark_used modif ht e) symb.used ;

  let check_use nl el =
    let ht = Hashtbl.create 301 in
    let modif = ref False in
    do {
      List.iter
        (fun e ->
          let u =
            match e.name.expr with
            [ <:expr< $lid:_ >> -> Unused
            | _ -> UsedNotScanned ]
          in
          Hashtbl.add ht e.name.tvar (ref u, e))
        el;
      List.iter
        (fun n ->
          try
            let rll = Hashtbl.find_all ht n.tvar in
            List.iter (fun (r, _) -> r := UsedNotScanned) rll
          with _ ->
            ())
        nl;
      modif := True;
      while !modif do {
        modif := False;
        Hashtbl.iter
          (fun _ (r, e) ->
            if !r = UsedNotScanned then do {
              r := UsedScanned;
              List.iter
                (fun level ->
                    let rules = level.rules in
                    List.iter
                      (fun rule ->
                        List.iter (fun s -> mark_symbol modif ht s)
                          rule.prod)
                      rules)
                e.levels
            }
            else ())
          ht
      };
      Hashtbl.iter
        (fun s (r, e) ->
          if !r = Unused then
            print_warning e.name.loc ("Unused local entry \"" ^ s ^ "\"")
          else ())
        ht;
    }
  ;

  let new_type_var =
    let i = ref 0 in fun () -> do { incr i; "e__" ^ string_of_int !i } ;

  let used_of_rule_list rl =
    List.fold_left
      (fun nl r -> List.fold_left (fun nl s -> s.used @ nl) nl r.prod) [] rl ;

  let retype_rule_list_without_patterns _loc rl =
    try
      List.map
        (fun
          (* ...; [ "foo" ]; ... ==> ...; (x = [ "foo" ] -> Gram.Token.extract_string x); ... *)
        [ {prod = [({pattern = None; styp = STtok _ ;_} as s)]; action = None} ->
            {prod = [{ (s) with pattern = Some <:patt< x >> }];
              action = Some <:expr< $(id:gm()).string_of_token x >>}
          (* ...; [ symb ]; ... ==> ...; (x = [ symb ] -> x); ... *)
        | {prod = [({pattern = None; _ } as s)]; action = None} ->
            {prod = [{ (s) with pattern = Some <:patt< x >> }];
              action = Some <:expr< x >>}
          (* ...; ([] -> a); ... *)
        | {prod = []; action = Some _} as r -> r
        | _ -> raise Exit ])
        rl
    with
    [ Exit -> rl ];

  let meta_action = ref False;

  let  make_ctyp  styp tvar =
    let rec aux  = fun  
    [ STlid _loc s -> <:ctyp< $lid:s >>
    | STapp _loc t1 t2 -> <:ctyp< $(aux t1) $(aux t2 ) >>
    | STquo _loc s -> <:ctyp< '$s >>
    | STself _loc x ->
        if tvar = "" then
          FanLoc.raise _loc
            (Stream.Error ("'" ^ x ^  "' illegal in anonymous entry level"))
        else <:ctyp< '$tvar >>
    | STtok _loc -> <:ctyp< $(id:gm()).token >> (*FIXME*)
    | STstring_tok _loc -> <:ctyp< string >>
    | STtyp t -> t ] in aux styp ;

  (*
    {[
    styp generates type constraints which are used to constrain patt
    ]}
   *)    
  let make_ctyp_patt styp tvar patt =
    let styp = match styp with [ STstring_tok _loc -> STtok _loc | t -> t ] in
    match make_ctyp styp tvar with
    [ <:ctyp< _ >> -> patt (* FIXME *)
    | t -> let _loc = Ast.loc_of_patt patt in <:patt< ($patt : $t) >> ];

  let make_ctyp_expr styp tvar expr =
    match make_ctyp styp tvar with
    [ <:ctyp< _ >> -> expr
    | t -> let _loc = Ast.loc_of_expr expr in <:expr< ($expr : $t) >> ];

  (*
    {[
    ('j, Ast.patt) symbol list
    ]}
   *)    
  let text_of_action _loc  (psl) (rtvar:string) (act:option Ast.expr) (tvar:string) =
    let locid = <:patt< $(lid: !FanLoc.name) >> in (* default is [_loc]*)
    let act = match act with
      [ Some act -> act
      | None -> <:expr< () >> ] in
    let (tok_match_pl, act, _) =
      List.fold_left
        (fun ((tok_match_pl, act, i) as accu) ->
          fun
          [ { pattern = None; _ } -> accu
          | { pattern = Some p ; _} when Ast.is_irrefut_patt p -> accu
          | { pattern = Some <:patt< ($_ $(tup:<:patt< _ >>) as $lid:s) >> ; _} ->
              (tok_match_pl,
               <:expr< let $lid:s = $(id:gm()).string_of_token $lid:s
                       in $act >>, i)
          | { pattern = Some p; text=TXtok _ _ _ ; _ } ->
              let id = "__camlp4_"^string_of_int i in
              (Some (match (tok_match_pl) with
                     [ None -> (<:expr< $lid:id >>, p)
                     | Some (tok_pl, match_pl) ->
                        (<:expr< $lid:id, $tok_pl >>, <:patt< $p, $match_pl >>)]),
               act, succ i)
          | _ -> accu ])
        (None, act, 0) psl  in
    let e =
      let e1 = <:expr< ($act : '$rtvar) >> in
      let e2 =
        match (tok_match_pl) with
        [ None -> e1
        | Some (<:expr< $t1, $t2 >>, <:patt< $p1, $p2 >>) ->
          <:expr< match ($t1, $t2) with
                  [ ($p1, $p2) -> $e1
                  | _ -> assert False ] >>
        | Some (tok, match_) ->
          <:expr< match $tok with
                  [ $pat:match_ -> $e1
                  | _ -> assert False ] >> ] in
      <:expr< fun ($locid : FanLoc.t) -> $e2 >> in (*FIXME hard coded Loc*)
    let (txt, _) =
      List.fold_left
        (fun (txt, i) s ->
          match s.pattern with
          [ None | Some <:patt< _ >> -> (<:expr< fun _ -> $txt >>, i)
          | Some <:patt< ($_ $(tup:<:patt< _ >>) as $p) >> ->
              let p = make_ctyp_patt s.styp tvar p in
              (<:expr< fun $p -> $txt >>, i)
          | Some p when Ast.is_irrefut_patt p ->
              let p = make_ctyp_patt s.styp tvar p in
              (<:expr< fun $p -> $txt >>, i)
          | Some _ ->
              let p = make_ctyp_patt s.styp tvar
                        <:patt< $(lid:"__camlp4_"^string_of_int i) >> in
              (<:expr< fun $p -> $txt >>, succ i) ])
        (e, 0) psl in
    let txt =
      if !meta_action then
        <:expr< Obj.magic $(MetaAst.Expr.meta_expr _loc txt) >>
      else txt  in
    <:expr< $(id:gm()).mk_action $txt >>
  ;
  let srules loc t rl tvar =
    List.map
      (fun r ->
        let sl = [ s.text | s <- r.prod ] in
        let ac = text_of_action loc r.prod t r.action tvar in
        (sl, ac))
      rl ;

  let rec make_expr entry tvar =
    fun
    [ TXmeta _loc n tl e t ->
        let el =
          List.fold_right
            (fun t el -> <:expr< [$(make_expr entry "" t) :: $el] >>)
            tl <:expr< [] >>
        in
        <:expr<
          $(id:gm()).Smeta $str:n $el ($(id:gm()).Action.mk $(make_ctyp_expr t tvar e)) >>
    | TXlist _loc min t ts ->
        let txt = make_expr entry "" t.text in
        match (min, ts) with
        [ (False, None) -> <:expr< $(id:gm()).Slist0 $txt >>
        | (True, None) -> <:expr< $(id:gm()).Slist1 $txt >>
        | (False, Some s) ->
            let x = make_expr entry tvar s.text in
            <:expr< $(id:gm()).Slist0sep $txt $x >>
        | (True, Some s) ->
            let x = make_expr entry tvar s.text in
            <:expr< $(id:gm()).Slist1sep $txt $x >> ]
    | TXnext _loc -> <:expr< $(id:gm()).Snext >>
    | TXnterm _loc n lev ->
        match lev with
        [ Some lab ->
            <:expr<
              $(id:gm()).Snterml
                ($(id:gm()).obj ($(n.expr) : $(id:gm()).t '$(n.tvar)))
                $str:lab >>
        | None ->
            if n.tvar = tvar then <:expr< $(id:gm()).Sself >>
            else
              <:expr<
                $(id:gm()).Snterm
                    ($(id:gm()).obj ($(n.expr) : $(id:gm()).t '$(n.tvar))) >> ]
    | TXopt _loc t -> <:expr< $(id:gm()).Sopt $(make_expr entry "" t) >>
    | TXtry _loc t -> <:expr< $(id:gm()).Stry $(make_expr entry "" t) >>
    | TXrules _loc rl ->
        <:expr< $(id:gm()).srules $(entry.expr) $(make_expr_rules _loc entry rl "") >>
    | TXself _loc -> <:expr< $(id:gm()).Sself >>
    | TXkwd _loc kwd -> <:expr< $(id:gm()).Skeyword $str:kwd >>
    | TXtok _loc match_fun descr -> (*
           Stoken (( function | `UIDENT _ -> true | _ -> false ), "`UIDENT (_)")
        *)
        <:expr< $(id:gm()).Stoken ($match_fun, $`str:descr) >> ]

  and make_expr_rules _loc n rl tvar =
    List.fold_left
      (fun txt (sl, ac) ->
        let sl =
          List.fold_right
            (fun t txt ->
                let x = make_expr n tvar t in
                <:expr< [$x :: $txt] >>)
            sl <:expr< [] >>
        in
        <:expr< [($sl, $ac) :: $txt ] >>)
      <:expr< [] >> rl
  ;

  let expr_of_delete_rule _loc n sl =
    let sl =
      List.fold_right
        (fun s e -> <:expr< [$(make_expr n "" s.text) :: $e ] >>) sl
        <:expr< [] >>
    in
    (<:expr< $(n.expr) >>, sl)
  ;



  let mk_name _loc i =
    {expr = <:expr< $id:i >>; tvar = Ident.tvar_of_ident i; loc = _loc};

  let slist loc min sep symb = TXlist loc min symb sep ;
  let text_of_entry  _loc e =
    let ent =
      let x = e.name in
      let _loc = e.name.loc in
      <:expr< ($(x.expr) : $(id:gm()).t '$(x.tvar)) >>   in
    let pos =
      match e.pos with
      [ Some pos -> <:expr< Some $pos >>
      | None -> <:expr< None >> ] in
    let txt =
      List.fold_right
        (fun level txt ->
          let lab =
            match level.label with
            [ Some lab -> <:expr< Some $str:lab >>
            | None -> <:expr< None >> ]  in
          let ass =
            match level.assoc with
            [ Some ass -> <:expr< Some $ass >>
            | None -> <:expr< None >> ]  in
          let txt =
            let rl = srules _loc e.name.tvar level.rules e.name.tvar in
            let e = make_expr_rules _loc e.name rl e.name.tvar in
            <:expr< [($lab, $ass, $e) :: $txt] >> in
          txt)
        e.levels <:expr< [] >> in
    (ent, pos, txt)
  ;
  (* [gl] is the name  list option *)   
  let let_in_of_extend _loc gram gl el args =
    match gl with
    [ None -> args
    | Some nl -> begin
        check_use nl el;
        let ll =
          let same_tvar e n = e.name.tvar = n.tvar in
          List.fold_right
            (fun e ll -> match e.name.expr with
              [ <:expr< $lid:_ >> ->
                    if List.exists (same_tvar e) nl then ll
                    else if List.exists (same_tvar e) ll then ll
                    else [e.name :: ll]
              | _ -> ll ])  el [] in
        let local_binding_of_name = fun
          [ {expr = <:expr< $lid:i >> ; tvar = x; loc = _loc} ->
            <:binding< $lid:i =  (grammar_entry_create $str:i : $(id:gm()).t '$x) >>
          | _ -> failwith "internal error in the Grammar extension" ]  in
        let expr_of_name {expr = e; tvar = x; loc = _loc} =
          <:expr< ($e : $(id:gm()).t '$x) >> in
        let e = match ll with
          [ [] -> args
          | [x::xs] ->
              let locals =
                List.fold_right
                  (fun name acc ->
                    <:binding< $acc and $(local_binding_of_name name) >>)
                  xs (local_binding_of_name x) in
              let entry_mk =  match gram with
              [ Some g -> <:expr< $(id:gm()).mk $id:g >>
              | None   -> <:expr< $(id:gm()).mk >> ] in <:expr<
              let grammar_entry_create = $entry_mk in
              let $locals in $args >> ] in
          match nl with
          [ [] -> e
          | [x::xs] ->
              let globals =
                List.fold_right
                  (fun name acc ->
                    <:binding< $acc and _ = $(expr_of_name name) >>)
                  xs <:binding< _ = $(expr_of_name x) >>
              in <:expr< let $globals in $e >> ]
        end ]
  ;

  (* class subst gmod = *)
  (*   object *)
  (*     inherit Ast.map as super; *)
  (*     method! ident = *)
  (*       fun *)
  (*       [ <:ident< $uid:x >> when x = gm -> gmod *)
  (*       | x -> super#ident x ]; *)
  (*   end; *)

 (* replace ast [Camlp4Grammar__] with [gmod]  *)   
  (* let subst_gmod ast gmod = (new subst gmod)#expr ast; *)

  (* the [gl] is global entry name list, [el] is entry list
     [gram] is the grammar, [gmod] is the [Gram] module
   *)
  let text_of_functorial_extend _loc  gram gl el = (* FIXME remove gmod later*)
    let args =
      let el =
        List.map
          (fun e ->
            let (ent, pos, txt) = text_of_entry e.name.loc e in
            <:expr< $(id:gm()).extend $ent ((fun () -> ($pos, $txt)) ()) >> ) el  in
      match el with
      [ [] -> <:expr< () >>
      | [e] -> e
      | [e::el] -> <:expr< do { $(List.fold_left (fun acc x -> <:expr< $acc; $x >>) e el) } >>  ]  in
    let_in_of_extend _loc gram gl el args;




 
  let mk_tok _loc p t =
    let p' = Ast.wildcarder#patt p in
    let match_fun =
      if Ast.is_irrefut_patt p' then
        <:expr< fun [ $pat:p' -> True ] >> (* why not p instead of p'*)
      else
        <:expr< fun [ $pat:p' -> True | _ -> False ] >> in
    let descr = string_of_patt p' in (* to normalize ?*)
    let text = TXtok _loc match_fun descr in
    {used = []; text = text; styp = t; pattern = Some p };

  let psymbol = Gram.mk "psymbol";

  (* FIXME why deprecate such syntax *)  
  let check_not_tok s =
    match s with
    [ {text = TXtok _loc _ _ ;_} ->
        FanLoc.raise _loc (Stream.Error
          ("Deprecated syntax, use a sub rule. "^
           "LIST0 STRING becomes LIST0 [ x = STRING -> x ]"))
    | _ -> () ];

  FanConfig.antiquotations := True;

  EXTEND Gram GLOBAL: expr psymbol;
    expr: After "top"
      [ [ "EXTEND"; extend_body{e}; "END" -> e
        | "DELETE_RULE"; delete_rule_body{e}; "END" -> e ] ] 
    extend_header:
      [ [ "("; qualid{i}; ":"; t_qualid{t}; ")" -> 
        let old=gm() in 
        let () = grammar_module_name := t in
        (Some i,old)
        |  qualuid{t} -> begin
            let old = gm() in
            let () = grammar_module_name := t in 
            (None,old)
        end
        | -> (None,gm()) (* FIXME *)
      ] ]
    extend_body:
      [ [ extend_header{(gram,old)};  OPT global{global_list};
          LIST1 [ entry{e}  -> e ]{el} -> (* semi_sep removed *)
            let res = text_of_functorial_extend _loc  gram global_list el in 
            let () = grammar_module_name := old in
            res 
        ] ] 
    delete_rule_body:
      [ [ delete_rule_header{old};  name{n}; ":";  LIST0 psymbol SEP semi_sep{sl} -> 
        let (e, b) = expr_of_delete_rule _loc n sl in (*FIXME*)
        let res =  <:expr< $(id:gm()).delete_rule $e $b >>  in
        let () = grammar_module_name := old  in 
        res
        ] ]
     delete_rule_header: (*for side effets, parser action *)
        [[  qualuid{g} ->
          let old = gm () in
          let () = grammar_module_name := g in
          old
         ]]
    qualuid:
      [ [ `UIDENT x; ".";  SELF{xs} -> <:ident< $uid:x.$xs >>
        | `UIDENT x -> <:ident< $uid:x >> ] ] 
    qualid:
      [ [ `UIDENT x; "."; SELF{xs} -> <:ident< $uid:x.$xs >>
        | `UIDENT x -> <:ident< $uid:x >>
        | `LIDENT x -> <:ident< $lid:x >> ] ]
    t_qualid:
      [ [ `UIDENT x; "."; SELF{xs} -> <:ident< $uid:x.$xs >>
        | `UIDENT x; "."; `LIDENT "t" -> <:ident< $uid:x >> ] ] 
    global:
      [ [ `UIDENT "GLOBAL"; ":"; LIST1 name{sl}; semi_sep -> sl ] ]
    entry:
      [ [  name{n}; ":"; OPT position{pos};  level_list{ll} ->
            {name = n; pos = pos; levels = ll} ] ]
    position:
      [ [ `UIDENT ("First"|"Last" as x ) ->
         <:expr< `$uid:x >>
        (* <:expr< FanSig.Grammar.$uid:x >> *)
        | `UIDENT ("Before" | "After" | "Level" as x) ;  string{n} ->
            <:expr< ` $uid:x  $n >> (*FIXME string escape?*)
            (* <:expr< FanSig.Grammar.$uid:x $n >> *)
        ] ]
    level_list:
      [ [ "["; LIST0 level SEP "|"{ll}; "]" -> ll ] ]
    level:
      [ [ OPT [STRING{x} -> x ]{lab};  OPT assoc{ass};  rule_list{rules} ->
            {label = lab; assoc = ass; rules = rules} ] ]
    assoc:
      [
       [ `UIDENT ("LA"|"RA"|"NA" as x) ->
         <:expr< `$uid:x >> 
         (* <:expr< FanSig.Grammar.$uid:x >> *)
       | `UIDENT x -> failwithf "%s is not a correct associativity:(LA|RA|NA)" x 
      ] ]
    rule_list:
      [ [ "["; "]" -> []
        | "["; LIST1 rule SEP "|"{rules}; "]" ->
            retype_rule_list_without_patterns _loc rules ] ]
    rule:
      [ [ LIST0 psymbol SEP semi_sep{psl}; "->"; expr{act} ->
            {prod = psl; action = Some act}
        |  LIST0 psymbol SEP semi_sep{psl} ->
            {prod = psl; action = None} ] ]
    (* psymbol: *)
      (* [ (\* [ p = LIDENT; "="; s = psymbol -> {(s) with pattern = Some <:patt< $lid:p >> } *\) *)
            (* match s.pattern with *)
            (* [ Some (<:patt< $uid:u $(tup:<:patt< _ >>) >> as p') -> *)
            (*     let match_fun = <:expr< fun [ $pat:p' -> True | _ -> False ] >> in *)
            (*     let p' = <:patt< ($p' as $lid:p) >> in *)
            (*     let descr = u ^ " _" in *)
            (*     let text = TXtok _loc match_fun descr in *)
            (*     { (s) with text = text; pattern = Some p' } *)
            (* | _ -> { (s) with pattern = Some <:patt< $lid:p >> } ] *)
        (* | i = LIDENT; lev = OPT [ `UIDENT "Level"; s = STRING -> s ] -> *)
        (*     let name = mk_name _loc <:ident< $lid:i >> in *)
        (*     let text = TXnterm _loc name lev in *)
        (*     let styp = STquo _loc i in *)
        (*     {used = [i]; text = text; styp = styp; pattern = None} *)
        (* [ p = pattern; "="; s = psymbol -> *)
        (*     {(s) with pattern = Some p} *)
            (* match s.pattern with *)
            (* [ Some <:patt< $uid:u $(tup:<:patt< _ >>) >> -> *)
            (*     mk_tok _loc <:patt< `$uid:u $p >> s.styp *)
            (* | _ -> { (s) with pattern = Some p } ] *)
        (* | s = psymbol -> s ] ] *)

    psymbol:
      [ "top" NA
        [ `UIDENT ("LIST0"| "LIST1" as x);  SELF{s};  OPT [ `UIDENT "SEP";  psymbol{t} -> t ]{sep} ->
            let () = check_not_tok s in
            let used =  match sep with
              [ Some symb -> symb.used @ s.used
              | None -> s.used ]   in
            let styp = STapp _loc (STlid _loc "list") s.styp in
            let text = slist _loc
                (match x with ["LIST0" -> False | "LIST1" -> True | _ -> failwithf "only (LIST0|LIST1) allowed here"])  sep s in
            {used = used; text = text; styp = styp; pattern = None}
        | `UIDENT "OPT"; SELF{s} ->
            let () = check_not_tok s in
            let styp = STapp _loc (STlid _loc "option") s.styp in
            let text = TXopt _loc s.text in
            {used = s.used; text = text; styp = styp; pattern = None}
        | `UIDENT "TRY"; SELF{s} ->
            let text = TXtry _loc s.text in
            {used = s.used; text = text; styp = s.styp; pattern = None} ]
      | [ `UIDENT "SELF" ->
            {used = []; text = TXself _loc; styp = STself _loc "SELF"; pattern = None}
        | `UIDENT "NEXT" ->
            {used = []; text = TXnext _loc; styp = STself _loc "NEXT"; pattern = None}
        | "[";  LIST0 rule SEP "|"{rl}; "]" ->
            let rl = retype_rule_list_without_patterns _loc rl in
            let t = new_type_var () in
            {used = used_of_rule_list rl;
            text = TXrules _loc (srules _loc t rl "");
            styp = STquo _loc t; pattern = None}
        (* parsing `UIDENT *)                    
        | TRY "`"; patt{p} -> mk_tok _loc p (STtok _loc) (* support pattern direclty instead*)
        (* | x = `UIDENT -> mk_tok _loc <:patt< `$uid:x _ >> (\* FIXED singleton tuple *\) *)
        (*                        (STstring_tok _loc) *)
        (* Notice that they have different s.styp, then do some simple transformation*)      
        (* | x = `UIDENT; s = STRING -> mk_tok _loc <:patt< `$uid:x $str:s >> (STtok _loc) *)
              
        (* | x = `UIDENT; `ANTIQUOT "" s -> *)
        (*     let e = AntiquotSyntax.parse_expr _loc s in *)
        (*     let match_fun = <:expr< fun [ $uid:x camlp4_x when camlp4_x = $e -> True | _ -> False ] >> in *)
        (*     let descr = "$" ^ x ^ " " ^ s in *)
        (*     let text = TXtok _loc match_fun descr in *)
        (*     let p = <:patt< $uid:x $(tup:<:patt< _ >>) >> in *)
        (*     {used = []; text = text; styp = STtok _loc; pattern = Some p } *)
        |  STRING{s} ->
            {used = []; text = TXkwd _loc s;
             styp = STtok _loc; pattern = None }
        (* | "'" ; i = `UIDENT; "."; il = qualid; *)
        (*   lev = OPT [ `UIDENT "Level"; s = STRING -> s ] -> *)
        (*     let n = mk_name _loc <:ident< $uid:i.$il >> in *)
        (*     {used = [n.tvar]; text = TXnterm _loc n lev; *)
        (*     styp = STquo _loc n.tvar; pattern = None} *)
        |  name{n}; OPT [ `UIDENT "Level";  STRING{s} -> s ]{lev} ->
            {used = [n.tvar]; text = TXnterm _loc n lev;
             styp = STquo _loc n.tvar; pattern = None}
        |  SELF{s}; "{"; pattern{p}; "}"   -> { (s) with pattern = Some p}
            
        | "("; SELF{s_t}; ")" -> s_t ] ]
    pattern:
        [ [ `LIDENT i -> <:patt< $lid:i >>
        | "_" -> <:patt< _ >>
        | "("; pattern{p}; ")" -> <:patt< $p >>
        | "(";  pattern{p1}; ",";  comma_patt{p2}; ")" -> <:patt< ( $p1, $p2 ) >>
      ] ]
    comma_patt:
      [ [  SELF{p1}; ",";  SELF{p2} -> <:patt< $p1, $p2 >>
        | pattern{p} -> p
      ] ]
    name:
      [ [ qualid{il} -> mk_name _loc il ] ]
    string:
      [ [ STRING{s} -> <:expr< $str:s >>
        | `ANTIQUOT "" s -> AntiquotSyntax.parse_expr _loc s ] ]
    semi_sep:
      [ [ ";" -> () ] ]
  END;

  (*
  EXTEND Gram
    symbol: Level "top"
      [ NA
        [ min = [ `UIDENT "SLIST0" -> False | `UIDENT "SLIST1" -> True ];
          s = SELF; sep = OPT [ `UIDENT "SEP"; t = symbol -> t ] ->
            sslist _loc min sep s
        | `UIDENT "SOPT"; s = SELF ->
            ssopt _loc s ] ]
  END;
  *)

  let sfold _loc  n foldfun f e s =
    let styp = STquo _loc (new_type_var ()) in
    let e = <:expr< $(id:gm()).$lid:foldfun $f $e >> in
    let t = STapp _loc (STapp _loc (STtyp <:ctyp< $(id:gm()).fold _ >>) s.styp) styp in
    {used = s.used; text = TXmeta _loc n [s.text] e t; styp = styp; pattern = None } ;

  let sfoldsep  _loc n foldfun f e s sep =
    let styp = STquo _loc (new_type_var ()) in
    let e = <:expr< $(id:gm()).$lid:foldfun $f $e >> in
    let t =
      STapp _loc (STapp _loc (STtyp <:ctyp< $(id:gm()).foldsep _ >>) s.styp) styp
    in
    {used = s.used @ sep.used; text = TXmeta _loc n [s.text; sep.text] e t;
    styp = styp; pattern = None} ;

  EXTEND Gram
    GLOBAL: psymbol;
    psymbol: Level "top"
      [ [ `UIDENT "FOLD0";  simple_expr{f};  simple_expr{e};  SELF{s} ->
            sfold _loc "FOLD0" "sfold0" f e s
        | `UIDENT "FOLD1"; simple_expr{f}; simple_expr{e};  SELF{s} ->
            sfold _loc "FOLD1" "sfold1" f e s
        | `UIDENT "FOLD0"; simple_expr{f}; simple_expr{e}; SELF{s};
          `UIDENT "SEP"; psymbol{sep} ->
            sfoldsep _loc "FOLD0 SEP" "sfold0sep" f e s sep
        | `UIDENT "FOLD1"; simple_expr{f}; simple_expr{e};  SELF{s};
          `UIDENT "SEP"; psymbol{sep} ->
            sfoldsep _loc "FOLD1 SEP" "sfold1sep" f e s sep ] ]
    simple_expr:
      [ [ a_LIDENT{i} -> <:expr< $lid:i >>
        | "("; expr{e}; ")" -> e ] ]
  END;

  Options.add "-split_ext" (Arg.Set split_ext)
    "Split EXTEND by functions to turn around a PowerPC problem.";

  Options.add "-split_gext" (Arg.Set split_ext)
    "Old name for the option -split_ext.";

  Options.add "-meta_action" (Arg.Set meta_action)
    "Undocumented"; (* FIXME *)

end;

module IdListComprehension = struct
  let name = "Camlp4ListComprehension";
  let version = Sys.ocaml_version;
end;

module MakeListComprehension (Syntax : Sig.Camlp4Syntax) = struct
  open FanSig;
  include Syntax;
  module Ast = Camlp4Ast;

  (* usual trick *) (* FIXME utilities based on Gram *)
  let test_patt_lessminus =
    Gram.of_parser "test_patt_lessminus"
      (fun strm ->
        let rec skip_patt n =
          match stream_peek_nth n strm with
          [ Some (KEYWORD "<-") -> n
          | Some (KEYWORD ("[" | "[<")) ->
              skip_patt (ignore_upto "]" (n + 1) + 1)
          | Some (KEYWORD "(") ->
              skip_patt (ignore_upto ")" (n + 1) + 1)
          | Some (KEYWORD "{") ->
              skip_patt (ignore_upto "}" (n + 1) + 1)
          | Some (KEYWORD ("as" | "::" | "," | "_"))
          | Some (LIDENT _ | `UIDENT _) -> skip_patt (n + 1)
          | Some _ | None -> raise Stream.Failure ]
        and ignore_upto end_kwd n =
          match stream_peek_nth n strm with
          [ Some (KEYWORD prm) when prm = end_kwd -> n
          | Some (KEYWORD ("[" | "[<")) ->
              ignore_upto end_kwd (ignore_upto "]" (n + 1) + 1)
          | Some (KEYWORD "(") ->
              ignore_upto end_kwd (ignore_upto ")" (n + 1) + 1)
          | Some (KEYWORD "{") ->
              ignore_upto end_kwd (ignore_upto "}" (n + 1) + 1)
          | Some _ -> ignore_upto end_kwd (n + 1)
          | None -> raise Stream.Failure ]
        in
        skip_patt 1);

  DELETE_RULE Gram expr: "["; sem_expr_for_list; "]" END;

  (* test wheter revised or not hack*)  
  let is_revised =
    try do {
      DELETE_RULE Gram expr: "["; sem_expr_for_list; "::"; expr; "]" END;
      True
    } with [ Not_found -> False ];

  let comprehension_or_sem_expr_for_list =
    Gram.mk "comprehension_or_sem_expr_for_list";
  EXTEND Gram
    GLOBAL: expr comprehension_or_sem_expr_for_list;
    expr: Level "simple"
      [ [ "["; comprehension_or_sem_expr_for_list{e}; "]" -> e ] ]  
    comprehension_or_sem_expr_for_list:
      [ [ expr Level "top"{e}; ";"; sem_expr_for_list{mk} ->
            <:expr< [ $e :: $(mk <:expr< [] >>) ] >>
        |  expr Level "top"{e}; ";" -> <:expr< [$e] >>
        | expr Level "top"{e}; "|";  LIST1 item SEP ";"{l} -> Expr.compr _loc e l
        | expr Level "top"{e} -> <:expr< [$e] >> ] ]  
    item:
      (* NP: These rules rely on being on this particular order. Which should
             be improved. *)
      [ [ TRY [ patt{p}; "<-" -> p]{p} ;  expr Level "top"{e} -> `gen (p, e)
        | expr Level "top"{e} -> `cond e ] ] 
  END;
  if is_revised then
    EXTEND Gram
      GLOBAL: expr comprehension_or_sem_expr_for_list;
      comprehension_or_sem_expr_for_list:
      [ [  expr Level "top"{e}; ";"; sem_expr_for_list{mk}; "::";  expr{last} ->
            <:expr< [ $e :: $(mk last) ] >>
        | expr Level "top"{e}; "::";  expr{last} ->
            <:expr< [ $e :: $last ] >> ] ] 
    END
  else ();

end;
  
module IdMacroParser = struct
  let name = "Camlp4MacroParser";
  let version = Sys.ocaml_version;
end;

(*
Added statements:

  At toplevel (structure item):

     DEFINE <uident>
     DEFINE <uident> = <expression>
     DEFINE <uident> (<parameters>) = <expression>
     IFDEF <uident> THEN <structure_items> [ ELSE <structure_items> ] (END | ENDIF)
     IFNDEF <uident> THEN <structure_items> [ ELSE <structure_items> ] (END | ENDIF)
     INCLUDE <string>

  At toplevel (signature item):

     DEFINE <uident>
     IFDEF <uident> THEN <signature_items> [ ELSE <signature_items> ] (END | ENDIF)
     IFNDEF <uident> THEN <signature_items> [ ELSE <signature_items> ] (END | ENDIF)
     INCLUDE <string>

  In expressions:

     IFDEF <uident> THEN <expression> [ ELSE <expression> ] (END | ENDIF)
     IFNDEF <uident> THEN <expression> [ ELSE <expression> ] (END | ENDIF)
     DEFINE <lident> = <expression> IN <expression>
     __FILE__
     __LOCATION__
     LOCATION_OF <parameter>

  In patterns:

     IFDEF <uident> THEN <pattern> ELSE <pattern> (END | ENDIF)
     IFNDEF <uident> THEN <pattern> ELSE <pattern> (END | ENDIF)

  As Camlp4 options:

     -D<uident> or -D<uident>=expr   define <uident> with optional let <expr>
     -U<uident>                      undefine it
     -I<dir>                         add <dir> to the search path for INCLUDE'd files

  After having used a DEFINE <uident> followed by "= <expression>", you
  can use it in expressions *and* in patterns. If the expression defining
  the macro cannot be used as a pattern, there is an error message if
  it is used in a pattern.

  You can also define a local macro in an expression usigng the DEFINE ... IN form.
  Note that local macros have lowercase names and can not take parameters.

  If a macro is defined to = NOTHING, and then used as an argument to a function,
  this will be equivalent to function taking one less argument. Similarly,
  passing NOTHING as an argument to a macro is equivalent to "erasing" the
  corresponding parameter from the macro body.

  The toplevel statement INCLUDE <string> can be used to include a
  file containing macro definitions and also any other toplevel items.
  The included files are looked up in directories passed in via the -I
  option, falling back to the current directory.

  The expression __FILE__ returns the current compiled file name.
  The expression __LOCATION__ returns the current location of itself.
  If used inside a macro, it returns the location where the macro is
  called.
  The expression (LOCATION_OF parameter) returns the location of the given
  macro parameter. It cannot be used outside a macro definition.

*)



module MakeMacroParser (Syntax : Sig.Camlp4Syntax) = struct
  open FanSig;
  include Syntax;
  module Ast = Camlp4Ast;
  type item_or_def 'a =
    [ SdStr of 'a
    | SdDef of string and option (list string * Ast.expr)
    | SdUnd of string
    | SdITE of bool and list (item_or_def 'a) and list (item_or_def 'a)
    | SdLazy of Lazy.t 'a ];
  let defined = ref [];
  let is_defined i = List.mem_assoc i !defined;
  let incorrect_number loc l1 l2 =
    FanLoc.raise loc
      (Failure
        (Printf.sprintf "expected %d parameters; found %d"
            (List.length l2) (List.length l1)));
  let define eo x = begin 
      match eo with
      [ Some ([], e) ->
        EXTEND Gram
          expr: Level "simple"
          [ [ `UIDENT $x -> (new Ast.reloc _loc)#expr e ]] 
        patt: Level "simple"
          [ [ `UIDENT $x ->
            let p = Expr.substp _loc [] e
            in (new Ast.reloc _loc)#patt p ]]
        END
      | Some (sl, e) ->
          EXTEND Gram
            expr: Level "apply"
            [ [ `UIDENT $x;  SELF{param} ->
              let el =  match param with
              [ <:expr< ($tup:e) >> -> Ast.list_of_expr e []
              | e -> [e] ]  in
              if List.length el = List.length sl then
                let env = List.combine sl el in
                (new Expr.subst _loc env)#expr e
              else
                incorrect_number _loc el sl ] ] 
          patt: Level "simple"
            [ [ `UIDENT $x; SELF{param} ->
              let pl = match param with
              [ <:patt< ($tup:p) >> -> Ast.list_of_patt p []
              | p -> [p] ] in
              if List.length pl = List.length sl then
                let env = List.combine sl pl in
                let p = Expr.substp _loc env e in
                (new Ast.reloc _loc)#patt p
              else
                incorrect_number _loc pl sl ] ]
          END
      | None -> () ];
      defined := [(x, eo) :: !defined]
    end;

  let undef x =
    try
      begin
        let eo = List.assoc x !defined in
        match eo with
        [ Some ([], _) ->
            do {
              DELETE_RULE Gram expr: `UIDENT $x END;
              DELETE_RULE Gram patt: `UIDENT $x END;
            }
        | Some (_, _) ->
            do {
              DELETE_RULE Gram expr: `UIDENT $x; SELF END;
              DELETE_RULE Gram patt: `UIDENT $x; SELF END;
            }
        | None -> () ];
        defined := list_remove x !defined;
      end
    with
    [ Not_found -> () ];

  let parse_def s =
    match Gram.parse_string expr (FanLoc.mk "<command line>") s with
    [ <:expr< $uid:n >> -> define None n
    | <:expr< $uid:n = $e >> -> define (Some ([],e)) n
    | _ -> invalid_arg s ];

  (* This is a list of directories to search for INCLUDE statements. *)
  let include_dirs = ref [];

  (* Add something to the above, make sure it ends with a slash. *)
  let add_include_dir str =
    if str <> "" then
      let str =
        if String.get str ((String.length str)-1) = '/'
        then str else str ^ "/"
      in include_dirs := !include_dirs @ [str]
    else ();

  let parse_include_file rule =
    let dir_ok file dir = Sys.file_exists (dir ^ file) in
    fun file ->
      let file =
        try (List.find (dir_ok file) (!include_dirs @ ["./"])) ^ file
        with [ Not_found -> file ]
      in
      let ch = open_in file in
      let st = Stream.of_channel ch in
        Gram.parse rule (FanLoc.mk file) st;

  let rec execute_macro nil cons =
    fun
    [ SdStr i -> i
    | SdDef x eo -> do { define eo x; nil }
    | SdUnd x -> do { undef x; nil }
    | SdITE b l1 l2 -> execute_macro_list nil cons (if b then l1 else l2)
    | SdLazy l -> Lazy.force l ]

  and execute_macro_list nil cons = fun
  [ [] -> nil
  | [hd::tl] -> (* The evaluation order is important here *)
    let il1 = execute_macro nil cons hd in
    let il2 = execute_macro_list nil cons tl in
    cons il1 il2 ] ;

  (* Stack of conditionals. *)
  let stack = Stack.create () ;

  (* Make an SdITE let by extracting the result of the test from the stack. *)
  let make_SdITE_result st1 st2 =
   let test = Stack.pop stack in
   SdITE test st1 st2 ;

  type branch = [ Then | Else ];

  (* Execute macro only if it belongs to the currently active branch. *)
  let execute_macro_if_active_branch _loc nil cons branch macro_def =
   let test = Stack.top stack in
   let item =
     if (test && branch=Then) || ((not test) && branch=Else) then
      execute_macro nil cons macro_def
     else (* ignore the macro *)
      nil
   in SdStr(item)
   ;

  EXTEND Gram
    GLOBAL: expr patt str_item sig_item;
    str_item: First
      [ [  macro_def{x} ->
            execute_macro <:str_item<>> (fun a b -> <:str_item< $a; $b >>) x ] ]
    sig_item: First
      [ [  macro_def_sig{x} ->
            execute_macro <:sig_item<>> (fun a b -> <:sig_item< $a; $b >>) x ] ]
    macro_def:
      [ [ "DEFINE"; uident{i}; opt_macro_value{def} -> SdDef i def
        | "UNDEF";  uident{i} -> SdUnd i
        | "IFDEF";  uident_eval_ifdef;  "THEN";  smlist_then{st1};  else_macro_def{st2} ->
            make_SdITE_result st1 st2
        | "IFNDEF"; uident_eval_ifndef; "THEN"; smlist_then{st1};  else_macro_def{st2} ->
            make_SdITE_result st1 st2
        | "INCLUDE"; `STRING(fname,_) -> (*FIXME which position *)
            SdLazy (lazy (parse_include_file str_items fname)) ] ] 
    macro_def_sig:
      [ [ "DEFINE"; uident{i} -> SdDef i None
        | "UNDEF";  uident{i} -> SdUnd i
        | "IFDEF";  uident_eval_ifdef;  "THEN"; sglist_then{sg1}; else_macro_def_sig{sg2} ->
            make_SdITE_result sg1 sg2
        | "IFNDEF"; uident_eval_ifndef; "THEN"; sglist_then{sg1};  else_macro_def_sig{sg2} ->
            make_SdITE_result sg1 sg2
        | "INCLUDE"; `STRING(fname,_) -> (*FIXME *)
            SdLazy (lazy (parse_include_file sig_items fname)) ] ] 
    uident_eval_ifdef:
      [ [ uident{i} -> Stack.push (is_defined i) stack ]] 
    uident_eval_ifndef:
      [ [ uident{i} -> Stack.push (not (is_defined i)) stack ]] 
    else_macro_def:
      [ [ "ELSE"; smlist_else{st}; endif -> st
        | endif -> [] ] ]  
    else_macro_def_sig:
      [ [ "ELSE"; sglist_else{st}; endif -> st
        | endif -> [] ] ]  
    else_expr:
      [ [ "ELSE";  expr{e}; endif -> e
      | endif -> <:expr< () >> ] ] 
    smlist_then:
      [ [  LIST1 [ macro_def{d}; semi ->
                          execute_macro_if_active_branch _loc <:str_item<>> (fun a b -> <:str_item< $a; $b >>) Then d
                      | str_item{si}; semi -> SdStr si ] {sml} -> sml ] ] 
    smlist_else:
      [ [ LIST1 [ macro_def{d}; semi ->
        execute_macro_if_active_branch _loc <:str_item<>> (fun a b -> <:str_item< $a; $b >>) Else d
      | str_item{si}; semi -> SdStr si ]{sml} -> sml ] ] 
    sglist_then:
      [ [ LIST1 [ macro_def_sig{d}; semi ->
        execute_macro_if_active_branch _loc <:sig_item<>> (fun a b -> <:sig_item< $a; $b >>) Then d
        | sig_item{si}; semi -> SdStr si ]{sgl} -> sgl ] ]  
    sglist_else:
      [ [ LIST1 [ macro_def_sig{d}; semi ->
        execute_macro_if_active_branch _loc <:sig_item<>> (fun a b -> <:sig_item< $a; $b >>) Else d
        | sig_item{si}; semi -> SdStr si ]{sgl} -> sgl ] ]  
    endif:
      [ [ "END" -> ()
        | "ENDIF" -> () ] ]  
    opt_macro_value:
      [ [ "("; LIST1 [ LIDENT{x} -> x ] SEP ","{pl}; ")"; "=";  expr{e} -> Some (pl, e)
        | "="; expr{e} -> Some ([], e)
        | -> None ] ]  
    expr: Level "top"
      [ [ "IFDEF"; uident{i}; "THEN"; expr{e1}; else_expr{e2} ->
            if is_defined i then e1 else e2
        | "IFNDEF"; uident{i}; "THEN"; expr{e1}; else_expr{e2} ->
            if is_defined i then e2 else e1
        | "DEFINE";  LIDENT{i}; "=";  expr{def}; "IN"; expr{body} ->
            (new Expr.subst _loc [(i, def)])#expr body ] ] 
    patt:
      [ [ "IFDEF";  uident{i}; "THEN"; patt{p1}; "ELSE";  patt{p2}; endif ->
            if is_defined i then p1 else p2
        | "IFNDEF"; uident{i}; "THEN";  patt{p1}; "ELSE";  patt{p2}; endif ->
            if is_defined i then p2 else p1 ] ] 
    uident:
      [ [  `UIDENT i -> i ] ]  
    (* dirty hack to allow polymorphic variants using the introduced keywords. *)
    expr: Before "simple"
      [ [ "`";  [ "IFDEF" | "IFNDEF" | "THEN" | "ELSE" | "END" | "ENDIF"
                     | "DEFINE" | "IN" ]{kwd} -> <:expr< `$uid:kwd >>
        | "`";  a_ident{s} -> <:expr< ` $s >> ] ] 
    (* idem *)
    patt: Before "simple"
      [ [ "`"; [ "IFDEF" | "IFNDEF" | "THEN" | "ELSE" | "END" | "ENDIF" ] {kwd} ->
            <:patt< `$uid:kwd >>
        | "`";  a_ident{s} -> <:patt< ` $s >> ] ]
  END;

  Options.add "-D" (Arg.String parse_def)
    "<string> Define for IFDEF instruction.";
  Options.add "-U" (Arg.String undef)
    "<string> Undefine for IFDEF instruction.";
  Options.add "-I" (Arg.String add_include_dir)
    "<string> Add a directory to INCLUDE search path.";
end;
module MakeNothing (Syn : Sig.Camlp4Syntax) = struct
 module Ast = Camlp4Ast ;
 (* Remove NOTHING and expanse __FILE__ and __LOCATION__ *)
 Syn.AstFilters.register_str_item_filter (Ast.map_expr Expr.map_expr)#str_item;
end;

module IdRevisedParser = struct
  let name = "Camlp4OCamlRevisedParser";
  let version = Sys.ocaml_version;
end;

module MakeRevisedParser (Syntax : Sig.Camlp4Syntax) = struct
  open FanSig;
  include Syntax;
  module Ast = Camlp4Ast;
  FanConfig.constructors_arity := False;

  let help_sequences () =
    do {
      Printf.eprintf "\
New syntax:\
\n    (e1; e2; ... ; en) OR begin e1; e2; ... ; en end\
\n    while e do e1; e2; ... ; en done\
\n    for v = v1 to/downto v2 do e1; e2; ... ; en done\
\nOld syntax (still supported):\
\n    do {e1; e2; ... ; en}\
\n    while e do {e1; e2; ... ; en}\
\n    for v = v1 to/downto v2 do {e1; e2; ... ; en}\
\nVery old (no more supported) syntax:\
\n    do e1; e2; ... ; en-1; return en\
\n    while e do e1; e2; ... ; en; done\
\n    for v = v1 to/downto v2 do e1; e2; ... ; en; done\
\n";
      flush stderr;
      exit 1
    }
  ;
  Options.add "-help_seq" (Arg.Unit help_sequences)
    "Print explanations about new sequences and exit.";
  Gram.clear a_CHAR;
  Gram.clear a_FLOAT;
  Gram.clear a_INT;
  Gram.clear a_INT32;
  Gram.clear a_INT64;
  Gram.clear a_LABEL;
  Gram.clear a_LIDENT;
  Gram.clear a_NATIVEINT;
  Gram.clear a_OPTLABEL;
  Gram.clear a_STRING;
  Gram.clear a_UIDENT;
  Gram.clear a_ident;
  Gram.clear amp_ctyp;
  Gram.clear and_ctyp;
  Gram.clear match_case;
  Gram.clear match_case0;
  Gram.clear match_case_quot;
  Gram.clear binding;
  Gram.clear binding_quot;
  Gram.clear rec_binding_quot;
  Gram.clear class_declaration;
  Gram.clear class_description;
  Gram.clear class_expr;
  Gram.clear class_expr_quot;
  Gram.clear class_fun_binding;
  Gram.clear class_fun_def;
  Gram.clear class_info_for_class_expr;
  Gram.clear class_info_for_class_type;
  Gram.clear class_longident;
  Gram.clear class_longident_and_param;
  Gram.clear class_name_and_param;
  Gram.clear class_sig_item;
  Gram.clear class_sig_item_quot;
  Gram.clear class_signature;
  Gram.clear class_str_item;
  Gram.clear class_str_item_quot;
  Gram.clear class_structure;
  Gram.clear class_type;
  Gram.clear class_type_declaration;
  Gram.clear class_type_longident;
  Gram.clear class_type_longident_and_param;
  Gram.clear class_type_plus;
  Gram.clear class_type_quot;
  Gram.clear comma_ctyp;
  Gram.clear comma_expr;
  Gram.clear comma_ipatt;
  Gram.clear comma_patt;
  Gram.clear comma_type_parameter;
  Gram.clear constrain;
  Gram.clear constructor_arg_list;
  Gram.clear constructor_declaration;
  Gram.clear constructor_declarations;
  Gram.clear ctyp;
  Gram.clear ctyp_quot;
  Gram.clear cvalue_binding;
  Gram.clear direction_flag;
  Gram.clear dummy;
  Gram.clear eq_expr;
  Gram.clear expr;
  Gram.clear expr_eoi;
  Gram.clear expr_quot;
  Gram.clear field_expr;
  Gram.clear field_expr_list;
  Gram.clear fun_binding;
  Gram.clear fun_def;
  Gram.clear ident;
  Gram.clear ident_quot;
  Gram.clear implem;
  Gram.clear interf;
  Gram.clear ipatt;
  Gram.clear ipatt_tcon;
  Gram.clear label;
  Gram.clear label_declaration;
  Gram.clear label_declaration_list;
  Gram.clear label_expr_list;
  Gram.clear label_expr;
  Gram.clear label_ipatt;
  Gram.clear label_ipatt_list;
  Gram.clear label_longident;
  Gram.clear label_patt;
  Gram.clear label_patt_list;
  Gram.clear labeled_ipatt;
  Gram.clear let_binding;
  Gram.clear meth_list;
  Gram.clear meth_decl;
  Gram.clear module_binding;
  Gram.clear module_binding0;
  Gram.clear module_binding_quot;
  Gram.clear module_declaration;
  Gram.clear module_expr;
  Gram.clear module_expr_quot;
  Gram.clear module_longident;
  Gram.clear module_longident_with_app;
  Gram.clear module_rec_declaration;
  Gram.clear module_type;
  Gram.clear module_type_quot;
  Gram.clear more_ctyp;
  Gram.clear name_tags;
  Gram.clear opt_as_lident;
  Gram.clear opt_class_self_patt;
  Gram.clear opt_class_self_type;
  Gram.clear opt_comma_ctyp;
  Gram.clear opt_dot_dot;
  Gram.clear opt_eq_ctyp;
  Gram.clear opt_expr;
  Gram.clear opt_meth_list;
  Gram.clear opt_mutable;
  Gram.clear opt_polyt;
  Gram.clear opt_private;
  Gram.clear opt_rec;
  Gram.clear opt_virtual;
  Gram.clear opt_when_expr;
  Gram.clear patt;
  Gram.clear patt_as_patt_opt;
  Gram.clear patt_eoi;
  Gram.clear patt_quot;
  Gram.clear patt_tcon;
  Gram.clear phrase;
  Gram.clear poly_type;
  Gram.clear row_field;
  Gram.clear sem_expr;
  Gram.clear sem_expr_for_list;
  Gram.clear sem_patt;
  Gram.clear sem_patt_for_list;
  Gram.clear semi;
  Gram.clear sequence;
  Gram.clear sig_item;
  Gram.clear sig_item_quot;
  Gram.clear sig_items;
  Gram.clear star_ctyp;
  Gram.clear str_item;
  Gram.clear str_item_quot;
  Gram.clear str_items;
  Gram.clear top_phrase;
  Gram.clear type_constraint;
  Gram.clear type_declaration;
  Gram.clear type_ident_and_parameters;
  Gram.clear type_kind;
  Gram.clear type_longident;
  Gram.clear type_longident_and_parameters;
  Gram.clear type_parameter;
  Gram.clear type_parameters;
  Gram.clear typevars;
  Gram.clear use_file;
  Gram.clear val_longident;
  Gram.clear with_constr;
  Gram.clear with_constr_quot;

  let setup_op_parser entry p =
    Gram.setup_parser entry
      (parser
        [< (KEYWORD x | SYMBOL x, ti) when p x >] ->
          let _loc = Gram.token_location ti in
          <:expr< $lid:x >>);

  let list = ['!'; '?'; '~'] in
  let excl = ["!="; "??"] in
  setup_op_parser prefixop
    (fun x -> not (List.mem x excl) && String.length x >= 2 &&
              List.mem x.[0] list && symbolchar x 1);

  let list_ok = ["<"; ">"; "<="; ">="; "="; "<>"; "=="; "!="; "$"] in
  let list_first_char_ok = ['='; '<'; '>'; '|'; '&'; '$'; '!'] in
  let excl = ["<-"; "||"; "&&"] in
  setup_op_parser infixop0
    (fun x -> (List.mem x list_ok) ||
              (not (List.mem x excl) && String.length x >= 2 &&
              List.mem x.[0] list_first_char_ok && symbolchar x 1));

  let list = ['@'; '^'] in
  setup_op_parser infixop1
    (fun x -> String.length x >= 1 && List.mem x.[0] list &&
              symbolchar x 1);

  let list = ['+'; '-'] in
  setup_op_parser infixop2
    (fun x -> x <> "->" && String.length x >= 1 && List.mem x.[0] list &&
              symbolchar x 1);

  let list = ['*'; '/'; '%'; '\\'] in
  setup_op_parser infixop3
    (fun x -> String.length x >= 1 && List.mem x.[0] list &&
              (x.[0] <> '*' || String.length x < 2 || x.[1] <> '*') &&
              symbolchar x 1);

  setup_op_parser infixop4
    (fun x -> String.length x >= 2 && x.[0] == '*' && x.[1] == '*' &&
              symbolchar x 2);

  let rec infix_kwds_filter =
    parser
    [ [< ((KEYWORD "(", _) as tok); 'xs >] ->
        match xs with parser
        [ [< (KEYWORD ("or"|"mod"|"land"|"lor"|"lxor"|"lsl"|"lsr"|"asr" as i), _loc);
             (KEYWORD ")", _); 'xs >] ->
                [< (LIDENT i, _loc); '(infix_kwds_filter xs) >]
        | [< 'xs >] ->
                [< tok; '(infix_kwds_filter xs) >] ]
    | [< x; 'xs >] -> [< x; '(infix_kwds_filter xs) >] ];

  Token.Filter.define_filter (Gram.get_filter ())
    (fun f strm -> infix_kwds_filter (f strm));

  Gram.setup_parser sem_expr begin
    let symb1 = Gram.parse_origin_tokens expr in
    let symb =
      parser
      [ [< (ANTIQUOT ("list" as n) s, ti) >] ->
        let _loc = Gram.token_location ti in
        <:expr< $(anti:mk_anti ~c:"expr;" n s) >>
      | [< a = symb1 >] -> a ]
    in
    let rec kont al =
      parser
      [ [< (KEYWORD ";", _); a = symb; 's >] ->
        let _loc = FanLoc.merge (Ast.loc_of_expr al)
                             (Ast.loc_of_expr a) in
        kont <:expr< $al; $a >> s
      | [< >] -> al ]
    in
    parser [< a = symb; 's >] -> kont a s
  end;

  EXTEND Gram
    GLOBAL:
      a_CHAR a_FLOAT a_INT a_INT32 a_INT64 a_LABEL a_LIDENT rec_binding_quot
      a_NATIVEINT a_OPTLABEL a_STRING a_UIDENT a_ident
      amp_ctyp and_ctyp match_case match_case0 match_case_quot binding binding_quot
      class_declaration class_description class_expr class_expr_quot
      class_fun_binding class_fun_def class_info_for_class_expr
      class_info_for_class_type class_longident class_longident_and_param
      class_name_and_param class_sig_item class_sig_item_quot class_signature
      class_str_item class_str_item_quot class_structure class_type
      class_type_declaration class_type_longident
      class_type_longident_and_param class_type_plus class_type_quot
      comma_ctyp comma_expr comma_ipatt comma_patt comma_type_parameter
      constrain constructor_arg_list constructor_declaration
      constructor_declarations ctyp ctyp_quot cvalue_binding direction_flag
      dummy eq_expr expr expr_eoi expr_quot field_expr field_expr_list fun_binding
      fun_def ident ident_quot implem interf ipatt ipatt_tcon label
      label_declaration label_declaration_list label_expr label_expr_list
      label_ipatt label_ipatt_list label_longident label_patt label_patt_list
      labeled_ipatt let_binding meth_list meth_decl module_binding module_binding0
      module_binding_quot module_declaration module_expr module_expr_quot
      module_longident module_longident_with_app module_rec_declaration
      module_type module_type_quot more_ctyp name_tags opt_as_lident
      opt_class_self_patt opt_class_self_type opt_comma_ctyp opt_dot_dot opt_eq_ctyp opt_expr
      opt_meth_list opt_mutable opt_polyt opt_private opt_rec
      opt_virtual opt_when_expr patt patt_as_patt_opt patt_eoi
      patt_quot patt_tcon phrase poly_type row_field
      sem_expr sem_expr_for_list sem_patt sem_patt_for_list semi sequence
      sig_item sig_item_quot sig_items star_ctyp str_item str_item_quot
      str_items top_phrase type_constraint type_declaration
      type_ident_and_parameters type_kind type_longident
      type_longident_and_parameters type_parameter type_parameters typevars
      use_file val_longident (* value_let *) (* value_val *) with_constr with_constr_quot
      infixop0 infixop1 infixop2 infixop3 infixop4 do_sequence package_type
      rec_flag_quot direction_flag_quot mutable_flag_quot private_flag_quot
      virtual_flag_quot row_var_flag_quot override_flag_quot;
    module_expr:
      [ "top"
        [ "functor"; "(";  a_UIDENT{i}; ":";  module_type{t}; ")"; "->";
          me = SELF ->
            <:module_expr< functor ( $i : $t ) -> $me >>
        | "struct"; str_items{st}; "end" ->
            <:module_expr< struct $st end >> ]
      | "apply"
        [ SELF{me1};  SELF{me2} -> <:module_expr< $me1 $me2 >> ]
      | "simple"
        [ `ANTIQUOT (""|"mexp"|"anti"|"list" as n) s ->
            <:module_expr< $(anti:mk_anti ~c:"module_expr" n s) >>
        | `QUOTATION x ->
            Quotation.expand _loc x DynAst.module_expr_tag
        |  module_longident{i} -> <:module_expr< $id:i >>
        | "(";  SELF{me}; ":";  module_type{mt}; ")" ->
            <:module_expr< ( $me : $mt ) >>
        | "(";  SELF{me}; ")" -> <:module_expr< $me >>
        | "("; "val"; expr{e}; ")" -> (* val *)
            <:module_expr< (val $e) >>  (* first class modules *)
        | "("; "val";  expr{e}; ":";  package_type{p}; ")" ->
            <:module_expr< (val $e : $p) >> ] ]
    str_item:
      [ "top"
        [ "exception";  constructor_declaration{t} ->
            <:str_item< exception $t >>
        | "exception"; constructor_declaration{t}; "="; type_longident{i} ->
            <:str_item< exception $t = $i >>
        | "external";  a_LIDENT{i}; ":";  ctyp{t}; "="; string_list{sl} ->
            <:str_item< external $i : $t = $sl >>
        | "include";  module_expr{me} -> <:str_item< include $me >>
        | "module";  a_UIDENT{i};  module_binding0{mb} ->
            <:str_item< module $i = $mb >>
        | "module"; "rec"; module_binding{mb} ->
            <:str_item< module rec $mb >>
        | "module"; "type";  a_ident{i}; "=";  module_type{mt} ->
            <:str_item< module type $i = $mt >>
        | "open";  module_longident{i} -> <:str_item< open $i >>
        | "type";  type_declaration{td} ->
            <:str_item< type $td >>
        | "let"; opt_rec{r};  binding{bi}; "in"; expr{x} ->
              <:str_item< let $rec:r $bi in $x >>
        | "let";  opt_rec{r}; binding{bi} ->   match bi with
            [ <:binding< _ = $e >> -> <:str_item< $exp:e >>
            | _ -> <:str_item< let $rec:r $bi >> ]
        | "let"; "module";  a_UIDENT{m};  module_binding0{mb}; "in";  expr{e} ->
              <:str_item< let module $m = $mb in $e >>
        | "let"; "open"; module_longident{i}; "in";  expr{e} ->
              <:str_item< let open $id:i in $e >>

        | "class";  class_declaration{cd} ->
            <:str_item< class $cd >>
        | "class"; "type"; class_type_declaration{ctd} ->
            <:str_item< class type $ctd >>
        | `ANTIQUOT (""|"stri"|"anti"|"list" as n) s ->
            <:str_item< $(anti:mk_anti ~c:"str_item" n s) >>
            (*
              first, it gives "mk_anti ~c:"str_item" n s" , and then through
              the meta operation, it gets
              (Ast.StAnt (_loc, ( (mk_anti ~c:"str_item" n s) )))
             *)
        | `QUOTATION x -> Quotation.expand _loc x DynAst.str_item_tag
        | expr{e} -> <:str_item< $exp:e >>
        (* this entry makes <:str_item< let $rec:r $bi in $x >> parsable *)
        ] ]
    module_binding0:
      [ RA
        [ "(";  a_UIDENT{m}; ":";  module_type{mt}; ")"; SELF{mb} ->
            <:module_expr< functor ( $m : $mt ) -> $mb >>
        | ":";  module_type{mt}; "=";  module_expr{me} ->
            <:module_expr< ( $me : $mt ) >>
        | "="; module_expr{me} -> <:module_expr< $me >> ] ]
    module_binding:
      [ LA
        [  SELF{b1}; "and";  SELF{b2} ->
            <:module_binding< $b1 and $b2 >>
        | `ANTIQUOT ("module_binding"|"anti"|"list" as n) s ->
            <:module_binding< $(anti:mk_anti ~c:"module_binding" n s) >>
        | `ANTIQUOT ("" as n) s ->
            <:module_binding< $(anti:mk_anti ~c:"module_binding" n s) >>
        | `ANTIQUOT ("" as n) m; ":"; mt = module_type; "="; me = module_expr ->
            <:module_binding< $(mk_anti n m) : $mt = $me >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.module_binding_tag
        |  a_UIDENT{m}; ":";  module_type{mt}; "=";  module_expr{me} ->
            <:module_binding< $m : $mt = $me >> ] ]
    module_type:
      [ "top"
        [ "functor"; "("; a_UIDENT{i}; ":";  SELF{t}; ")"; "->"; SELF{mt} ->
            <:module_type< functor ( $i : $t ) -> $mt >> ]
      | "with"
        [ SELF{mt}; "with";  with_constr{wc} ->
            <:module_type< $mt with $wc >> ]
      | "apply"
        [ SELF{mt1};  SELF{mt2}; dummy -> ModuleType.app mt1 mt2 ]
      | "."
        [  SELF{mt1}; "."; SELF{mt2} -> ModuleType.acc mt1 mt2 ]
      | "sig"
        [ "sig"; sig_items{sg}; "end" ->
            <:module_type< sig $sg end >> ]
      | "simple"
        [ `ANTIQUOT (""|"mtyp"|"anti"|"list" as n) s ->
            <:module_type< $(anti:mk_anti ~c:"module_type" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.module_type_tag
        | module_longident_with_app{i} -> <:module_type< $id:i >>
        | "'"; i = a_ident -> <:module_type< ' $i >>
        | "("; mt = SELF; ")" -> <:module_type< $mt >>
        | "module"; "type"; "of"; me = module_expr ->
            <:module_type< module type of $me >> ] ]
    sig_item:
      [ "top"
        [ `ANTIQUOT (""|"sigi"|"anti"|"list" as n) s ->
            <:sig_item< $(anti:mk_anti ~c:"sig_item" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.sig_item_tag
        | "exception"; constructor_declaration{t} ->
            <:sig_item< exception $t >>
        | "external";  a_LIDENT{i}; ":";  ctyp{t}; "=";  string_list{sl} ->
            <:sig_item< external $i : $t = $sl >>
        | "include";  module_type{mt} -> <:sig_item< include $mt >>
        | "module"; a_UIDENT{i};  module_declaration{mt} ->
            <:sig_item< module $i : $mt >>
        | "module"; "rec"; module_rec_declaration{mb} ->
            <:sig_item< module rec $mb >>
        | "module"; "type";  a_ident{i}; "=";  module_type{mt} ->
            <:sig_item< module type $i = $mt >>
        | "module"; "type"; a_ident{i} ->
            <:sig_item< module type $i >>
        | "open";  module_longident{i} -> <:sig_item< open $i >>
        | "type"; type_declaration{t} ->
            <:sig_item< type $t >>
        | "val"; a_LIDENT{i}; ":";  ctyp{t} ->
            <:sig_item< val $i : $t >>
        | "class";  class_description{cd} ->
            <:sig_item< class $cd >>
        | "class"; "type"; class_type_declaration{ctd} ->
            <:sig_item< class type $ctd >> ] ]
    module_declaration:
      [ RA
        [ ":"; module_type{mt} -> <:module_type< $mt >>
        | "(";  a_UIDENT{i}; ":";  module_type{t}; ")";  SELF{mt} ->
            <:module_type< functor ( $i : $t ) -> $mt >> ] ]
    module_rec_declaration:
      [ LA
        [  SELF{m1}; "and";  SELF{m2} -> <:module_binding< $m1 and $m2 >>
        | `ANTIQUOT (""|"module_binding"|"anti"|"list" as n) s ->
            <:module_binding< $(anti:mk_anti ~c:"module_binding" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.module_binding_tag
        | a_UIDENT{m}; ":";  module_type{mt} -> <:module_binding< $m : $mt >>
      ] ]
    with_constr:
      [ LA
        [ SELF{wc1}; "and";  SELF{wc2} -> <:with_constr< $wc1 and $wc2 >>
        | `ANTIQUOT (""|"with_constr"|"anti"|"list" as n) s ->
            <:with_constr< $(anti:mk_anti ~c:"with_constr" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.with_constr_tag
        | "type"; `ANTIQUOT (""|"typ"|"anti" as n) s; "="; t = ctyp ->
            <:with_constr< type $(anti:mk_anti ~c:"ctyp" n s) = $t >>
        | "type"; type_longident_and_parameters{t1}; "=";  ctyp{t2} ->
            <:with_constr< type $t1 = $t2 >>
        | "module";  module_longident{i1}; "=";  module_longident_with_app{i2} ->
            <:with_constr< module $i1 = $i2 >>
        | "type"; `ANTIQUOT (""|"typ"|"anti" as n) s; ":="; ctyp{t} ->
            <:with_constr< type $(anti:mk_anti ~c:"ctyp" n s) := $t >>
        | "type"; type_longident_and_parameters{t1}; ":=";  ctyp{t2} ->
            <:with_constr< type $t1 := $t2 >>
        | "module"; module_longident{i1}; ":="; module_longident_with_app{i2} ->
            <:with_constr< module $i1 := $i2 >> ] ]
    expr:
      [ "top" RA
        [ "let"; opt_rec{r};  binding{bi}; "in"; SELF{x} ->
            <:expr< let $rec:r $bi in $x >>
        | "let"; "module";  a_UIDENT{m};  module_binding0{mb}; "in";  SELF{e} ->
            <:expr< let module $m = $mb in $e >>
        | "let"; "open";  module_longident{i}; "in";  SELF{e} ->
            <:expr< let open $id:i in $e >>
        | "fun"; "[";  LIST0 match_case0 SEP "|"{a}; "]" ->
            <:expr< fun [ $list:a ] >>
        | "fun"; fun_def{e} -> e
        | "match";  sequence{e}; "with";  match_case{a} ->
            <:expr< match $(Expr.mksequence' _loc e) with [ $a ] >>
        | "try";  sequence{e}; "with"; match_case{a} ->
            <:expr< try $(Expr.mksequence' _loc e) with [ $a ] >>
        | "if"; SELF{e1}; "then";  SELF{e2}; "else";  SELF{e3} ->
            <:expr< if $e1 then $e2 else $e3 >>
        | "do";  do_sequence{seq} -> Expr.mksequence _loc seq
        | "for"; a_LIDENT{i}; "=";  sequence{e1};  direction_flag{df};
          sequence{e2}; "do"; do_sequence{seq} ->
            <:expr< for $i = $(Expr.mksequence' _loc e1) $to:df $(Expr.mksequence' _loc e2) do
              { $seq } >>
        | "while"; sequence{e}; "do";  do_sequence{seq} ->
            <:expr< while $(Expr.mksequence' _loc e) do { $seq } >>
        | "object"; opt_class_self_patt{csp};  class_structure{cst}; "end" ->
            <:expr< object ($csp) $cst end >> ]
      | "where"
        [ SELF{e}; "where";  opt_rec{rf}; let_binding{lb} ->
            <:expr< let $rec:rf $lb in $e >> ]
      | ":=" NA
        [ SELF{e1}; ":="; SELF{e2}; dummy ->
              <:expr< $e1 := $e2 >> 
        | SELF{e1}; "<-"; SELF{e2}; dummy -> (* FIXME should be deleted in original syntax later? *)
            match Expr.bigarray_set _loc e1 e2 with
            [ Some e -> e
            | None -> <:expr< $e1 <- $e2 >> 
            ]  
        ]
      | "||" RA
        [ SELF{e1}; infixop6{op};SELF{e2} -> <:expr< $op $e1 $e2 >> ]
      | "&&" RA
        [ SELF{e1};  infixop5{op};  SELF{e2} -> <:expr< $op $e1 $e2 >> ]
      | "<" LA
        [ SELF{e1}; infixop0{op};  SELF{e2} -> <:expr< $op $e1 $e2 >> ]
      | "^" RA
        [  SELF{e1}; infixop1{op};  SELF{e2} -> <:expr< $op $e1 $e2 >> ]
      | "+" LA
        [ SELF{e1}; infixop2{op};  SELF{e2} -> <:expr< $op $e1 $e2 >> ]
      | "*" LA
        [  SELF{e1}; "land"; SELF{e2} -> <:expr< $e1 land $e2 >>
        |  SELF{e1}; "lor";  SELF{e2} -> <:expr< $e1 lor $e2 >>
        |  SELF{e1}; "lxor"; SELF{e2} -> <:expr< $e1 lxor $e2 >>
        |  SELF{e1}; "mod";  SELF{e2} -> <:expr< $e1 mod $e2 >>
        |  SELF{e1}; infixop3{op};  SELF{e2} -> <:expr< $op $e1 $e2 >> ]
      | "**" RA
        [  SELF{e1}; "asr";  SELF{e2} -> <:expr< $e1 asr $e2 >>
        |  SELF{e1}; "lsl";  SELF{e2} -> <:expr< $e1 lsl $e2 >>
        |  SELF{e1}; "lsr";  SELF{e2} -> <:expr< $e1 lsr $e2 >>
        |  SELF{e1}; infixop4{op};  SELF{e2} -> <:expr< $op $e1 $e2 >> ]
      | "unary minus" NA
        [ "-"; SELF{e} -> Expr.mkumin _loc "-" e
        | "-.";SELF{e} -> Expr.mkumin _loc "-." e ]
      | "apply" LA
        [ SELF{e1}; SELF{e2} -> <:expr< $e1 $e2 >>
        | "assert"; SELF{e} -> Expr.mkassert _loc e
        | "new"; class_longident{i} -> <:expr< new $i >>
        | "lazy"; SELF{e} -> <:expr< lazy $e >> ]
      | "label" NA
        [ "~"; a_LIDENT{i}; ":"; e = SELF -> <:expr< ~ $i : $e >>
        | "~";  a_LIDENT{i} -> <:expr< ~ $i >>

        (* Here it's LABEL and not tilde_label since ~a:b is different than ~a : b *)
        | `LABEL i; SELF{e} -> <:expr< ~ $i : $e >>

        (* Same remark for ?a:b *)
        | `OPTLABEL i;  SELF{e} -> <:expr< ? $i : $e >>

        | "?";  a_LIDENT{i}; ":";  SELF{e} -> <:expr< ? $i : $e >>
        | "?";  a_LIDENT{i} -> <:expr< ? $i >> ]
      | "." LA
        [ SELF{e1}; "."; "(";  SELF{e2}; ")" -> <:expr< $e1 .( $e2 ) >>
        | SELF{e1}; "."; "[";  SELF{e2}; "]" -> <:expr< $e1 .[ $e2 ] >>
        | SELF{e1}; "."; "{";  comma_expr{e2}; "}" -> Expr.bigarray_get _loc e1 e2
        | SELF{e1}; "."; SELF{e2} -> <:expr< $e1 . $e2 >>
        | SELF{e}; "#";  label{lab} -> <:expr< $e # $lab >> ]
      | "~-" NA
        [ "!"; SELF{e} ->  <:expr< ! $e>>
        | prefixop{f};SELF{e} -> <:expr< $f $e >> ]
      | "simple"
        [ `QUOTATION x -> Quotation.expand _loc x DynAst.expr_tag
        | `ANTIQUOT ("exp"|""|"anti" as n) s ->
            <:expr< $(anti:mk_anti ~c:"expr" n s) >>
        | `ANTIQUOT ("`bool" as n) s ->
            <:expr< $(id:<:ident< $(anti:mk_anti n s) >>) >>
        | `ANTIQUOT ("tup" as n) s ->
            <:expr< $(tup: <:expr< $(anti:mk_anti ~c:"expr" n s) >>) >>
        | `ANTIQUOT ("seq" as n) s ->
            <:expr< do $(anti:mk_anti ~c:"expr" n s) done >>
        | a_INT{s} -> <:expr< $int:s >>
        | a_INT32{s} -> <:expr< $int32:s >>
        | a_INT64{s} -> <:expr< $int64:s >>
        | a_NATIVEINT{s} -> <:expr< $nativeint:s >>
        | a_FLOAT{s} -> <:expr< $flo:s >>
        | a_STRING{s} -> <:expr< $str:s >>
        | a_CHAR{s} -> <:expr< $chr:s >>
        | TRY module_longident_dot_lparen; e = sequence{i}; ")" ->
            <:expr< let open $i in $e >>
        | TRY val_longident{i} -> <:expr< $id:i >>
        | "`";  a_ident{s} -> <:expr< ` $s >>
        | "["; "]" -> <:expr< [] >>
        | "[";  sem_expr_for_list{mk_list}; "::"; last = expr; "]" ->
            mk_list last
        | "[";  sem_expr_for_list{mk_list}; "]" ->
            mk_list <:expr< [] >>
        | "[|"; "|]" -> <:expr< [| $(<:expr<>>) |] >>
        | "[|";  sem_expr{el}; "|]" -> <:expr< [| $el |] >>
        | "{"; label_expr_list{el}; "}" -> <:expr< { $el } >>
        | "{"; "("; SELF{e}; ")"; "with";label_expr_list{el}; "}" ->
            <:expr< { ($e) with $el } >>
        | "{<"; ">}" -> <:expr< {<>} >>
        | "{<";  field_expr_list{fel}; ">}" -> <:expr< {< $fel >} >>
        | "("; ")" -> <:expr< () >>
        | "("; SELF{e}; ":"; ctyp{t}; ")" -> <:expr< ($e : $t) >>
        | "("; SELF{e}; ","; comma_expr{el}; ")" -> <:expr< ( $e, $el ) >>
        | "("; SELF{e}; ";";  sequence{seq}; ")" -> Expr.mksequence _loc <:expr< $e; $seq >>
        | "("; SELF{e}; ";"; ")" -> Expr.mksequence _loc e
        | "("; SELF{e}; ":"; ctyp{t}; ":>"; t2 = ctyp; ")" ->
            <:expr< ($e : $t :> $t2 ) >>
        | "("; SELF{e}; ":>"; ctyp{t}; ")" -> <:expr< ($e :> $t) >>
        | "("; SELF{e}; ")" -> e
        | "begin";sequence{seq}; "end" -> Expr.mksequence _loc seq
        | "begin"; "end" -> <:expr< () >>
        | "("; "module";  module_expr{me}; ")" ->
            <:expr< (module $me) >>
        | "("; "module";  module_expr{me}; ":";  package_type{pt}; ")" ->
            <:expr< (module $me : $pt) >>
        ] ]
    do_sequence:
      [ [ TRY ["{"; seq = sequence; "}" {seq}-> seq] -> seq
        | TRY ["{"; "}"] -> <:expr< () >>
        | TRY [sequence{seq}; "done" -> seq]{seq} -> seq
        | "done" -> <:expr< () >>
      ] ]
    infixop5:
      [ [ [ "&" | "&&" ]{x} -> <:expr< $lid:x >> ] ]
    infixop6:
      [ [ [ "or" | "||" ]{x} -> <:expr< $lid:x >> ] ]
    sem_expr_for_list:
      [ [ expr{e}; ";";  SELF{el} -> fun acc -> <:expr< [ $e :: $(el acc) ] >>
        | expr{e}; ";" -> fun acc -> <:expr< [ $e :: $acc ] >>
        | expr{e} -> fun acc -> <:expr< [ $e :: $acc ] >>
      ] ]
    comma_expr:
      [ [ SELF{e1}; ",";  SELF{e2} -> <:expr< $e1, $e2 >>
        | `ANTIQUOT ("list" as n) s -> <:expr< $(anti:mk_anti ~c:"expr," n s) >>
        | expr Level "top"{e} -> e ] ]
    dummy:
      [ [ -> () ] ]
    sequence':
      [ [ -> fun e -> e
        | ";" -> fun e -> e
        | ";"; sequence{el} -> fun e -> <:expr< $e; $el >> ] ]
    sequence:
      [ [ "let"; rf = opt_rec; bi = binding; "in"; e = expr; k = sequence' ->
            k <:expr< let $rec:rf $bi in $e >>
        | "let"; rf = opt_rec; bi = binding; ";"; el = SELF ->
            <:expr< let $rec:rf $bi in $(Expr.mksequence _loc el) >>
        | "let"; "module"; m = a_UIDENT; mb = module_binding0; "in"; e = expr; k = sequence' ->
            k <:expr< let module $m = $mb in $e >>
        | "let"; "module"; m = a_UIDENT; mb = module_binding0; ";"; el = SELF ->
            <:expr< let module $m = $mb in $(Expr.mksequence _loc el) >>
        | "let"; "open"; i = module_longident; "in"; e = SELF ->
            <:expr< let open $id:i in $e >>
        | `ANTIQUOT ("list" as n) s -> <:expr< $(anti:mk_anti ~c:"expr;" n s) >>
        | e = expr; k = sequence' -> k e ] ]
    binding:
      [ LA
        [ `ANTIQUOT ("binding"|"list" as n) s ->
            <:binding< $(anti:mk_anti ~c:"binding" n s) >>
        | `ANTIQUOT (""|"anti" as n) s; "="; e = expr ->
            <:binding< $(anti:mk_anti ~c:"patt" n s) = $e >>
        | `ANTIQUOT (""|"anti" as n) s -> <:binding< $(anti:mk_anti ~c:"binding" n s) >>
        | b1 = SELF; "and"; b2 = SELF -> <:binding< $b1 and $b2 >>
        | b = let_binding -> b
      ] ]
    let_binding:
      [ [ p = ipatt; e = fun_binding -> <:binding< $p = $e >> ] ]
    fun_binding:
      [ RA
        [ TRY ["("; "type"]; i = a_LIDENT; ")"; e = SELF ->
            <:expr< fun (type $i) -> $e >>
        | p = TRY labeled_ipatt; e = SELF ->
            <:expr< fun $p -> $e >>
        | bi = cvalue_binding -> bi
      ] ]
    match_case:
      [ [ "["; l = LIST0 match_case0 SEP "|"; "]" -> Ast.mcOr_of_list l
        | p = ipatt; "->"; e = expr -> <:match_case< $p -> $e >> ] ]
    match_case0:
      [ [ `ANTIQUOT ("match_case"|"list" as n) s ->
            <:match_case< $(anti:mk_anti ~c:"match_case" n s) >>
        | `ANTIQUOT (""|"anti" as n) s ->
            <:match_case< $(anti:mk_anti ~c:"match_case" n s) >>
        | `ANTIQUOT (""|"anti" as n) s; "->"; e = expr ->
            <:match_case< $(anti:mk_anti ~c:"patt" n s) -> $e >>
        | `ANTIQUOT (""|"anti" as n) s; "when"; w = expr; "->"; e = expr ->
            <:match_case< $(anti:mk_anti ~c:"patt" n s) when $w -> $e >>
        | p = patt_as_patt_opt; w = opt_when_expr; "->"; e = expr ->
            <:match_case< $p when $w -> $e >>
      ] ]
    opt_when_expr:
      [ [ "when"; w = expr -> w
        | -> <:expr<>>
      ] ]
    patt_as_patt_opt:
      [ [ p1 = patt; "as"; p2 = patt -> <:patt< ($p1 as $p2) >>
        | p = patt -> p
      ] ]
    label_expr_list:
      [ [ b1 = label_expr; ";"; b2 = SELF -> <:rec_binding< $b1 ; $b2 >>
        | b1 = label_expr; ";"            -> b1
        | b1 = label_expr                 -> b1
      ] ]
    label_expr:
      [ [ `ANTIQUOT ("rec_binding" as n) s ->
            <:rec_binding< $(anti:mk_anti ~c:"rec_binding" n s) >>
        | `ANTIQUOT (""|"anti" as n) s ->
            <:rec_binding< $(anti:mk_anti ~c:"rec_binding" n s) >>
        | `ANTIQUOT (""|"anti" as n) s; "="; e = expr ->
            <:rec_binding< $(anti:mk_anti ~c:"ident" n s) = $e >>
        | `ANTIQUOT ("list" as n) s ->
            <:rec_binding< $(anti:mk_anti ~c:"rec_binding" n s) >>
        | i = label_longident; e = fun_binding -> <:rec_binding< $i = $e >>
        | i = label_longident ->
            <:rec_binding< $i = $(lid:Ident.to_lid i) >> ] ]
    fun_def:
      [ [ TRY ["("; "type"]; i = a_LIDENT; ")";
          e = fun_def_cont_no_when ->
            <:expr< fun (type $i) -> $e >>
        | p = TRY labeled_ipatt; (w, e) = fun_def_cont ->
            <:expr< fun [ $p when $w -> $e ] >> ] ]
    fun_def_cont:
      [ RA
        [ TRY ["("; "type"]; i = a_LIDENT; ")";
          e = fun_def_cont_no_when ->
            (<:expr<>>, <:expr< fun (type $i) -> $e >>)
        | p = TRY labeled_ipatt; (w,e) = SELF ->
            (<:expr<>>, <:expr< fun [ $p when $w -> $e ] >>)
        | "when"; w = expr; "->"; e = expr -> (w, e)
        | "->"; e = expr -> (<:expr<>>, e) ] ]
    fun_def_cont_no_when:
      [ RA
        [ TRY ["("; "type"]; i = a_LIDENT; ")";
          e = fun_def_cont_no_when -> <:expr< fun (type $i) -> $e >>
        | p = TRY labeled_ipatt; (w,e) = fun_def_cont ->
            <:expr< fun [ $p when $w -> $e ] >>
        | "->"; e = expr -> e ] ]
    patt:
      [ "|" LA
        [ p1 = SELF; "|"; p2 = SELF -> <:patt< $p1 | $p2 >> ]
      | ".." NA
        [ p1 = SELF; ".."; p2 = SELF -> <:patt< $p1 .. $p2 >> ]
      | "apply" LA
        [ p1 = SELF; p2 = SELF -> <:patt< $p1 $p2 >>
        | "lazy"; p = SELF -> <:patt< lazy $p >>  ]
      | "simple"
        [ `ANTIQUOT (""|"pat"|"anti" as n) s ->
            <:patt< $(anti:mk_anti ~c:"patt" n s) >>
        | `ANTIQUOT ("tup" as n) s ->
            <:patt< ($(tup:<:patt< $(anti:mk_anti ~c:"patt" n s) >> )) >>
        | `ANTIQUOT ("`bool" as n) s ->
            <:patt< $(id:<:ident< $(anti:mk_anti n s) >>) >>
        | i = ident -> <:patt< $id:i >>
        | s = a_INT -> <:patt< $int:s >>
        | s = a_INT32 -> <:patt< $int32:s >>
        | s = a_INT64 -> <:patt< $int64:s >>
        | s = a_NATIVEINT -> <:patt< $nativeint:s >>
        | s = a_FLOAT -> <:patt< $flo:s >>
        | s = a_STRING -> <:patt< $str:s >>
        | s = a_CHAR -> <:patt< $chr:s >>
        | "-"; s = a_INT -> <:patt< $(int:neg_string s) >>
        | "-"; s = a_INT32 -> <:patt< $(int32:neg_string s) >>
        | "-"; s = a_INT64 -> <:patt< $(int64:neg_string s) >>
        | "-"; s = a_NATIVEINT -> <:patt< $(nativeint:neg_string s) >>
        | "-"; s = a_FLOAT -> <:patt< $(flo:neg_string s) >>
        | "["; "]" -> <:patt< [] >>
        | "["; mk_list = sem_patt_for_list; "::"; last = patt; "]" ->
            mk_list last
        | "["; mk_list = sem_patt_for_list; "]" ->
            mk_list <:patt< [] >>
        | "[|"; "|]" -> <:patt< [| $(<:patt<>>) |] >>
        | "[|"; pl = sem_patt; "|]" -> <:patt< [| $pl |] >>
        | "{"; pl = label_patt_list; "}" -> <:patt< { $pl } >>
        | "("; ")" -> <:patt< () >>
        | "("; "module"; m = a_UIDENT; ")" -> <:patt< (module $m) >>
        | "("; "module"; m = a_UIDENT; ":"; pt = package_type; ")" ->
            <:patt< ((module $m) : (module $pt)) >>
        | "("; p = SELF; ")" -> p
        | "("; p = SELF; ":"; t = ctyp; ")" -> <:patt< ($p : $t) >>
        | "("; p = SELF; "as"; p2 = SELF; ")" -> <:patt< ($p as $p2) >>
        | "("; p = SELF; ","; pl = comma_patt; ")" -> <:patt< ($p, $pl) >>
        | "_" -> <:patt< _ >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.patt_tag
        | "`"; s = a_ident -> <:patt< ` $s >>
        | "#"; i = type_longident -> <:patt< # $i >>
        | `LABEL i; p = SELF -> <:patt< ~ $i : $p >>
        | "~"; `ANTIQUOT (""|"lid" as n) i; ":"; p = SELF ->
            <:patt< ~ $(mk_anti n i) : $p >>
        | "~"; `ANTIQUOT (""|"lid" as n) i -> <:patt< ~ $(mk_anti n i) >>
        | "~"; `LIDENT i -> <:patt< ~ $i >>
        (* | i = opt_label; "("; p = patt_tcon; ")" -> *)
            (* <:patt< ? $i$ : ($p$) >> *)
        | `OPTLABEL i; "("; p = patt_tcon; f = eq_expr; ")" -> f i p
        | "?"; `ANTIQUOT (""|"lid" as n) i; ":"; "("; p = patt_tcon; f = eq_expr; ")" ->
            f (mk_anti n i) p
        | "?"; `LIDENT i -> <:patt< ? $i >>
        | "?"; `ANTIQUOT (""|"lid" as n) i -> <:patt< ? $(mk_anti n i) >>
        | "?"; "("; p = patt_tcon; ")" ->
            <:patt< ? ($p) >>
        | "?"; "("; p = patt_tcon; "="; e = expr; ")" ->
            <:patt< ? ($p = $e) >> ] ]
    comma_patt:
      [ [ p1 = SELF; ","; p2 = SELF -> <:patt< $p1, $p2 >>
        | `ANTIQUOT ("list" as n) s -> <:patt< $(anti:mk_anti ~c:"patt," n s) >>
        | p = patt -> p ] ]
    sem_patt:
      [ LA
        [ p1 = patt; ";"; p2 = SELF -> <:patt< $p1; $p2 >>
        | `ANTIQUOT ("list" as n) s -> <:patt< $(anti:mk_anti ~c:"patt;" n s) >>
        | p = patt; ";" -> p
        | p = patt -> p ] ]
    sem_patt_for_list:
      [ [ p = patt; ";"; pl = SELF -> fun acc -> <:patt< [ $p :: $(pl acc) ] >>
        | p = patt; ";" -> fun acc -> <:patt< [ $p :: $acc ] >>
        | p = patt -> fun acc -> <:patt< [ $p :: $acc ] >>
      ] ]
    label_patt_list:
      [ [ p1 = label_patt; ";"; p2 = SELF -> <:patt< $p1 ; $p2 >>
        | p1 = label_patt; ";"; "_"       -> <:patt< $p1 ; _ >>
        | p1 = label_patt; ";"; "_"; ";"  -> <:patt< $p1 ; _ >>
        | p1 = label_patt; ";"            -> p1
        | p1 = label_patt                 -> p1
      ] ]
    label_patt:
      [ [ `ANTIQUOT (""|"pat"|"anti" as n) s ->
            <:patt< $(anti:mk_anti ~c:"patt" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.patt_tag
        | `ANTIQUOT ("list" as n) s ->
            <:patt< $(anti:mk_anti ~c:"patt;" n s) >>
        | i = label_longident; "="; p = patt -> <:patt< $i = $p >>
        | i = label_longident -> <:patt< $i = $(lid:Ident.to_lid i) >>
      ] ]
    ipatt:
      [ [ "{"; pl = label_ipatt_list; "}" -> <:patt< { $pl } >>
        | `ANTIQUOT (""|"pat"|"anti" as n) s ->
            <:patt< $(anti:mk_anti ~c:"patt" n s) >>
        | `ANTIQUOT ("tup" as n) s ->
            <:patt< ($(tup:<:patt< $(anti:mk_anti ~c:"patt" n s) >>)) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.patt_tag
        | "("; ")" -> <:patt< () >>
        | "("; "module"; m = a_UIDENT; ")" -> <:patt< (module $m) >>
        | "("; "module"; m = a_UIDENT; ":"; pt = package_type; ")" ->
            <:patt< ((module $m) : (module $pt)) >>
        | "("; p = SELF; ")" -> p
        | "("; p = SELF; ":"; t = ctyp; ")" -> <:patt< ($p : $t) >>
        | "("; p = SELF; "as"; p2 = SELF; ")" -> <:patt< ($p as $p2) >>
        | "("; p = SELF; ","; pl = comma_ipatt; ")" -> <:patt< ($p, $pl) >>
        | s = a_LIDENT -> <:patt< $lid:s >>
        | "_" -> <:patt< _ >> ] ]
    labeled_ipatt:
      [ [ p = ipatt -> p ] ]
    comma_ipatt:
      [ LA
        [ p1 = SELF; ","; p2 = SELF -> <:patt< $p1, $p2 >>
        | `ANTIQUOT ("list" as n) s -> <:patt< $(anti:mk_anti ~c:"patt," n s) >>
        | p = ipatt -> p ] ]
    label_ipatt_list:
      [ [ p1 = label_ipatt; ";"; p2 = SELF -> <:patt< $p1 ; $p2 >>
        | p1 = label_ipatt; ";"; "_"       -> <:patt< $p1 ; _ >>
        | p1 = label_ipatt; ";"; "_"; ";"  -> <:patt< $p1 ; _ >>
        | p1 = label_ipatt; ";"            -> p1
        | p1 = label_ipatt                 -> p1
      ] ]
    label_ipatt:
      [ [ `ANTIQUOT (""|"pat"|"anti" as n) s ->
            <:patt< $(anti:mk_anti ~c:"patt" n s) >>
        | `ANTIQUOT ("list" as n) s ->
            <:patt< $(anti:mk_anti ~c:"patt;" n s) >>
        | `QUOTATION x ->
            Quotation.expand _loc x DynAst.patt_tag
        | i = label_longident; "="; p = ipatt -> <:patt< $i = $p >>
      ] ]
    type_declaration:
      [ LA
        [ `ANTIQUOT (""|"typ"|"anti" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp" n s) >>
        | `ANTIQUOT ("list" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctypand" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.ctyp_tag
        | t1 = SELF; "and"; t2 = SELF -> <:ctyp< $t1 and $t2 >>
        | (n, tpl) = type_ident_and_parameters; tk = opt_eq_ctyp;
          cl = LIST0 constrain -> Ast.TyDcl _loc n tpl tk cl ] ]
    constrain:
      [ [ "constraint"; t1 = ctyp; "="; t2 = ctyp -> (t1, t2) ] ]
    opt_eq_ctyp:
      [ [ "="; tk = type_kind -> tk
        | -> <:ctyp<>> ] ]
    type_kind:
      [ [ t = ctyp -> t ] ]
    type_ident_and_parameters:
      [ [ i = a_LIDENT; tpl = LIST0 optional_type_parameter -> (i, tpl) ] ]
    type_longident_and_parameters:
      [ [ i = type_longident; tpl = type_parameters -> tpl <:ctyp< $id:i >>
      ] ]
    type_parameters:
      [ [ t1 = type_parameter; t2 = SELF ->
            fun acc -> t2 <:ctyp< $acc $t1 >>
        | t = type_parameter -> fun acc -> <:ctyp< $acc $t >>
        | -> fun t -> t
      ] ]
    type_parameter:
      [ [ `ANTIQUOT (""|"typ"|"anti" as n) s -> <:ctyp< $(anti:mk_anti n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.ctyp_tag
        | "'"; i = a_ident -> <:ctyp< '$lid:i >>
        | "+"; "'"; i = a_ident -> <:ctyp< +'$lid:i >>
        | "-"; "'"; i = a_ident -> <:ctyp< -'$lid:i >> ] ]
    optional_type_parameter:
      [ [ `ANTIQUOT (""|"typ"|"anti" as n) s -> <:ctyp< $(anti:mk_anti n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.ctyp_tag
        | "'"; i = a_ident -> <:ctyp< '$lid:i >>
        | "+"; "'"; i = a_ident -> <:ctyp< +'$lid:i >>
        | "-"; "'"; i = a_ident -> <:ctyp< -'$lid:i >>
        | "+"; "_" -> Ast.TyAnP _loc  
        | "-"; "_" -> Ast.TyAnM _loc  
        | "_" -> <:ctyp< _ >>  ] ]
    ctyp:
      [ "==" LA
        [ t1 = SELF; "=="; t2 = SELF -> <:ctyp< $t1 == $t2 >> ]
      | "private" NA
        [ "private"; t = ctyp Level "alias" -> <:ctyp< private $t >> ]
      | "alias" LA
        [ t1 = SELF; "as"; t2 = SELF ->
          <:ctyp< $t1 as $t2 >> ]
      | "forall" LA
        [ "!"; t1 = typevars; "."; t2 = ctyp ->
          <:ctyp< ! $t1 . $t2 >> ]
      | "arrow" RA
        [ t1 = SELF; "->"; t2 = SELF ->
          <:ctyp< $t1 -> $t2 >> ]
      | "label" NA
        [ "~"; i = a_LIDENT; ":"; t = SELF ->
          <:ctyp< ~ $i : $t >>
        | i = a_LABEL; t =  SELF  ->
          <:ctyp< ~ $i : $t >>
        | "?"; i = a_LIDENT; ":"; t = SELF ->
            <:ctyp< ? $i : $t >>
        | i = a_OPTLABEL; t = SELF ->
            <:ctyp< ? $i : $t >> ]
      | "apply" LA
        [ t1 = SELF; t2 = SELF ->
            let t = <:ctyp< $t1 $t2 >> in
            try <:ctyp< $(id:Ast.ident_of_ctyp t) >>
            with [ Invalid_argument _ -> t ] ]
      | "." LA
        [ t1 = SELF; "."; t2 = SELF ->
            try <:ctyp< $(id:Ast.ident_of_ctyp t1).$(id:Ast.ident_of_ctyp t2) >>
            with [ Invalid_argument s -> raise (Stream.Error s) ] ]
      | "simple"
        [ "'"; i = a_ident -> <:ctyp< '$i >>
        | "_" -> <:ctyp< _ >>
        | `ANTIQUOT (""|"typ"|"anti" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp" n s) >>
        | `ANTIQUOT ("tup" as n) s ->
            <:ctyp< ($(tup:<:ctyp< $(anti:mk_anti ~c:"ctyp" n s) >>)) >>
        | `ANTIQUOT ("id" as n) s ->
            <:ctyp< $(id:<:ident< $(anti:mk_anti ~c:"ident" n s) >>) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.ctyp_tag
        | i = a_LIDENT -> <:ctyp< $lid:i >>
        | i = a_UIDENT -> <:ctyp< $uid:i >>
        | "("; t = SELF; "*"; tl = star_ctyp; ")" ->
            <:ctyp< ( $t * $tl ) >>
        | "("; t = SELF; ")" -> t
        | "["; "]" -> <:ctyp< [ ] >>
        | "["; t = constructor_declarations; "]" -> <:ctyp< [ $t ] >>
        | "["; "="; rfl = row_field; "]" ->
            <:ctyp< [ = $rfl ] >>
        | "["; ">"; "]" -> <:ctyp< [ > $(<:ctyp<>>) ] >>
        | "["; ">"; rfl = row_field; "]" ->
            <:ctyp< [ > $rfl ] >>
        | "["; "<"; rfl = row_field; "]" ->
            <:ctyp< [ < $rfl ] >>
        | "["; "<"; rfl = row_field; ">"; ntl = name_tags; "]" ->
            <:ctyp< [ < $rfl > $ntl ] >>
        | "[<"; rfl = row_field; "]" ->
            <:ctyp< [ < $rfl ] >>
        | "[<"; rfl = row_field; ">"; ntl = name_tags; "]" ->
            <:ctyp< [ < $rfl > $ntl ] >>
        | "{"; t = label_declaration_list; "}" -> <:ctyp< { $t } >>
        | "#"; i = class_longident -> <:ctyp< # $i >>
        | "<"; t = opt_meth_list; ">" -> t
        | "("; "module"; p = package_type; ")" -> <:ctyp< (module $p) >>  ] ]
    star_ctyp:
      [ [ `ANTIQUOT (""|"typ" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp" n s) >>
        | `ANTIQUOT ("list" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp*" n s) >>
        | t1 = SELF; "*"; t2 = SELF ->
            <:ctyp< $t1 * $t2 >>
        | t = ctyp -> t  ] ]
    constructor_declarations:
      [ [ `ANTIQUOT (""|"typ" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp" n s) >>
        | `ANTIQUOT ("list" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp|" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.ctyp_tag
        | t1 = SELF; "|"; t2 = SELF ->
            <:ctyp< $t1 | $t2 >>
        | s = a_UIDENT; "of"; t = constructor_arg_list ->
            <:ctyp< $uid:s of $t >>
        | s = a_UIDENT; ":"; t = ctyp ->
            let (tl, rt) = Ctyp.to_generalized t in
            <:ctyp< $uid:s : ($(Ast.tyAnd_of_list tl) -> $rt) >>
        | s = a_UIDENT ->
	  <:ctyp< $uid:s >>  ] ]
    constructor_declaration:
      [ [ `ANTIQUOT (""|"typ" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.ctyp_tag
        | s = a_UIDENT; "of"; t = constructor_arg_list ->
            <:ctyp< $uid:s of $t >>
        | s = a_UIDENT ->
            <:ctyp< $uid:s >>
      ] ]
    constructor_arg_list:
      [ [ `ANTIQUOT ("list" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctypand" n s) >>
        | t1 = SELF; "and"; t2 = SELF -> <:ctyp< $t1 and $t2 >>
        | t = ctyp -> t
      ] ]
    label_declaration_list:
      [ [ t1 = label_declaration; ";"; t2 = SELF -> <:ctyp< $t1; $t2 >>
        | t1 = label_declaration; ";"            -> t1
        | t1 = label_declaration                 -> t1  ] ]
    label_declaration:
      [ [ `ANTIQUOT (""|"typ" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp" n s) >>
        | `ANTIQUOT ("list" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp;" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.ctyp_tag
        | s = a_LIDENT; ":"; t = poly_type ->
            <:ctyp< $lid:s : $t >>
        | s = a_LIDENT; ":"; "mutable"; t = poly_type ->
            <:ctyp< $lid:s : mutable $t >>  ] ]
    a_ident:
      [ [ i = a_LIDENT -> i
        | i = a_UIDENT -> i ] ]
    ident:
      [ [ `ANTIQUOT (""|"id"|"anti"|"list" as n) s -> (* id it self does not support ANTIQUOT "lid", however [a_UIDENT] supports*)
            <:ident< $(anti:mk_anti ~c:"ident" n s) >>
        | i = a_UIDENT -> <:ident< $uid:i >>
        | i = a_LIDENT -> <:ident< $lid:i >>
        | `ANTIQUOT (""|"id"|"anti"|"list" as n) s; "."; i = SELF ->
            <:ident< $(anti:mk_anti ~c:"ident" n s).$i >>
        | i = a_UIDENT; "."; j = SELF -> <:ident< $uid:i.$j >> ] ]
    module_longident:
      [ [ `ANTIQUOT (""|"id"|"anti"|"list" as n) s ->
            <:ident< $(anti:mk_anti ~c:"ident" n s) >>
        | m = a_UIDENT; "."; l = SELF -> <:ident< $uid:m.$l >>
        | i = a_UIDENT -> <:ident< $uid:i >> ] ]
    module_longident_with_app:
      [ "apply"
        [ i = SELF; j = SELF -> <:ident< $i $j >> ]
      | "."
        [ i = SELF; "."; j = SELF -> <:ident< $i.$j >> ]
      | "simple"
        [ `ANTIQUOT (""|"id"|"anti"|"list" as n) s ->
            <:ident< $(anti:mk_anti ~c:"ident" n s) >>
        | i = a_UIDENT -> <:ident< $uid:i >>
        | "("; i = SELF; ")" -> i ] ]
    module_longident_dot_lparen:
      [ [ `ANTIQUOT (""|"id"|"anti"|"list" as n) s; "."; "(" ->
            <:ident< $(anti:mk_anti ~c:"ident" n s) >>
        | m = a_UIDENT; "."; l = SELF -> <:ident< $uid:m.$l >>
        | i = a_UIDENT; "."; "(" -> <:ident< $uid:i >> ] ]
    type_longident:
      [ "apply"
        [ i = SELF; j = SELF -> <:ident< $i $j >> ]
      | "."
        [ i = SELF; "."; j = SELF -> <:ident< $i.$j >> ]
      | "simple"
        [ `ANTIQUOT (""|"id"|"anti"|"list" as n) s ->
            <:ident< $(anti:mk_anti ~c:"ident" n s) >>
        | i = a_LIDENT -> <:ident< $lid:i >>
        | i = a_UIDENT -> <:ident< $uid:i >>
        | "("; i = SELF; ")" -> i ] ]
    label_longident:
      [ [ `ANTIQUOT (""|"id"|"anti"|"list" as n) s ->
            <:ident< $(anti:mk_anti ~c:"ident" n s) >>
        | m = a_UIDENT; "."; l = SELF -> <:ident< $uid:m.$l >>
        | i = a_LIDENT -> <:ident< $lid:i >> ] ]
    class_type_longident:
      [ [ x = type_longident -> x ] ]
    val_longident:
      [ [ x = ident -> x ] ]
    class_longident:
      [ [ x = label_longident -> x ] ]
    class_declaration:
      [ LA
        [ c1 = SELF; "and"; c2 = SELF ->
            <:class_expr< $c1 and $c2 >>
        | `ANTIQUOT (""|"cdcl"|"anti"|"list" as n) s ->
            <:class_expr< $(anti:mk_anti ~c:"class_expr" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.class_expr_tag
        | ci = class_info_for_class_expr; ce = class_fun_binding ->
            <:class_expr< $ci = $ce >> ] ]
    class_fun_binding:
      [ [ "="; ce = class_expr -> ce
        | ":"; ct = class_type_plus; "="; ce = class_expr ->
            <:class_expr< ($ce : $ct) >>
        | p = labeled_ipatt; cfb = SELF ->
            <:class_expr< fun $p -> $cfb >>  ] ]
    class_info_for_class_type:
      [ [ mv = opt_virtual; (i, ot) = class_name_and_param ->
            <:class_type< $virtual:mv $lid:i [ $ot ] >>  ] ]
    class_info_for_class_expr:
      [ [ mv = opt_virtual; (i, ot) = class_name_and_param ->
            <:class_expr< $virtual:mv $lid:i [ $ot ] >>  ] ]
    class_name_and_param:
      [ [ i = a_LIDENT; "["; x = comma_type_parameter; "]" -> (i, x)
        | i = a_LIDENT -> (i, <:ctyp<>>)
      ] ]
    comma_type_parameter:
      [ [ t1 = SELF; ","; t2 = SELF -> <:ctyp< $t1, $t2 >>
        | `ANTIQUOT ("list" as n) s -> <:ctyp< $(anti:mk_anti ~c:"ctyp," n s) >>
        | t = type_parameter -> t  ] ]
    opt_comma_ctyp:
      [ [ "["; x = comma_ctyp; "]" -> x
        | -> <:ctyp<>>  ] ]
    comma_ctyp:
      [ [ t1 = SELF; ","; t2 = SELF -> <:ctyp< $t1, $t2 >>
        | `ANTIQUOT ("list" as n) s -> <:ctyp< $(anti:mk_anti ~c:"ctyp," n s) >>
        | t = ctyp -> t  ] ]
    class_fun_def:
      [ [ p = labeled_ipatt; ce = SELF -> <:class_expr< fun $p -> $ce >>
        | "->"; ce = class_expr -> ce ] ]
    class_expr:
      [ "top"
        [ "fun"; p = labeled_ipatt; ce = class_fun_def ->
            <:class_expr< fun $p -> $ce >>
        | "let"; rf = opt_rec; bi = binding; "in"; ce = SELF ->
            <:class_expr< let $rec:rf $bi in $ce >> ]
      | "apply" NA
        [ ce = SELF; e = expr Level "label" ->
            <:class_expr< $ce $e >> ]
      | "simple"
        [ `ANTIQUOT (""|"cexp"|"anti" as n) s ->
            <:class_expr< $(anti:mk_anti ~c:"class_expr" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.class_expr_tag
        | ce = class_longident_and_param -> ce
        | "object"; csp = opt_class_self_patt; cst = class_structure; "end" ->
            <:class_expr< object ($csp) $cst end >>
        | "("; ce = SELF; ":"; ct = class_type; ")" ->
            <:class_expr< ($ce : $ct) >>
        | "("; ce = SELF; ")" -> ce ] ]
    class_longident_and_param:
      [ [ ci = class_longident; "["; t = comma_ctyp; "]" ->
          <:class_expr< $id:ci [ $t ] >>
        | ci = class_longident -> <:class_expr< $id:ci >>  ] ]
    class_structure:
      [ [ `ANTIQUOT (""|"cst"|"anti"|"list" as n) s ->
            <:class_str_item< $(anti:mk_anti ~c:"class_str_item" n s) >>
        | `ANTIQUOT (""|"cst"|"anti"|"list" as n) s; semi; cst = SELF ->
            <:class_str_item< $(anti:mk_anti ~c:"class_str_item" n s); $cst >>
        | l = LIST0 [ cst = class_str_item; semi -> cst ] -> Ast.crSem_of_list l  ] ]
    opt_class_self_patt:
      [ [ "("; p = patt; ")" -> p
        | "("; p = patt; ":"; t = ctyp; ")" -> <:patt< ($p : $t) >>
        | -> <:patt<>> ] ]
    class_str_item:
      [ LA
        [ `ANTIQUOT (""|"cst"|"anti"|"list" as n) s ->
            <:class_str_item< $(anti:mk_anti ~c:"class_str_item" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.class_str_item_tag
        | "inherit"; o = opt_override; ce = class_expr; pb = opt_as_lident ->
            <:class_str_item< inherit $override:o $ce as $pb >>
        | o = value_val_opt_override; mf = opt_mutable; lab = label; e = cvalue_binding
          ->
            <:class_str_item< val $override:o $mutable:mf $lab = $e >>
        | o = value_val_opt_override; mf = opt_mutable; "virtual"; l = label; ":";
              t = poly_type ->
            if o <> <:override_flag<>> then
              raise (Stream.Error "override (!) is incompatible with virtual")
            else
              <:class_str_item< val virtual $mutable:mf $l : $t >>
        | o = value_val_opt_override; "virtual"; mf = opt_mutable; l = label; ":";
                t = poly_type ->
            if o <> <:override_flag<>> then
              raise (Stream.Error "override (!) is incompatible with virtual")
            else
              <:class_str_item< val virtual $mutable:mf $l : $t >>
        | o = method_opt_override; "virtual"; pf = opt_private; l = label; ":";
                t = poly_type ->
            if o <> <:override_flag<>> then
              raise (Stream.Error "override (!) is incompatible with virtual")
            else
              <:class_str_item< method virtual $private:pf $l : $t >>
        | o = method_opt_override; pf = opt_private; l = label; topt = opt_polyt;
                e = fun_binding ->
            <:class_str_item< method $override:o $private:pf $l : $topt = $e >>
        | o = method_opt_override; pf = opt_private; "virtual"; l = label; ":";
             t = poly_type ->
            if o <> <:override_flag<>> then
              raise (Stream.Error "override (!) is incompatible with virtual")
            else
              <:class_str_item< method virtual $private:pf $l : $t >>
        | type_constraint; t1 = ctyp; "="; t2 = ctyp ->
            <:class_str_item< type $t1 = $t2 >>
        | "initializer"; se = expr -> <:class_str_item< initializer $se >> ] ]
    method_opt_override:
      [ [ "method"; "!" -> <:override_flag< ! >>
        | "method"; `ANTIQUOT (("!"|"override"|"anti") as n) s -> Ast.OvAnt (mk_anti n s)
        | "method" -> <:override_flag<>>  ] ]
    value_val_opt_override:
      [ [ "val"; "!" -> <:override_flag< ! >>
        | "val"; `ANTIQUOT (("!"|"override"|"anti") as n) s -> Ast.OvAnt (mk_anti n s)
        | "val" -> <:override_flag<>>   ] ]
    opt_as_lident:
      [ [ "as"; i = a_LIDENT -> i
        | -> ""  ] ]
    opt_polyt:
      [ [ ":"; t = poly_type -> t
        | -> <:ctyp<>> ] ]
    cvalue_binding:
      [ [ "="; e = expr -> e
        | ":"; "type"; t1 = unquoted_typevars; "." ; t2 = ctyp ; "="; e = expr -> 
	(* let u = Ast.TyTypePol _loc t1 t2 in *)
         let u = <:ctyp< ! $t1 . $t2 >> in   
         <:expr< ($e : $u) >>
        | ":"; t = poly_type; "="; e = expr -> <:expr< ($e : $t) >>
        | ":"; t = poly_type; ":>"; t2 = ctyp; "="; e = expr ->
            match t with
            [ <:ctyp< ! $_ . $_ >> -> raise (Stream.Error "unexpected polytype here")
            | _ -> <:expr< ($e : $t :> $t2) >> ]
        | ":>"; t = ctyp; "="; e = expr -> <:expr< ($e :> $t) >> ] ]
    label:
      [ [ i = a_LIDENT -> i ] ]
    class_type:
      [ [ `ANTIQUOT (""|"ctyp"|"anti" as n) s ->
            <:class_type< $(anti:mk_anti ~c:"class_type" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.class_type_tag
        | ct = class_type_longident_and_param -> ct
        | "object"; cst = opt_class_self_type; csg = class_signature; "end" ->
            <:class_type< object ($cst) $csg end >> ] ]
    class_type_longident_and_param:
      [ [ i = class_type_longident; "["; t = comma_ctyp; "]" ->
            <:class_type< $id:i [ $t ] >>
        | i = class_type_longident -> <:class_type< $id:i >> ] ]
    class_type_plus:
      [ [ "["; t = ctyp; "]"; "->"; ct = SELF ->
        <:class_type< [ $t ] -> $ct >>
        | ct = class_type -> ct ] ]
    opt_class_self_type:
      [ [ "("; t = ctyp; ")" -> t
        | -> <:ctyp<>> ] ]
    class_signature:
      [ [ `ANTIQUOT (""|"csg"|"anti"|"list" as n) s ->
            <:class_sig_item< $(anti:mk_anti ~c:"class_sig_item" n s) >>
        | `ANTIQUOT (""|"csg"|"anti"|"list" as n) s; semi; csg = SELF ->
            <:class_sig_item< $(anti:mk_anti ~c:"class_sig_item" n s); $csg >>
        | l = LIST0 [ csg = class_sig_item; semi -> csg ] ->
            Ast.cgSem_of_list l  ] ]
    class_sig_item:
      [ [ `ANTIQUOT (""|"csg"|"anti"|"list" as n) s ->
            <:class_sig_item< $(anti:mk_anti ~c:"class_sig_item" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.class_sig_item_tag
        | "inherit"; cs = class_type ->
            <:class_sig_item< inherit $cs >>
        | "val"; mf = opt_mutable; mv = opt_virtual;
          l = label; ":"; t = ctyp ->
            <:class_sig_item< val $mutable:mf $virtual:mv $l : $t >>
        | "method"; "virtual"; pf = opt_private; l = label; ":"; t = poly_type ->
            <:class_sig_item< method virtual $private:pf $l : $t >>
        | "method"; pf = opt_private; l = label; ":"; t = poly_type ->
            <:class_sig_item< method $private:pf $l : $t >>
        | "method"; pf = opt_private; "virtual"; l = label; ":"; t = poly_type ->
            <:class_sig_item< method virtual $private:pf $l : $t >>
        | type_constraint; t1 = ctyp; "="; t2 = ctyp ->
            <:class_sig_item< type $t1 = $t2 >> ] ]
    type_constraint:
      [ [ "type" | "constraint" -> () ] ]
    class_description:
      [ [ cd1 = SELF; "and"; cd2 = SELF ->
            <:class_type< $cd1 and $cd2 >>
        | `ANTIQUOT (""|"typ"|"anti"|"list" as n) s ->
            <:class_type< $(anti:mk_anti ~c:"class_type" n s) >>
        | `QUOTATION x ->
            Quotation.expand _loc x DynAst.class_type_tag
        | ci = class_info_for_class_type; ":"; ct = class_type_plus ->
            <:class_type< $ci : $ct >>  ] ]
    class_type_declaration:
      [ LA
        [ cd1 = SELF; "and"; cd2 = SELF ->
          <:class_type< $cd1 and $cd2 >>
        | `ANTIQUOT (""|"typ"|"anti"|"list" as n) s ->
            <:class_type< $(anti:mk_anti ~c:"class_type" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.class_type_tag
        | ci = class_info_for_class_type; "="; ct = class_type ->
            <:class_type< $ci = $ct >> ] ]
    field_expr_list:
      [ [ b1 = field_expr; ";"; b2 = SELF -> <:rec_binding< $b1 ; $b2 >>
        | b1 = field_expr; ";"            -> b1
        | b1 = field_expr                 -> b1
      ] ]
    field_expr:
      [ [ `ANTIQUOT (""|"bi"|"anti" as n) s ->
            <:rec_binding< $(anti:mk_anti ~c:"rec_binding" n s) >>
        | `ANTIQUOT ("list" as n) s ->
            <:rec_binding< $(anti:mk_anti ~c:"rec_binding" n s) >>
        | l = label; "="; e = expr Level "top" ->
            <:rec_binding< $lid:l = $e >> ] ]
    meth_list:
      [ [ m = meth_decl; ";"; (ml, v) = SELF  -> (<:ctyp< $m; $ml >>, v)
        | m = meth_decl; ";"; v = opt_dot_dot -> (m, v)
        | m = meth_decl; v = opt_dot_dot      -> (m, v)
      ] ]
    meth_decl:
      [ [ `ANTIQUOT (""|"typ" as n) s        -> <:ctyp< $(anti:mk_anti ~c:"ctyp" n s) >>
        | `ANTIQUOT ("list" as n) s          -> <:ctyp< $(anti:mk_anti ~c:"ctyp;" n s) >>
        | `QUOTATION x                       -> Quotation.expand _loc x DynAst.ctyp_tag
        | lab = a_LIDENT; ":"; t = poly_type -> <:ctyp< $lid:lab : $t >> ] ]
    opt_meth_list:
      [ [ (ml, v) = meth_list -> <:ctyp< < $ml $(..:v) > >>
        | v = opt_dot_dot     -> <:ctyp< < $(..:v) > >>
      ] ]
    poly_type:
      [ [ t = ctyp -> t ] ]
    package_type:
      [ [ p = module_type -> p ] ]
    typevars:
      [ LA
        [ t1 = SELF; t2 = SELF -> <:ctyp< $t1 $t2 >>
        | `ANTIQUOT (""|"typ" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.ctyp_tag
        | "'"; i = a_ident -> <:ctyp< '$lid:i >> ] ]
    unquoted_typevars:
      [ LA
        [ t1 = SELF; t2 = SELF -> <:ctyp< $t1 $t2 >>
        | `ANTIQUOT (""|"typ" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp" n s) >>
        | `QUOTATION x -> Quotation.expand _loc x DynAst.ctyp_tag
        | i = a_ident -> <:ctyp< $lid:i >>
      ] ]
    row_field:
      [ [ `ANTIQUOT (""|"typ" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp" n s) >>
        | `ANTIQUOT ("list" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp|" n s) >>
        | t1 = SELF; "|"; t2 = SELF -> <:ctyp< $t1 | $t2 >>
        | "`"; i = a_ident -> <:ctyp< `$i >>
        | "`"; i = a_ident; "of"; "&"; t = amp_ctyp -> <:ctyp< `$i of & $t >>
        | "`"; i = a_ident; "of"; t = amp_ctyp -> <:ctyp< `$i of $t >>
        | t = ctyp -> t ] ]
    amp_ctyp:
      [ [ t1 = SELF; "&"; t2 = SELF -> <:ctyp< $t1 & $t2 >>
        | `ANTIQUOT ("list" as n) s -> <:ctyp< $(anti:mk_anti ~c:"ctyp&" n s) >>
        | t = ctyp -> t
      ] ]
    name_tags:
      [ [ `ANTIQUOT (""|"typ" as n) s ->
            <:ctyp< $(anti:mk_anti ~c:"ctyp" n s) >>
        | t1 = SELF; t2 = SELF -> <:ctyp< $t1 $t2 >>
        | "`"; i = a_ident -> <:ctyp< `$i >>  ] ]
    eq_expr:
      [ [ "="; e = expr -> fun i p -> <:patt< ? $i : ($p = $e) >>
        | -> fun i p -> <:patt< ? $i : ($p) >> ] ]
    patt_tcon:
      [ [ p = patt; ":"; t = ctyp -> <:patt< ($p : $t) >>
        | p = patt -> p ] ]
    ipatt:
      [ [ `LABEL i; p = SELF -> <:patt< ~ $i : $p >>
        | "~"; `ANTIQUOT (""|"lid" as n) i; ":"; p = SELF ->
            <:patt< ~ $(mk_anti n i) : $p >>
        | "~"; `ANTIQUOT (""|"lid" as n) i -> <:patt< ~ $(mk_anti n i) >>
        | "~"; `LIDENT i -> <:patt< ~ $i >>
        (* | i = opt_label; "("; p = ipatt_tcon; ")" ->
            <:patt< ? $i$ : ($p$) >>
        | i = opt_label; "("; p = ipatt_tcon; "="; e = expr; ")" ->
            <:patt< ? $i$ : ($p$ = $e$) >>                             *)
        | `OPTLABEL i; "("; p = ipatt_tcon; f = eq_expr; ")" -> f i p
        | "?"; `ANTIQUOT (""|"lid" as n) i; ":"; "("; p = ipatt_tcon;
          f = eq_expr; ")" -> f (mk_anti n i) p
        | "?"; `LIDENT i -> <:patt< ? $i >>
        | "?"; `ANTIQUOT (""|"lid" as n) i -> <:patt< ? $(mk_anti n i) >>
        | "?"; "("; p = ipatt_tcon; ")" ->
            <:patt< ? ($p) >>
        | "?"; "("; p = ipatt_tcon; "="; e = expr; ")" ->
            <:patt< ? ($p = $e) >> ] ]
    ipatt_tcon:
      [ [ p = ipatt; ":"; t = ctyp -> <:patt< ($p : $t) >>
        | p = ipatt -> p ] ]
    direction_flag:
      [ [ "to" -> <:direction_flag< to >>
        | "downto" -> <:direction_flag< downto >>
        | `ANTIQUOT ("to"|"anti" as n) s -> Ast.DiAnt (mk_anti n s) ] ]
    opt_private:
      [ [ "private" -> <:private_flag< private >>
        | `ANTIQUOT ("private"|"anti" as n) s -> Ast.PrAnt (mk_anti n s)
        | -> <:private_flag<>>  ] ]
    opt_mutable:
      [ [ "mutable" -> <:mutable_flag< mutable >>
        | `ANTIQUOT ("mutable"|"anti" as n) s -> Ast.MuAnt (mk_anti n s)
        | -> <:mutable_flag<>>  ] ]
    opt_virtual:
      [ [ "virtual" -> <:virtual_flag< virtual >>
        | `ANTIQUOT ("virtual"|"anti" as n) s -> Ast.ViAnt (mk_anti n s)
        | -> <:virtual_flag<>>  ] ]
    opt_dot_dot:
      [ [ ".." -> <:row_var_flag< .. >>
        | `ANTIQUOT (".."|"anti" as n) s -> Ast.RvAnt (mk_anti n s)
        | -> <:row_var_flag<>>  ] ]
    opt_rec:
      [ [ "rec" -> <:rec_flag< rec >>
        | `ANTIQUOT ("rec"|"anti" as n) s -> Ast.ReAnt (mk_anti n s)
        | -> <:rec_flag<>> ] ]
    opt_override:
      [ [ "!" -> <:override_flag< ! >>
        | `ANTIQUOT (("!"|"override"|"anti") as n) s -> Ast.OvAnt (mk_anti n s)
        | -> <:override_flag<>> ] ]
    opt_expr:
      [ [ e = expr -> e
        | -> <:expr<>> ] ]
    interf:
      [ [ "#"; n = a_LIDENT; dp = opt_expr; semi ->
            ([ <:sig_item< # $n $dp >> ], stopped_at _loc)
          (* Ast.SgDir(_loc,n,dp), stopped is of type FanLoc.t option *)
        | si = sig_item; semi; (sil, stopped) = SELF -> ([si :: sil], stopped)
        | `EOI -> ([], None) ] ]
    sig_items:
      [ [ `ANTIQUOT (""|"sigi"|"anti"|"list" as n) s ->
            <:sig_item< $(anti:mk_anti n ~c:"sig_item" s) >>
        | `ANTIQUOT (""|"sigi"|"anti"|"list" as n) s; semi; sg = SELF ->
            <:sig_item< $(anti:mk_anti n ~c:"sig_item" s); $sg >> 
        | l = LIST0 [ sg = sig_item; semi -> sg ] -> Ast.sgSem_of_list l  ] ]
    implem:
      [ [ "#"; n = a_LIDENT; dp = opt_expr; semi ->
            ([ <:str_item< # $n $dp >> ], stopped_at _loc)
        | si = str_item; semi; (sil, stopped) = SELF -> ([si :: sil], stopped)
        | `EOI -> ([], None) ] ]
    str_items:
      [ [ `ANTIQUOT (""|"stri"|"anti"|"list" as n) s ->
            <:str_item< $(anti:mk_anti n ~c:"str_item" s) >>
        | `ANTIQUOT (""|"stri"|"anti"|"list" as n) s; semi; st = SELF ->
            <:str_item< $(anti:mk_anti n ~c:"str_item" s); $st >>
        | l = LIST0 [ st = str_item; semi -> st ] -> Ast.stSem_of_list l  ] ]
    top_phrase:
      [ [ ph = phrase -> Some ph
        | `EOI -> None ] ]
    use_file:
      [ [ "#"; n = a_LIDENT; dp = opt_expr; semi ->
            ([ <:str_item< # $n $dp >> ], stopped_at _loc)
        | si = str_item; semi; (sil, stopped) = SELF -> ([si :: sil], stopped)
        | `EOI -> ([], None) ] ]
    phrase:
      [ [ "#"; n = a_LIDENT; dp = opt_expr; semi ->
            <:str_item< # $n $dp >>
        | st = str_item; semi -> st  ] ]
    a_INT:
      [ [ `ANTIQUOT (""|"int"|"`int" as n) s -> mk_anti n s
        | `INT _ s -> s ] ]
    a_INT32:
      [ [ `ANTIQUOT (""|"int32"|"`int32" as n) s -> mk_anti n s
        | `INT32 _ s -> s ] ]
    a_INT64:
      [ [ `ANTIQUOT (""|"int64"|"`int64" as n) s -> mk_anti n s
        | `INT64 _ s -> s ] ]
    a_NATIVEINT:
      [ [ `ANTIQUOT (""|"nativeint"|"`nativeint" as n) s -> mk_anti n s
        | `NATIVEINT _ s -> s ] ]
    a_FLOAT:
      [ [ `ANTIQUOT (""|"flo"|"`flo" as n) s -> mk_anti n s
        | `FLOAT _ s -> s ] ]
    a_CHAR:
      [ [ `ANTIQUOT (""|"chr"|"`chr" as n) s -> mk_anti n s
        | `CHAR _ s -> s ] ]
    a_UIDENT:
      [ [ `ANTIQUOT (""|"uid" as n) s -> mk_anti n s
        | `UIDENT s -> s ] ]
    a_LIDENT:
      [ [ `ANTIQUOT (""|"lid" as n) s -> mk_anti n s
        | `LIDENT s -> s ] ]
    a_LABEL:
      [ [ "~"; `ANTIQUOT ("" as n) s; ":" -> mk_anti n s
        | `LABEL s -> s ] ]
    a_OPTLABEL:
      [ [ "?"; `ANTIQUOT ("" as n) s; ":" -> mk_anti n s
        | `OPTLABEL s -> s ] ]
    a_STRING:
      [ [ `ANTIQUOT (""|"str"|"`str" as n) s -> mk_anti n s
        | `STRING _ s -> s ] ]
    string_list:
      [ [ `ANTIQUOT (""|"str_list") s -> Ast.LAnt (mk_anti "str_list" s)
        | `STRING _ x; xs = string_list -> Ast.LCons x xs
        | `STRING _ x -> Ast.LCons x Ast.LNil ] ]
    semi:
      [ [ ";" -> () ] ] 
    expr_quot:
      [ [ e1 = expr; ","; e2 = comma_expr -> <:expr< $e1, $e2 >>
        | e1 = expr; ";"; e2 = sem_expr -> <:expr< $e1; $e2 >>
        | e = expr -> e
        | -> <:expr<>> ] ]
    patt_quot:
      [ [ x = patt; ","; y = comma_patt -> <:patt< $x, $y >>
        | x = patt; ";"; y = sem_patt -> <:patt< $x; $y >>
        | x = patt; "="; y = patt ->
            let i =
              match x with
              [ <:patt@loc< $anti:s >> -> <:ident@loc< $anti:s >>
              | p -> Ast.ident_of_patt p ]
            in
            <:patt< $i = $y >>
        | x = patt -> x
        | -> <:patt<>>
      ] ]
    ctyp_quot:
      [ [ x = more_ctyp; ","; y = comma_ctyp -> <:ctyp< $x, $y >>
        | x = more_ctyp; ";"; y = label_declaration_list -> <:ctyp< $x; $y >>
        | x = more_ctyp; "|"; y = constructor_declarations -> <:ctyp< $x | $y >>
        | x = more_ctyp; "of"; y = constructor_arg_list -> <:ctyp< $x of $y >>
        | x = more_ctyp; "of"; y = constructor_arg_list; "|"; z = constructor_declarations ->
            <:ctyp< $(<:ctyp< $x of $y >> ) | $z >>
        | x = more_ctyp; "of"; "&"; y = amp_ctyp -> <:ctyp< $x of & $y >>
        | x = more_ctyp; "of"; "&"; y = amp_ctyp; "|"; z = row_field ->
            <:ctyp< $(<:ctyp< $x of & $y >> ) | $z >>
        | x = more_ctyp; ":"; y = more_ctyp -> <:ctyp< $x : $y >>
        | x = more_ctyp; ":"; y = more_ctyp; ";"; z = label_declaration_list ->
            <:ctyp< $(<:ctyp< $x : $y >> ) ; $z >>
        | x = more_ctyp; "*"; y = star_ctyp -> <:ctyp< $x * $y >>
        | x = more_ctyp; "&"; y = amp_ctyp -> <:ctyp< $x & $y >>
        | x = more_ctyp; "and"; y = constructor_arg_list -> <:ctyp< $x and $y >>
        | x = more_ctyp -> x
        | -> <:ctyp<>>  ] ]
    more_ctyp:
      [ [ "mutable"; x = SELF -> <:ctyp< mutable $x >>
        | "`"; x = a_ident -> <:ctyp< `$x >>
        | x = ctyp -> x
        | x = type_parameter -> x
      ] ]
    str_item_quot:
      [ [ "#"; n = a_LIDENT; dp = opt_expr -> <:str_item< # $n $dp >>
        | st1 = str_item; semi; st2 = SELF ->
            match st2 with
            [ <:str_item<>> -> st1
            | _ -> <:str_item< $st1; $st2 >> ]
        | st = str_item -> st
        | -> <:str_item<>> ] ]
    sig_item_quot:
      [ [ "#"; n = a_LIDENT; dp = opt_expr -> <:sig_item< # $n $dp >>
        | sg1 = sig_item; semi; sg2 = SELF ->
            match sg2 with
            [ <:sig_item<>> -> sg1
            | _ -> <:sig_item< $sg1; $sg2 >> ]
        | sg = sig_item -> sg
        | -> <:sig_item<>> ] ]
    module_type_quot:
      [ [ x = module_type -> x
        | -> <:module_type<>> ] ]
    module_expr_quot:
      [ [ x = module_expr -> x
        | -> <:module_expr<>> ] ]
    match_case_quot:
      [ [ x = LIST0 match_case0 SEP "|" -> <:match_case< $list:x >>
        | -> <:match_case<>> ] ]
    binding_quot:
      [ [ x = binding -> x
        | -> <:binding<>> ] ]
    rec_binding_quot:
      [ [ x = label_expr_list -> x
        | -> <:rec_binding<>> ] ]
    module_binding_quot:
      [ [ b1 = SELF; "and"; b2 = SELF ->
            <:module_binding< $b1 and $b2 >>
        | `ANTIQUOT ("module_binding"|"anti" as n) s ->
            <:module_binding< $(anti:mk_anti ~c:"module_binding" n s) >>
        | `ANTIQUOT ("" as n) s ->
            <:module_binding< $(anti:mk_anti ~c:"module_binding" n s) >>
        | `ANTIQUOT ("" as n) m; ":"; mt = module_type ->
            <:module_binding< $(mk_anti n m) : $mt >>
        | `ANTIQUOT ("" as n) m; ":"; mt = module_type; "="; me = module_expr ->
            <:module_binding< $(mk_anti n m) : $mt = $me >>
        | m = a_UIDENT; ":"; mt = module_type ->
            <:module_binding< $m : $mt >>
        | m = a_UIDENT; ":"; mt = module_type; "="; me = module_expr ->
            <:module_binding< $m : $mt = $me >>
        | -> <:module_binding<>> ] ]
    ident_quot:
      [ "apply"
        [ i = SELF; j = SELF -> <:ident< $i $j >> ]
      | "."
        [ i = SELF; "."; j = SELF -> <:ident< $i.$j >> ]
      | "simple"
        [ `ANTIQUOT (""|"id"|"anti"|"list" as n) s ->
            <:ident< $(anti:mk_anti ~c:"ident" n s) >>
        | i = a_UIDENT -> <:ident< $uid:i >>
        | i = a_LIDENT -> <:ident< $lid:i >>
        | `ANTIQUOT (""|"id"|"anti"|"list" as n) s; "."; i = SELF ->
            <:ident< $(anti:mk_anti ~c:"ident" n s).$i >>
        | "("; i = SELF; ")" -> i  ] ]
    class_expr_quot:
      [ [ ce1 = SELF; "and"; ce2 = SELF -> <:class_expr< $ce1 and $ce2 >>
        | ce1 = SELF; "="; ce2 = SELF -> <:class_expr< $ce1 = $ce2 >>
        | "virtual"; (i, ot) = class_name_and_param ->
            <:class_expr< virtual $lid:i [ $ot ] >>
        | `ANTIQUOT ("virtual" as n) s; i = ident; ot = opt_comma_ctyp ->
            let anti = Ast.ViAnt (mk_anti ~c:"class_expr" n s) in
            <:class_expr< $virtual:anti $id:i [ $ot ] >>
        | x = class_expr -> x
        | -> <:class_expr<>> ] ]
    class_type_quot:
      [ [ ct1 = SELF; "and"; ct2 = SELF -> <:class_type< $ct1 and $ct2 >>
        | ct1 = SELF; "="; ct2 = SELF -> <:class_type< $ct1 = $ct2 >>
        | ct1 = SELF; ":"; ct2 = SELF -> <:class_type< $ct1 : $ct2 >>
        | "virtual"; (i, ot) = class_name_and_param ->
            <:class_type< virtual $lid:i [ $ot ] >>
        | `ANTIQUOT ("virtual" as n) s; i = ident; ot = opt_comma_ctyp ->
            let anti = Ast.ViAnt (mk_anti ~c:"class_type" n s) in
            <:class_type< $virtual:anti $id:i [ $ot ] >>
        | x = class_type_plus -> x
        | -> <:class_type<>>   ] ]
    class_str_item_quot:
      [ [ x1 = class_str_item; semi; x2 = SELF ->
          match x2 with
          [ <:class_str_item<>> -> x1
          | _ -> <:class_str_item< $x1; $x2 >> ]
        | x = class_str_item -> x
        | -> <:class_str_item<>> ] ]
    class_sig_item_quot:
      [ [ x1 = class_sig_item; semi; x2 = SELF ->
          match x2 with
          [ <:class_sig_item<>> -> x1
          | _ -> <:class_sig_item< $x1; $x2 >> ]
        | x = class_sig_item -> x
        | -> <:class_sig_item<>> ] ]
    with_constr_quot:
      [ [ x = with_constr -> x
        | -> <:with_constr<>> ] ]
    rec_flag_quot: [ [ x = opt_rec -> x ] ]
    direction_flag_quot: [ [ x = direction_flag -> x ] ]
    mutable_flag_quot: [ [ x = opt_mutable -> x ] ]
    private_flag_quot: [ [ x = opt_private -> x ] ]
    virtual_flag_quot: [ [ x = opt_virtual -> x ] ]
    row_var_flag_quot: [ [ x = opt_dot_dot -> x ] ]
    override_flag_quot: [ [ x = opt_override -> x ] ]
    patt_eoi:
      [ [ x = patt; `EOI -> x ] ]
    expr_eoi:
      [ [ x = expr; `EOI -> x ] ]
  END;

end;

module IdRevisedParserParser : Sig.Id = struct
  let name = "Camlp4OCamlRevisedParserParser";
  let version = Sys.ocaml_version;
end;

module MakeRevisedParserParser (Syntax : Sig.Camlp4Syntax) = struct
  include Syntax;
  module Ast = Camlp4Ast;
  type spat_comp =
    [ SpTrm of FanLoc.t and Ast.patt and option Ast.expr
    | SpNtr of FanLoc.t and Ast.patt and Ast.expr
    | SpStr of FanLoc.t and Ast.patt ]
  ;
  type sexp_comp =
    [ SeTrm of FanLoc.t and Ast.expr | SeNtr of FanLoc.t and Ast.expr ]
  ;

  let stream_expr = Gram.mk "stream_expr";
  let stream_begin = Gram.mk "stream_begin";
  let stream_end = Gram.mk "stream_end";
  let stream_quot = Gram.mk "stream_quot";
  let parser_case = Gram.mk "parser_case";
  let parser_case_list = Gram.mk "parser_case_list";

  let strm_n = "__strm";
  let peek_fun _loc = <:expr< Stream.peek >>;
  let junk_fun _loc = <:expr< Stream.junk >>;

  let rec pattern_eq_expression p e =  match (p, e) with
    [ (<:patt< $lid:a >>, <:expr< $lid:b >>) -> a = b
    | (<:patt< $uid:a >>, <:expr< $uid:b >>) -> a = b
    | (<:patt< $p1 $p2 >>, <:expr< $e1 $e2 >>) ->
        pattern_eq_expression p1 e1 && pattern_eq_expression p2 e2
    | _ -> False ] ;

  let is_raise e =
    match e with
    [ <:expr< raise $_ >> -> True
    | _ -> False ] ;

  let is_raise_failure e =
    match e with
    [ <:expr< raise Stream.Failure >> -> True
    | _ -> False ] ;

  let rec handle_failure e =  match e with
    [ <:expr< try $_ with [ Stream.Failure -> $e] >> ->
        handle_failure e
    | <:expr< match $me with [ $a ] >> ->
        let rec match_case_handle_failure = fun
          [ <:match_case< $a1 | $a2 >> ->
              match_case_handle_failure a1 && match_case_handle_failure a2
          | <:match_case< $pat:_ -> $e >> -> handle_failure e
          | _ -> False ]
        in handle_failure me && match_case_handle_failure a
    | <:expr< let $bi in $e >> ->
        let rec binding_handle_failure =
          fun
          [ <:binding< $b1 and $b2 >> ->
              binding_handle_failure b1 && binding_handle_failure b2
          | <:binding< $_ = $e >> -> handle_failure e
          | _ -> False ]
        in binding_handle_failure bi && handle_failure e
    | <:expr< $lid:_ >> | <:expr< $int:_ >> | <:expr< $str:_ >> |
      <:expr< $chr:_ >> | <:expr< fun [ $_ ] >> | <:expr< $uid:_ >> ->
        True
    | <:expr< raise $e >> ->
        match e with
        [ <:expr< Stream.Failure >> -> False
        | _ -> True ]
    | <:expr< $f $x >> ->
        is_constr_apply f && handle_failure f && handle_failure x
    | _ -> False ]
  and is_constr_apply =
    fun
    [ <:expr< $uid:_ >> -> True
    | <:expr< $lid:_ >> -> False
    | <:expr< $x $_ >> -> is_constr_apply x
    | _ -> False ];

  let rec subst v e =
    let _loc = Ast.loc_of_expr e in
    match e with
    [ <:expr< $lid:x >> ->
        let x = if x = v then strm_n else x in
        <:expr< $lid:x >>
    | <:expr< $uid:_ >> -> e
    | <:expr< $int:_ >> -> e
    | <:expr< $chr:_ >> -> e
    | <:expr< $str:_ >> -> e
    | <:expr< $_ . $_ >> -> e
    | <:expr< let $rec:rf $bi in $e >> ->
        <:expr< let $rec:rf $(subst_binding v bi) in $(subst v e) >>
    | <:expr< $e1 $e2 >> -> <:expr< $(subst v e1) $(subst v e2) >>
    | <:expr< ( $tup:e ) >> -> <:expr< ( $(tup:subst v e) ) >>
    | <:expr< $e1, $e2 >> -> <:expr< $(subst v e1), $(subst v e2) >>
    | _ -> raise Not_found ]
  and subst_binding v =
    fun
    [ <:binding@_loc< $b1 and $b2 >> ->
        <:binding< $(subst_binding v b1) and $(subst_binding v b2) >>
    | <:binding@_loc< $lid:v' = $e >> ->
        <:binding< $lid:v' = $(if v = v' then e else subst v e) >>
    | _ -> raise Not_found ];

  let stream_pattern_component skont ckont =
    fun
    [ SpTrm _loc p None ->
        <:expr< match $(peek_fun _loc) $lid:strm_n with
                [ Some $p ->
                    do { $(junk_fun _loc) $lid:strm_n; $skont }
                | _ -> $ckont ] >>
    | SpTrm _loc p (Some w) ->
        <:expr< match $(peek_fun _loc) $lid:strm_n with
                [ Some $p when $w ->
                    do { $(junk_fun _loc) $lid:strm_n; $skont }
                | _ -> $ckont ] >>
    | SpNtr _loc p e ->
        let e =
          match e with
          [ <:expr< fun [ ($lid:v : Stream.t _) -> $e ] >> when v = strm_n -> e
          | _ -> <:expr< $e $lid:strm_n >> ]
        in
        if pattern_eq_expression p skont then
          if is_raise_failure ckont then e
          else if handle_failure e then e
          else <:expr< try $e with [ Stream.Failure -> $ckont ] >>
        else if is_raise_failure ckont then
          <:expr< let $p = $e in $skont >>
        else if pattern_eq_expression <:patt< Some $p >> skont then
          <:expr< try Some $e with [ Stream.Failure -> $ckont ] >>
        else if is_raise ckont then
          let tst =
            if handle_failure e then e
            else <:expr< try $e with [ Stream.Failure -> $ckont ] >>
          in
          <:expr< let $p = $tst in $skont >>
        else
          <:expr< match try Some $e with [ Stream.Failure -> None ] with
                  [ Some $p -> $skont
                  | _ -> $ckont ] >>
    | SpStr _loc p ->
        try
          match p with
          [ <:patt< $lid:v >> -> subst v skont
          | _ -> raise Not_found ]
        with
        [ Not_found -> <:expr< let $p = $lid:strm_n in $skont >> ] ];

  let rec stream_pattern _loc epo e ekont = fun
    [ [] ->
        match epo with
        [ Some ep -> <:expr< let $ep = Stream.count $lid:strm_n in $e >>
        | _ -> e ]
    | [(spc, err) :: spcl] ->
        let skont =
          let ekont err =
            let str = match err with
              [ Some estr -> estr
              | _ -> <:expr< "" >> ] in
            <:expr< raise (Stream.Error $str) >>
          in
          stream_pattern _loc epo e ekont spcl
        in
        let ckont = ekont err in stream_pattern_component skont ckont spc ];

  let stream_patterns_term _loc ekont tspel =
    let pel =
      List.fold_right
        (fun (p, w, _loc, spcl, epo, e) acc ->
          let p = <:patt< Some $p >> in
          let e =
            let ekont err =
              let str =
                match err with
                [ Some estr -> estr
                | _ -> <:expr< "" >> ]
              in
              <:expr< raise (Stream.Error $str) >>
            in
            let skont = stream_pattern _loc epo e ekont spcl in
            <:expr< do { $(junk_fun _loc) $lid:strm_n; $skont } >>
          in
          match w with
          [ Some w -> <:match_case< $pat:p when $w -> $e | $acc >>
          | None -> <:match_case< $pat:p -> $e | $acc >> ])
        tspel <:match_case<>>
    in
    <:expr< match $(peek_fun _loc) $lid:strm_n with [ $pel | _ -> $(ekont ()) ] >>
  ;

  let rec group_terms =
    fun
    [ [([(SpTrm _loc p w, None) :: spcl], epo, e) :: spel] ->
        let (tspel, spel) = group_terms spel in
        ([(p, w, _loc, spcl, epo, e) :: tspel], spel)
    | spel -> ([], spel) ]
  ;

  let rec parser_cases _loc = fun
    [ [] -> <:expr< raise Stream.Failure >>
    | spel ->
        match group_terms spel with
        [ ([], [(spcl, epo, e) :: spel]) ->
            stream_pattern _loc epo e (fun _ -> parser_cases _loc spel) spcl
        | (tspel, spel) ->
            stream_patterns_term _loc (fun _ -> parser_cases _loc spel) tspel ] ];

  let cparser _loc bpo pc =
    let e = parser_cases _loc pc in
    let e =
      match bpo with
      [ Some bp -> <:expr< let $bp = Stream.count $lid:strm_n in $e >>
      | None -> e ]
    in
    let p = <:patt< ($lid:strm_n : Stream.t _) >> in
    <:expr< fun $p -> $e >> ;

  let cparser_match _loc me bpo pc =
    let pc = parser_cases _loc pc in
    let e =
      match bpo with
      [ Some bp -> <:expr< let $bp = Stream.count $lid:strm_n in $pc >>
      | None -> pc ]  in
    let me =   match me with
      [ <:expr@_loc< $_; $_ >> as e -> <:expr< do { $e } >>
      | e -> e ] in
    match me with
    [ <:expr< $lid:x >> when x = strm_n -> e
    | _ -> <:expr< let ($lid:strm_n : Stream.t _) = $me in $e >> ] ;

  (* streams *)

  let rec not_computing =
    fun
    [ <:expr< $lid:_ >> | <:expr< $uid:_ >> | <:expr< $int:_ >> |
      <:expr< $flo:_ >> | <:expr< $chr:_ >> | <:expr< $str:_ >> -> True
    | <:expr< $x $y >> -> is_cons_apply_not_computing x && not_computing y
    | _ -> False ]
  and is_cons_apply_not_computing =
    fun
    [ <:expr< $uid:_ >> -> True
    | <:expr< $lid:_ >> -> False
    | <:expr< $x $y >> -> is_cons_apply_not_computing x && not_computing y
    | _ -> False ];

  let slazy _loc e =
    match e with
    [ <:expr< $f () >> ->
        match f with
        [ <:expr< $lid:_ >> -> f
        | _ -> <:expr< fun _ -> $e >> ]
    | _ -> <:expr< fun _ -> $e >> ] ;

  let rec cstream gloc = 
    fun
    [ [] -> let _loc = gloc in <:expr< [< >] >>
    | [SeTrm _loc e] ->
        if not_computing e then <:expr< Stream.ising $e >>
        else <:expr< Stream.lsing $(slazy _loc e) >>
    | [SeTrm _loc e :: secl] ->
        if not_computing e then <:expr< Stream.icons $e $(cstream gloc secl) >>
        else <:expr< Stream.lcons $(slazy _loc e) $(cstream gloc secl) >>
    | [SeNtr _loc e] ->
        if not_computing e then e else <:expr< Stream.slazy $(slazy _loc e) >>
    | [SeNtr _loc e :: secl] ->
        if not_computing e then <:expr< Stream.iapp $e $(cstream gloc secl) >>
        else <:expr< Stream.lapp $(slazy _loc e) $(cstream gloc secl) >> ] ;
  (* Syntax extensions in Revised Syntax grammar *)

  EXTEND Gram
    GLOBAL: expr stream_expr stream_begin stream_end stream_quot
      parser_case parser_case_list;
    expr: Level "top"
      [ [ "parser"; po = OPT parser_ipatt; pcl = parser_case_list ->
            cparser _loc po pcl
        | "match"; e = sequence; "with"; "parser"; po = OPT parser_ipatt;
          pcl = parser_case_list ->
            cparser_match _loc e po pcl ] ]
    parser_ipatt:
      [ [ i = a_LIDENT -> <:patt< $lid:i >>  | "_" -> <:patt< _ >>  ] ]        
    parser_case_list:
      [ [ "["; pcl = LIST0 parser_case SEP "|"; "]" -> pcl
        | pc = parser_case -> [pc] ] ]
    parser_case:
      [ [ stream_begin; sp = stream_patt; stream_end; po = OPT parser_ipatt; "->"; e = expr
          ->   (sp, po, e) ] ]
    stream_begin: [ [ "[<" -> () ] ] stream_end: [ [ ">]" -> () ] ]
    stream_quot:  [ [ "'" -> () ] ]
    stream_expr:  [ [ e = expr -> e ] ]
    stream_patt:
      [ [ spc = stream_patt_comp -> [(spc, None)]
        | spc = stream_patt_comp; ";"; sp = stream_patt_comp_err_list
          ->    [(spc, None) :: sp]
        | -> [] ] ]
    (* stream_patt_comp: (\* FIXME here *\) *)
    (*   [ [ stream_quot; p = patt; eo = OPT [ "when"; e = stream_expr -> e ] *)
    (*       ->  SpTrm _loc p eo *)
    (*     | p = patt; "="; e = stream_expr -> SpNtr _loc p e *)
    (*     | p = patt -> SpStr _loc p ] ] *)
    stream_patt_comp: (* FIXME here *)
      [ [ p = patt; eo = OPT [ "when"; e = stream_expr -> e ]
          ->  SpTrm _loc p eo
        | p = patt; "="; e = stream_expr -> SpNtr _loc p e
        | stream_quot; p = patt -> SpStr _loc p ] ]
        
    stream_patt_comp_err:
      [ [ spc = stream_patt_comp; eo = OPT [ "??"; e = stream_expr -> e ]
          ->  (spc, eo) ] ]
    stream_patt_comp_err_list:
      [ [ spc = stream_patt_comp_err -> [spc]
        | spc = stream_patt_comp_err; ";" -> [spc]
        | spc = stream_patt_comp_err; ";"; sp = stream_patt_comp_err_list ->
            [spc :: sp] ] ]
    expr: Level "simple"
      [ [ stream_begin; stream_end -> <:expr< [< >] >>
        | stream_begin; sel = stream_expr_comp_list; stream_end
          ->  cstream _loc sel] ]
    stream_expr_comp_list:
      [ [ se = stream_expr_comp; ";"; sel = stream_expr_comp_list -> [se :: sel]
        | se = stream_expr_comp; ";" -> [se]
        | se = stream_expr_comp -> [se] ] ]
    (* stream_expr_comp: (\* FIXME *\) *)
    (*   [ [ stream_quot; e = stream_expr -> SeTrm _loc e *)
    (*     | e = stream_expr -> SeNtr _loc e ] ] *)
    stream_expr_comp: (* FIXME *)
      [ [  e = stream_expr -> SeTrm _loc e
        | stream_quot;e = stream_expr -> SeNtr _loc e ] ]
        
  END;

end;
  
module IdQuotationCommon = struct (* FIXME unused here *)
  let name = "Camlp4QuotationCommon";
  let version = Sys.ocaml_version;
end;

module MakeQuotationCommon (Syntax : Sig.Camlp4Syntax)
            (TheAntiquotSyntax : Sig.ParserExpr)
= struct
  open FanSig;
  include Syntax; (* Be careful an AntiquotSyntax module appears here *)
  module Ast = Camlp4Ast;
  module MetaAst = Ast.Meta.Make Lib.Meta.MetaLocQuotation;
  module ME = MetaAst.Expr;
  module MP = MetaAst.Patt;

  let antiquot_expander = object
    inherit Ast.map as super;
    method! patt = fun
      [ <:patt@_loc< $anti:s >> | <:patt@_loc< $str:s >> as p ->
          let mloc _loc = Lib.Meta.MetaLocQuotation.meta_loc_patt _loc _loc in
          handle_antiquot_in_string s p TheAntiquotSyntax.parse_patt _loc
            ~decorate:(fun n p ->
            match n with
            [ "antisig_item" -> <:patt< Ast.SgAnt $(mloc _loc) $p >>
            | "antistr_item" -> <:patt< Ast.StAnt $(mloc _loc) $p >>
            | "antictyp" -> <:patt< Ast.TyAnt $(mloc _loc) $p >>
            | "antipatt" -> <:patt< Ast.PaAnt $(mloc _loc) $p >>
            | "antiexpr" -> <:patt< Ast.ExAnt $(mloc _loc) $p >>
            | "antimodule_type" -> <:patt< Ast.MtAnt $(mloc _loc) $p >>
            | "antimodule_expr" -> <:patt< Ast.MeAnt $(mloc _loc) $p >>
            | "anticlass_type" -> <:patt< Ast.CtAnt $(mloc _loc) $p >>
            | "anticlass_expr" -> <:patt< Ast.CeAnt $(mloc _loc) $p >>
            | "anticlass_sig_item" -> <:patt< Ast.CgAnt $(mloc _loc) $p >>
            | "anticlass_str_item" -> <:patt< Ast.CrAnt $(mloc _loc) $p >>
            | "antiwith_constr" -> <:patt< Ast.WcAnt $(mloc _loc) $p >>
            | "antibinding" -> <:patt< Ast.BiAnt $(mloc _loc) $p >>
            | "antirec_binding" -> <:patt< Ast.RbAnt $(mloc _loc) $p >>
            | "antimatch_case" -> <:patt< Ast.McAnt $(mloc _loc) $p >>
            | "antimodule_binding" -> <:patt< Ast.MbAnt $(mloc _loc) $p >>
            | "antiident" -> <:patt< Ast.IdAnt $(mloc _loc) $p >>
            | _ -> p ])
      | p -> super#patt p ];
    method! expr = fun
      [ <:expr@_loc< $anti:s >> | <:expr@_loc< $str:s >> as e ->
          let mloc _loc = Lib.Meta.MetaLocQuotation.meta_loc_expr _loc _loc in
          handle_antiquot_in_string s e TheAntiquotSyntax.parse_expr _loc
            ~decorate:(fun n e ->
            match n with
            [ "`int" -> <:expr< string_of_int $e >>
            | "`int32" -> <:expr< Int32.to_string $e >>
            | "`int64" -> <:expr< Int64.to_string $e >>
            | "`nativeint" -> <:expr< Nativeint.to_string $e >>
            | "`flo" -> <:expr< FanUtil.float_repres $e >>
            | "`str" -> <:expr< Ast.safe_string_escaped $e >>
            | "`chr" -> <:expr< Char.escaped $e >>
            | "`bool" -> <:expr< Ast.IdUid $(mloc _loc) (if $e then "True" else "False") >>
            | "liststr_item" -> <:expr< Ast.stSem_of_list $e >>
            | "listsig_item" -> <:expr< Ast.sgSem_of_list $e >>
            | "listclass_sig_item" -> <:expr< Ast.cgSem_of_list $e >>
            | "listclass_str_item" -> <:expr< Ast.crSem_of_list $e >>
            | "listmodule_expr" -> <:expr< Ast.meApp_of_list $e >>
            | "listmodule_type" -> <:expr< Ast.mtApp_of_list $e >>
            | "listmodule_binding" -> <:expr< Ast.mbAnd_of_list $e >>
            | "listbinding" -> <:expr< Ast.biAnd_of_list $e >>
            | "listbinding;" -> <:expr< Ast.biSem_of_list $e >>
            | "listrec_binding" -> <:expr< Ast.rbSem_of_list $e >>
            | "listclass_type" -> <:expr< Ast.ctAnd_of_list $e >>
            | "listclass_expr" -> <:expr< Ast.ceAnd_of_list $e >>
            | "listident" -> <:expr< Ast.idAcc_of_list $e >>
            | "listctypand" -> <:expr< Ast.tyAnd_of_list $e >>
            | "listctyp;" -> <:expr< Ast.tySem_of_list $e >>
            | "listctyp*" -> <:expr< Ast.tySta_of_list $e >>
            | "listctyp|" -> <:expr< Ast.tyOr_of_list $e >>
            | "listctyp," -> <:expr< Ast.tyCom_of_list $e >>
            | "listctyp&" -> <:expr< Ast.tyAmp_of_list $e >>
            | "listwith_constr" -> <:expr< Ast.wcAnd_of_list $e >>
            | "listmatch_case" -> <:expr< Ast.mcOr_of_list $e >>
            | "listpatt," -> <:expr< Ast.paCom_of_list $e >>
            | "listpatt;" -> <:expr< Ast.paSem_of_list $e >>
            | "listexpr," -> <:expr< Ast.exCom_of_list $e >>
            | "listexpr;" -> <:expr< Ast.exSem_of_list $e >>
            | "antisig_item" -> <:expr< Ast.SgAnt $(mloc _loc) $e >>
            | "antistr_item" -> <:expr< Ast.StAnt $(mloc _loc) $e >>
            | "antictyp" -> <:expr< Ast.TyAnt $(mloc _loc) $e >>
            | "antipatt" -> <:expr< Ast.PaAnt $(mloc _loc) $e >>
            | "antiexpr" -> <:expr< Ast.ExAnt $(mloc _loc) $e >>
            | "antimodule_type" -> <:expr< Ast.MtAnt $(mloc _loc) $e >>
            | "antimodule_expr" -> <:expr< Ast.MeAnt $(mloc _loc) $e >>
            | "anticlass_type" -> <:expr< Ast.CtAnt $(mloc _loc) $e >>
            | "anticlass_expr" -> <:expr< Ast.CeAnt $(mloc _loc) $e >>
            | "anticlass_sig_item" -> <:expr< Ast.CgAnt $(mloc _loc) $e >>
            | "anticlass_str_item" -> <:expr< Ast.CrAnt $(mloc _loc) $e >>
            | "antiwith_constr" -> <:expr< Ast.WcAnt $(mloc _loc) $e >>
            | "antibinding" -> <:expr< Ast.BiAnt $(mloc _loc) $e >>
            | "antirec_binding" -> <:expr< Ast.RbAnt $(mloc _loc) $e >>
            | "antimatch_case" -> <:expr< Ast.McAnt $(mloc _loc) $e >>
            | "antimodule_binding" -> <:expr< Ast.MbAnt $(mloc _loc) $e >>
            | "antiident" -> <:expr< Ast.IdAnt $(mloc _loc) $e >>
            | _ -> e ])
      | e -> super#expr e ];
  end;

  let add_quotation name entry mexpr mpatt =
    let entry_eoi = Gram.mk (Gram.name entry) in
    let parse_quot_string entry loc s =
      let q = !FanConfig.antiquotations in
      let () = FanConfig.antiquotations := True in
      let res = Gram.parse_string entry loc s in
      let () = FanConfig.antiquotations := q in
      res in
    let expand_expr loc loc_name_opt s =
      let ast = parse_quot_string entry_eoi loc s in
      let () = Lib.Meta.MetaLocQuotation.loc_name := loc_name_opt in
      let meta_ast = mexpr loc ast in
      let exp_ast = antiquot_expander#expr meta_ast in
      exp_ast in
    let expand_str_item loc loc_name_opt s =
      let exp_ast = expand_expr loc loc_name_opt s in
      <:str_item@loc< $(exp:exp_ast) >> in
    let expand_patt _loc loc_name_opt s =
      let ast = parse_quot_string entry_eoi _loc s in
      let meta_ast = mpatt _loc ast in
      let exp_ast = antiquot_expander#patt meta_ast in
      match loc_name_opt with
      [ None -> exp_ast
      | Some name ->
        let rec subst_first_loc =  fun
          [ <:patt@_loc< Ast.$uid:u $_ >> -> <:patt< Ast.$uid:u $lid:name >>
          | <:patt@_loc< $a $b >> -> <:patt< $(subst_first_loc a) $b >>
          | p -> p ] in
        subst_first_loc exp_ast ] in begin 
          EXTEND Gram
            entry_eoi:
            [ [ x = entry; `EOI -> x ] ]
            END;
          Quotation.add name DynAst.expr_tag expand_expr;
          Quotation.add name DynAst.patt_tag expand_patt;
          Quotation.add name DynAst.str_item_tag expand_str_item;
        end;
  add_quotation "sig_item" sig_item_quot ME.meta_sig_item MP.meta_sig_item;
  add_quotation "str_item" str_item_quot ME.meta_str_item MP.meta_str_item;
  add_quotation "ctyp" ctyp_quot ME.meta_ctyp MP.meta_ctyp;
  add_quotation "patt" patt_quot ME.meta_patt MP.meta_patt;
  add_quotation "expr" expr_quot ME.meta_expr MP.meta_expr;
  add_quotation "module_type" module_type_quot ME.meta_module_type MP.meta_module_type;
  add_quotation "module_expr" module_expr_quot ME.meta_module_expr MP.meta_module_expr;
  add_quotation "class_type" class_type_quot ME.meta_class_type MP.meta_class_type;
  add_quotation "class_expr" class_expr_quot ME.meta_class_expr MP.meta_class_expr;
  add_quotation "class_sig_item"
                class_sig_item_quot ME.meta_class_sig_item MP.meta_class_sig_item;
  add_quotation "class_str_item"
                class_str_item_quot ME.meta_class_str_item MP.meta_class_str_item;
  add_quotation "with_constr" with_constr_quot ME.meta_with_constr MP.meta_with_constr;
  add_quotation "binding" binding_quot ME.meta_binding MP.meta_binding;
  add_quotation "rec_binding" rec_binding_quot ME.meta_rec_binding MP.meta_rec_binding;
  add_quotation "match_case" match_case_quot ME.meta_match_case MP.meta_match_case;
  add_quotation "module_binding"
                module_binding_quot ME.meta_module_binding MP.meta_module_binding;
  add_quotation "ident" ident_quot ME.meta_ident MP.meta_ident;
  add_quotation "rec_flag" rec_flag_quot ME.meta_rec_flag MP.meta_rec_flag;
  add_quotation "private_flag" private_flag_quot ME.meta_private_flag MP.meta_private_flag;
  add_quotation "row_var_flag" row_var_flag_quot ME.meta_row_var_flag MP.meta_row_var_flag;
  add_quotation "mutable_flag" mutable_flag_quot ME.meta_mutable_flag MP.meta_mutable_flag;
  add_quotation "virtual_flag" virtual_flag_quot ME.meta_virtual_flag MP.meta_virtual_flag;
  add_quotation "override_flag" override_flag_quot ME.meta_override_flag MP.meta_override_flag;
  add_quotation "direction_flag" direction_flag_quot ME.meta_direction_flag MP.meta_direction_flag;

end;



module IdQuotationExpander = struct
  let name = "Camlp4QuotationExpander";
  let version = Sys.ocaml_version;
end;

module MakeQuotationExpander (Syntax : Sig.Camlp4Syntax)
= struct
  module M = MakeQuotationCommon Syntax Syntax.AntiquotSyntax;
  include M;
end;

(* let pa_r  = "Camlp4OCamlRevisedParser"; *)    
let pa_r (module P:Sig.PRECAST) =
  P.syntax_extension (module IdRevisedParser)  (module MakeRevisedParser);

(* let pa_rp = "Camlp4OCamlRevisedParserParser"; *)
let pa_rp (module P:Sig.PRECAST) =
  P.syntax_extension (module IdRevisedParserParser)
    (module MakeRevisedParserParser);


let pa_g (module P:Sig.PRECAST) =
  P.syntax_extension (module IdGrammarParser) (module MakeGrammarParser);

(* let pa_m  = "Camlp4MacroParser"; *)
let pa_m (module P:Sig.PRECAST) =
  let () = P.syntax_extension (module IdMacroParser) (module MakeMacroParser) in
  P.syntax_plugin (module IdMacroParser) (module MakeNothing);

(* let pa_q  = "Camlp4QuotationExpander"; *)
let pa_q (module P:Sig.PRECAST) =
  P.syntax_extension (module IdQuotationExpander) (module MakeQuotationExpander);
  
(* let pa_rq = "Camlp4OCamlRevisedQuotationExpander"; *)
(*   unreflective*, quotation syntax use revised syntax. *)

let pa_rq (module P:Sig.PRECAST) =
  let module Gram = Grammar.Static.Make P.Lexer in
  let module M1 = OCamlInitSyntax.Make P.Gram in
  let module M2 = MakeRevisedParser M1 in
  let module M3 = MakeQuotationCommon M2 P.Syntax.AntiquotSyntax in ();

let pa_l  (module P: Sig.PRECAST) =
  P.syntax_extension (module IdListComprehension) (module MakeListComprehension);


(* load debug parser for bootstrapping *)
let pa_debug (module P: Sig.PRECAST) =
  P.syntax_extension (module IdDebugParser) (module MakeDebugParser);




