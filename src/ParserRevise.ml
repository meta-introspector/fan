
open AstLoc;
open FanOps;
open Syntax;
open LibUtil;
open FanUtil;
open GramLib;
let help_sequences () = begin
  Printf.eprintf "\
New syntax:\
\n    (e1; e2; ... ; en) OR begin e1; e2; ... ; en end\
\n    while e do e1; e2; ... ; en done\
\n    for v = v1 to/downto v2 do e1; e2; ... ; en done\
\nOld syntax (still supported):\
\n    begin e1; e2; ... ; en end\
\n    while e begin e1; e2; ... ; en end\
\n    for v = v1 to/downto v2 do {e1; e2; ... ; en}\
\nVery old (no more supported) syntax:\
\n    do e1; e2; ... ; en-1; return en\
\n    while e do e1; e2; ... ; en; done\
\n    for v = v1 to/downto v2 do e1; e2; ... ; en; done\
\n"; flush stderr; exit 1  end;

{:create|Gram pos_exprs|};
let apply () = begin 
  Options.add ("-help_seq", (FanArg.Unit help_sequences), "Print explanations about new sequences and exit.");

    {:clear|Gram
      amp_ctyp and_ctyp match_case match_case0 match_case_quot binding binding_quot rec_expr_quot
    class_declaration class_description class_expr class_expr_quot class_fun_binding class_fun_def
    class_info_for_class_expr class_info_for_class_type class_longident class_longident_and_param
    class_name_and_param class_sig_item class_sig_item_quot class_signature class_str_item class_str_item_quot
    class_structure
      class_type class_type_declaration class_type_longident class_type_longident_and_param
    class_type_plus class_type_quot comma_ctyp comma_expr comma_ipatt comma_patt comma_type_parameter
    constrain constructor_arg_list constructor_declaration constructor_declarations ctyp ctyp_quot
    cvalue_binding direction_flag dummy eq_expr expr expr_eoi expr_quot field_expr field_expr_list fun_binding
    fun_def ident ident_quot implem interf ipatt ipatt_tcon patt_tcon label_declaration label_declaration_list
    label_expr_list label_expr label_longident label_patt label_patt_list  let_binding meth_list
    meth_decl module_binding module_binding0 module_binding_quot module_declaration module_expr module_expr_quot
    module_longident module_longident_with_app module_rec_declaration module_type module_type_quot
    more_ctyp name_tags (* opt_as_lident *) (* opt_class_self_patt *) opt_class_self_type opt_comma_ctyp opt_dot_dot
    (* opt_expr *) opt_meth_list opt_mutable opt_polyt opt_private opt_rec opt_virtual 
    patt patt_as_patt_opt patt_eoi patt_quot row_field sem_expr
    sem_expr_for_list sem_patt sem_patt_for_list semi sequence sig_item sig_item_quot sig_items star_ctyp
    str_item str_item_quot str_items top_phrase type_declaration type_ident_and_parameters
    type_longident type_longident_and_parameters type_parameter type_parameters typevars 
    val_longident with_constr with_constr_quot
      lang
  |};  


  let list = ['!'; '?'; '~'] in
  let excl = ["!="; "??"] in
  setup_op_parser prefixop
    (fun x -> not (List.mem x excl) && String.length x >= 2 &&
              List.mem x.[0] list && symbolchar x 1);

  let list_ok = ["<"; ">"; "<="; ">="; "="; "<>"; "=="; "!="; "$"] in
  let list_first_char_ok = ['='; '<'; '>'; '|'; '&'; '$'; '!'] in
  let excl = ["<-"; "||"; "&&"] in
  setup_op_parser infixop2
    (fun x -> (List.mem x list_ok) ||
              (not (List.mem x excl) && String.length x >= 2 &&
              List.mem x.[0] list_first_char_ok && symbolchar x 1));

  let list = ['@'; '^'] in
  setup_op_parser infixop3
    (fun x -> String.length x >= 1 && List.mem x.[0] list &&
              symbolchar x 1);

  let list = ['+'; '-'] in
  setup_op_parser infixop4
    (fun x -> x <> "->" && String.length x >= 1 && List.mem x.[0] list &&
              symbolchar x 1);

  let list = ['*'; '/'; '%'; '\\'] in
  setup_op_parser infixop5
    (fun x -> String.length x >= 1 && List.mem x.[0] list &&
              (x.[0] <> '*' || String.length x < 2 || x.[1] <> '*') &&
              symbolchar x 1);

  setup_op_parser infixop6
    (fun x -> String.length x >= 2 && x.[0] == '*' && x.[1] == '*' &&
              symbolchar x 2);


  FanTokenFilter.define_filter (Gram.get_filter ())
    (fun f strm -> infix_kwds_filter (f strm));

  Gram.setup_parser sem_expr begin
    let symb1 = Gram.parse_origin_tokens expr in
    let symb = parser
      [ [< (`Ant (("list" as n), s), _loc) >] ->
        {:expr| $(anti:mk_anti ~c:"expr;" n s) |}
      | [< a = symb1 >] -> a ] in
    let rec kont al =
      parser
      [ [< (`KEYWORD ";", _); a = symb; 's >] ->
        let _loc =  al <+> a  in
        kont {:expr| $al; $a |} s
      | [< >] -> al ] in
    parser [< a = symb; 's >] -> kont a s
  end;

  with module_expr
  {:extend|
      module_expr_quot:
      [ module_expr{x} -> x]
      module_binding0:
      { RA
        [ "("; a_uident{m}; ":"; module_type{mt}; ")"; S{mb} ->
            {| functor ( $m : $mt ) -> $mb |}
        | ":"; module_type{mt}; "="; module_expr{me} ->
            {| ( $me : $mt ) |}
        | "="; module_expr{me} -> {| $me |} ] }
      module_expr:
      { "top"
        [ "functor"; "("; a_uident{i}; ":"; module_type{t}; ")"; "->"; S{me} ->
            {| functor ( $i : $t ) -> $me |}
        | "struct"; str_items{st}; "end" -> `Struct(_loc,st)
        | "struct"; "end" -> `StructEnd(_loc)]
       "apply"
        [ S{me1}; S{me2} -> {| $me1 $me2 |} ]
       "simple"
        [ `Ant ((""|"mexp"|"anti"|"list" as n),s) ->
            {| $(anti:mk_anti ~c:"module_expr" n s) |}
        | `QUOTATION x ->
            AstQuotation.expand _loc x DynAst.module_expr_tag
        | module_longident{i} -> {| $id:i |}
        | "("; S{me}; ":"; module_type{mt}; ")" ->
            {| ( $me : $mt ) |}
        | "("; S{me}; ")" -> {| $me |}
        | "("; "val"; expr{e}; ")" -> {| (val $e) |}  (* first class modules *)
        | "("; "val"; expr{e}; ":"; (* package_type *)module_type{p}; ")" ->
            {| (val $e : $p) |} ] } |};

  with module_binding
      {:extend|
        module_binding_quot:
        [ S{b1}; "and"; S{b2} ->  `And(_loc,b1,b2)
        | `Ant (("module_binding"|"anti"|"" as n),s) ->
            {| $(anti:mk_anti ~c:"module_binding" n s) |}
        | a_uident{m}; ":"; module_type{mt} -> `Constraint(_loc,m,mt)
        | a_uident{m}; ":"; module_type{mt}; "="; module_expr{me} ->
            (* {| $uid:m : $mt = $me |} *)
            `ModuleBind(_loc,m,mt,me)]
        module_binding:
        [ S{b1}; "and"; S{b2} -> {| $b1 and $b2 |}
        | `Ant (("module_binding"|"anti"|"list" |"" as n),s) -> {| $(anti:mk_anti ~c:"module_binding" n s) |}
        | `QUOTATION x -> AstQuotation.expand _loc x DynAst.module_binding_tag
        | a_uident{m}; ":"; module_type{mt}; "="; module_expr{me} ->
            (* {| $uid:m : $mt = $me |} *)
               `ModuleBind (_loc, m, mt, me)]
        module_rec_declaration:
        [ S{m1}; "and"; S{m2} -> {| $m1 and $m2 |}
        | `Ant ((""|"module_binding"|"anti"|"list" as n),s) ->  {| $(anti:mk_anti ~c:"module_binding" n s) |}
        | `QUOTATION x -> AstQuotation.expand _loc x DynAst.module_binding_tag
        | a_uident{m}; ":"; module_type{mt} ->
            `Constraint(_loc,m,mt)
            (* {| $uid:m : $mt |} *) ] |};

  with with_constr
      {:extend|
        with_constr_quot:
        [ with_constr{x} -> x   ]
        with_constr: 
        [ S{wc1}; "and"; S{wc2} -> {| $wc1 and $wc2 |}
        | `Ant ((""|"with_constr"|"anti"|"list" as n),s) -> {| $(anti:mk_anti ~c:"with_constr" n s) |}
        | `QUOTATION x -> AstQuotation.expand _loc x DynAst.with_constr_tag
        | "type"; type_longident_and_parameters{t1}; "="; ctyp{t2} ->
            `TypeEq (_loc, t1, t2)
        | "type"; type_longident_and_parameters{t1}; "="; "private"; ctyp{t2} ->
            `TypeEqPriv(_loc,t1,t2)
            (* {| type $t1 = $t2 |} *)
        | "type"; type_longident_and_parameters{t1}; ":="; ctyp{t2} ->
            `TypeSubst (_loc, t1, t2)
            (* {| type $t1 := $t2 |} *)
        | "module"; module_longident{i1}; "="; module_longident_with_app{i2} ->
            `ModuleEq (_loc, i1, i2)
            (* {| module $i1 = $i2 |} *)
        | "module"; module_longident{i1}; ":="; module_longident_with_app{i2} ->
            `ModuleSubst (_loc, i1, i2)
            (* {| module $i1 := $i2 |} *) ] |};

  with module_type
    {:extend|
      module_type:
      { "top"
        [ "functor"; "("; a_uident{i}; ":"; S{t}; ")"; "->"; S{mt} ->
            {| functor ( $i : $t ) -> $mt |} ]
        "with"
        [ S{mt}; "with"; with_constr{wc} ->  {| $mt with $wc |} ]
        "apply"
        [ S{mt1}; S{mt2} ->
          let app0 mt1 mt2 =
            match (mt1, mt2) with
            [ (`Id(loc1,i1),`Id(loc2,i2)) ->
              let _loc = FanLoc.merge loc1 loc2 in
              `Id(_loc,`App(_loc,i1,i2))
            | _ -> raise XStream.Failure ] in app0 mt1 mt2
          (* ModuleType.app0 mt1 mt2 *) ] (* FIXME *)
        "."
        [ S{mt1}; "."; S{mt2} ->
          let acc0 mt1 mt2 =
            match (mt1, mt2) with
            [ (`Id(loc1,i1),`Id(loc2,i2)) ->
              let _loc = FanLoc.merge loc1 loc2 in
              `Id(_loc,`Dot(_loc,i1,i2))
                (* ({| $id:i1 |}, {@_| $id:i2 |}) ->  {| $(id:{:ident| $i1.$i2 |}) |} *)
            | _ -> raise XStream.Failure ] in
          acc0 mt1 mt2
          (* ModuleType.acc0 mt1 mt2 *) ] (*FIXME*)
        "sig"
        [ "sig"; sig_items{sg}; "end" -> `Sig(_loc,sg)
        | "sig";"end" -> `SigEnd(_loc)]
       "simple"
        [ `Ant ((""|"mtyp"|"anti"|"list" as n),s) ->  {| $(anti:mk_anti ~c:"module_type" n s) |}
        | `QUOTATION x -> AstQuotation.expand _loc x DynAst.module_type_tag
        | module_longident_with_app{i} -> {| $id:i |}
        | "("; S{mt}; ")" -> {| $mt |}
        | "module"; "type"; "of"; module_expr{me} -> `ModuleTypeOf(_loc,me)] }
      module_declaration:
      { RA
        [ ":"; module_type{mt} -> {| $mt |}
        | "("; a_uident{i}; ":"; module_type{t}; ")"; S{mt} ->
            {| functor ( $i : $t ) -> $mt |} ] }
      module_type_quot:
      [ module_type{x} -> x | -> {:module_type||} ]  |};

  with sig_item
  {:extend|
    sig_item_quot:
    [ "#"; a_lident{s} -> `DirectiveSimple(_loc,s)
    | "#"; a_lident{s}; expr{dp} -> `Directive(_loc,s,dp)
    | sig_item{sg1}; semi; S{sg2} -> `Sem(_loc,sg1,sg2)
    | sig_item{sg} -> sg] 
    sig_item:
    [ `Ant ((""|"sigi"|"anti"|"list" as n),s) ->  {| $(anti:mk_anti ~c:"sig_item" n s) |}
    | `QUOTATION x -> AstQuotation.expand _loc x DynAst.sig_item_tag
    | "exception"; constructor_declaration{t} ->  {| exception $t |}
    | "external"; a_lident{i};":";ctyp{t};"=" ;string_list{sl} ->
        `External (_loc, i, t, sl)
        (* {| external $i : $t = $sl |}  *)
    | "include"; module_type{mt} -> {| include $mt |}
    | "module"; a_uident{i}; module_declaration{mt} ->  {| module $i : $mt |}
    | "module"; "rec"; module_rec_declaration{mb} ->    {| module rec $mb |}
    | "module"; "type"; a_uident{i}; "="; module_type{mt} ->
        `ModuleType(_loc,i,mt)
    | "module"; "type"; a_uident{i} -> {| module type $i |}
    | "open"; module_longident{i} -> {| open $i |}

    | "type"; type_declaration{t} -> `Type(_loc,t) (* {| type $t |} *)
    | "val"; a_lident{i}; ":"; ctyp{t} -> `Val(_loc,i,t)
    | "class"; class_description{cd} ->    `Class(_loc,cd)
    | "class"; "type"; class_type_declaration{ctd} ->  `ClassType(_loc,ctd) ]
    (* mli entrance *)    
    interf:
    [ "#"; a_lident{n};  ";;" ->
      ([ `DirectiveSimple(_loc,n) ],  Some _loc)
    | "#"; a_lident{n}; expr{dp}; ";;" -> ([ `Directive(_loc,n,dp)], Some _loc) 
    | sig_item{si}; semi;  S{(sil, stopped)} -> ([si :: sil], stopped)
    | `EOI -> ([], None) ]
    sig_items:
    [ `Ant ((""|"sigi"|"anti"|"list" as n),s) ->  {| $(anti:mk_anti n ~c:"sig_item" s) |}
    | `Ant ((""|"sigi"|"anti"|"list" as n),s); semi; S{sg} ->  {| $(anti:mk_anti n ~c:"sig_item" s); $sg |} 
    | L1 [ sig_item{sg}; semi -> sg ]{l} -> sem_of_list1 l  ]
 |};

    with expr
    {:extend|
      local:  fun_def_patt;
      expr_quot:
      [ expr{e1}; ","; comma_expr{e2} -> `Com(_loc,e1,e2)
      | expr{e1}; ";"; sem_expr{e2} -> `Sem(_loc,e1,e2)
      | expr{e} -> e]
       (*
       {:str_item|
       let f (type t) () =
          let module M = struct exception E of t ; end in
          ((fun x -> M.E x), (function [M.E x -> Some x | _ -> None]))|}

       {:str_item| let f : ! 'a . 'a -> 'a = fun x -> x |}  
        *)
      cvalue_binding:
      [ "="; expr{e} -> e
      | ":"; "type"; unquoted_typevars{t1}; "." ; ctyp{t2} ; "="; expr{e} -> 
          let u = {:ctyp| ! $t1 . $t2 |} in  {| ($e : $u) |}
      | ":"; (* poly_type *)ctyp{t}; "="; expr{e} -> {| ($e : $t) |}
      | ":"; (* poly_type *)ctyp{t}; ":>"; ctyp{t2}; "="; expr{e} ->
          match t with
          [ {:ctyp| ! $_ . $_ |} -> raise (XStream.Error "unexpected polytype here")
          | _ -> {| ($e : $t :> $t2) |} ]
      | ":>"; ctyp{t}; "="; expr{e} -> {| ($e :> $t) |} ]
      fun_binding:
      { RA
          [ "("; "type"; a_lident{i}; ")"; S{e} ->
            {| fun (type $i) -> $e |} 
          | ipatt{p}; S{e} -> `Fun(_loc,`Case(_loc,p,e))
              (* {| fun $p -> $e |} *)
          | cvalue_binding{bi} -> bi  ] }
       lang:
       [ dot_lstrings{ls} -> begin
         let old = !AstQuotation.default;
         AstQuotation.default := FanToken.resolve_name ls;
        old
       end
       ]
       pos_exprs:
       [ L1
           [ `Lid x;":";dot_lstrings{y} ->
             ((x:string),
              FanToken.resolve_name y
             )
           | `Lid x ->
               ((x:string), FanToken.resolve_name
                  (`Sub [], x) ) ] SEP ";"{xys} -> begin
           let old = !AstQuotation.map;
           AstQuotation.map := SMap.add_list xys old;
           old
       end]
       fun_def_patt:
       ["(";"type";a_lident{i};")" ->
         fun e -> {|fun (type $i) -> $e |} 
       | ipatt{p} -> fun e -> `Fun(_loc,`Case(_loc,p,e))(* {| fun $p -> $e |} *)
       | ipatt{p}; "when"; expr{w} -> fun e ->
           `Fun(_loc,`CaseWhen(_loc,p,w,e))
           (* {|fun $p when $w -> $e |} *) ]
       fun_def:
       {RA
          [ fun_def_patt{f}; "->"; expr{e} ->  f e
          | fun_def_patt{f}; S{e} -> f e] }    
       expr:
       {
        "top" RA
        [ "let"; opt_rec{r}; binding{bi}; "in"; S{x} ->
            {| let $rec:r $bi in $x |}
        | "let"; "module"; a_uident{m}; module_binding0{mb}; "in"; S{e} ->
            {| let module $m = $mb in $e |}
        | "let"; "open"; module_longident{i}; "in"; S{e} ->
            {| let open $id:i in $e |}
        | "let"; "try"; opt_rec{r}; binding{bi}; "in"; S{x}; "with"; match_case{a} ->
            {| let try $rec:r $bi in $x with [ $a ] |}
        | "match"; S{e}; "with"; match_case{a} -> {|match $e with [$a]|}
        | "try"; S{e}; "with"; match_case{a} -> {|try $e with [$a]|}
        | "if"; S{e1}; "then"; S{e2}; "else"; S{e3} -> {| if $e1 then $e2 else $e3 |}
        | "if"; S{e1}; "then"; S{e2} -> {| if $e1 then $e2 |}
        | "do"; sequence{seq}; "done" -> FanOps.mksequence ~loc:_loc seq
        | "with"; lang{old}; S{x} -> begin  AstQuotation.default := old; x  end
        | "with";"{"; pos_exprs{old} ;"}"; S{x} -> begin AstQuotation.map := old; x end
        | "for"; a_lident{i}; "="; S{e1}; direction_flag{df}; S{e2}; "do";
            sequence{seq}; "done" ->
              {| for $i = $e1 $to:df $e2 do $seq done |}
        | "while"; S{e}; "do"; sequence{seq}; "done" ->
            {|while $e do $seq done |}   ]  
       ":=" NA
        [ S{e1}; ":="; S{e2} -> {| $e1 := $e2 |} 
        | S{e1}; "<-"; S{e2} -> (* FIXME should be deleted in original syntax later? *)
            match FanOps.bigarray_set _loc e1 e2 with
            [ Some e -> e
            | None -> `Assign(_loc,e1,e2) ] ]
       "||" RA
        [ S{e1}; infixop0{op}; S{e2} -> {| $op $e1 $e2 |} ]
       "&&" RA
        [ S{e1}; infixop1{op}; S{e2} -> {| $op $e1 $e2 |} ]
       "<" LA
        [ S{e1}; infixop2{op}; S{e2} -> {| $op $e1 $e2 |} ]
       "^" RA
        [ S{e1}; infixop3{op}; S{e2} -> {| $op $e1 $e2 |} ]
       "+" LA
        [ S{e1}; infixop4{op}; S{e2} -> {| $op $e1 $e2 |} ]
       "*" LA
        [ S{e1}; "land"; S{e2} -> {| $e1 land $e2 |}
        | S{e1}; "lor"; S{e2} -> {| $e1 lor $e2 |}
        | S{e1}; "lxor"; S{e2} -> {| $e1 lxor $e2 |}
        | S{e1}; "mod"; S{e2} -> {| $e1 mod $e2 |}
        | S{e1}; infixop5{op}; S{e2} -> {| $op $e1 $e2 |} ]
       "**" RA
        [ S{e1}; "asr"; S{e2} -> {| $e1 asr $e2 |}
        | S{e1}; "lsl"; S{e2} -> {| $e1 lsl $e2 |}
        | S{e1}; "lsr"; S{e2} -> {| $e1 lsr $e2 |}
        | S{e1}; infixop6{op}; S{e2} -> {| $op $e1 $e2 |} ]
       "obj" RA
        [
        (* FIXME fun and function duplicated *)      
         "fun"; "[";  L1 match_case0 SEP "|"{a}; "]" ->
           let cases = or_of_list1 a in `Fun (_loc,cases)
        | "function"; "[";  L1 match_case0 SEP "|"{a}; "]" ->
            let cases = or_of_list1 a in `Fun(_loc,cases)
        | "fun"; fun_def{e} -> e
        | "function"; fun_def{e} -> e
        | "object"; "(";patt{p}; ")"; class_structure{cst};"end" ->
            `ObjPat(_loc,p,cst)
        | "object"; "(";patt{p};":";ctyp{t};")";class_structure{cst};"end" ->
            `ObjPat(_loc,`Constraint(_loc,p,t),cst)
        | "object"; class_structure{cst};"end"->
            `Obj(_loc,cst)]
       "unary minus" NA
        [ "-"; S{e} -> FanOps.mkumin _loc "-" e
        | "-."; S{e} -> FanOps.mkumin _loc "-." e ]
       "apply" LA
        [ S{e1}; S{e2} -> {| $e1 $e2 |}
        | "assert"; S{e} -> FanOps.mkassert _loc e
        | "new"; class_longident{i} -> `New (_loc,i) (* {| new $i |} *)
        | "lazy"; S{e} -> {| lazy $e |} ]
       "label" NA
        [ "~"; a_lident{i}; ":"; S{e} ->
          {| ~ $i : $e |}
        | "~"; a_lident{i} -> `LabelS(_loc,i)
        (* Here it's LABEL and not tilde_label since ~a:b is different than ~a : b *)
        | `LABEL i; S{e} -> {| ~ $lid:i : $e |}
        (* Same remark for ?a:b *)
        | `OPTLABEL i; S{e} ->  `OptLabl(_loc,`Lid(_loc,i),e)
        | "?"; a_lident{i}; ":"; S{e} -> `OptLabl(_loc,i,e)
        | "?"; a_lident{i} -> `OptLablS(_loc,i) ] 
       "." LA
        [ S{e1}; "."; "("; S{e2}; ")" -> {| $e1 .( $e2 ) |}
        | S{e1}; "."; "["; S{e2}; "]" -> {| $e1 .[ $e2 ] |}
        | S{e1}; "."; "{"; comma_expr{e2}; "}" -> FanOps.bigarray_get _loc e1 e2
        | S{e1}; "."; S{e2} -> {| $e1 . $e2 |}
        | S{e}; "#"; a_lident{lab} -> {| $e # $lab |} ]
       "~-" NA
        [ "!"; S{e} ->  {| ! $e|}
        | prefixop{f}; S{e} -> {| $f $e |} ]
       "simple"
        [ `QUOTATION x -> AstQuotation.expand _loc x DynAst.expr_tag
        | `Ant (("exp"|""|"anti"|"`bool" |"tup"|"seq"|"int"|"`int"
                |"int32"|"`int32"|"int64"|"`int64"|"nativeint"|"`nativeint"
                |"flo"|"`flo"|"chr"|"`chr"|"str"|"`str" | "vrn" as n),s) ->
                    {| $(anti:mk_anti ~c:"expr" n s) |}
        | `INT(_,s) -> {|$int:s|}
        | `INT32(_,s) -> {|$int32:s|}
        | `INT64(_,s) -> {|$int64:s|}
        | `Flo(_,s) -> {|$flo:s|}
        | `CHAR(_,s) -> {|$chr:s|}
        | `STR(_,s) -> {|$str:s|}
        | `NATIVEINT(_,s) -> {|$nativeint:s|}
        | TRY module_longident_dot_lparen{i};S{e}; ")" ->
            {| let open $i in $e |}
        (* | TRY val_longident{i} -> {| $id:i |} *)
        | ident{i} -> {|$id:i|} (* FIXME logic was splitted here *)
        | "`"; luident{s} -> {| $vrn:s|}
        | "["; "]" -> {| [] |}
        | "[";sem_expr_for_list{mk_list}; "::"; expr{last}; "]" -> mk_list last
        | "["; sem_expr_for_list{mk_list}; "]" -> mk_list {| [] |}
        | "[|"; "|]" -> `ArrayEmpty(_loc)
        | "[|"; sem_expr{el}; "|]" -> {| [| $el |] |}

        | "{"; `Lid x ; "with"; label_expr_list{el}; "}" ->
            {| { ($lid:x) with $el }|} (* FIXME add antiquot support *)
        | "{"; label_expr_list{el}; "}" -> {| { $el } |}
        | "{"; "("; S{e}; ")"; "with"; label_expr_list{el}; "}" ->
            {| { ($e) with $el } |}
        | "{<"; ">}" -> `OvrInstEmpty(_loc)
        | "{<"; field_expr_list{fel}; ">}" -> `OvrInst(_loc,fel) 
        | "("; ")" -> {| () |}
        | "("; S{e}; ":"; ctyp{t}; ")" -> {| ($e : $t) |}
        | "("; S{e}; ","; comma_expr{el}; ")" -> {| ( $e, $el ) |}
        | "("; S{e}; ";"; sequence{seq}; ")" -> FanOps.mksequence ~loc:_loc {| $e; $seq |}
        | "("; S{e}; ";"; ")" -> FanOps.mksequence ~loc:_loc e
        | "("; S{e}; ":"; ctyp{t}; ":>"; ctyp{t2}; ")" ->
            {| ($e : $t :> $t2 ) |}
        | "("; S{e}; ":>"; ctyp{t}; ")" -> {| ($e :> $t) |}
        | "("; S{e}; ")" -> e
        | "begin"; sequence{seq}; "end" -> FanOps.mksequence ~loc:_loc seq
        | "begin"; "end" -> {| () |}
        | "("; "module"; module_expr{me}; ")" ->
            {| (module $me) |}
        | "("; "module"; module_expr{me}; ":"; (* package_type *)module_type{pt}; ")" ->
            {| (module $me : $pt) |}  ] }
       sequence: (*FIXME*)
       [ "let"; opt_rec{rf}; binding{bi}; "in"; expr{e}; sequence'{k} ->
         k {| let $rec:rf $bi in $e |}
       | "let"; "try"; opt_rec{r}; binding{bi}; "in"; S{x}; "with"; match_case{a}; sequence'{k}
         -> k {| let try $rec:r $bi in $x with [ $a ] |}
       | "let"; opt_rec{rf}; binding{bi}; ";"; S{el} ->
           {| let $rec:rf $bi in $(FanOps.mksequence ~loc:_loc el) |}
       | "let"; "module"; a_uident{m}; module_binding0{mb}; "in";
           expr{e}; sequence'{k} -> k {| let module $m = $mb in $e |}
       | "let"; "module"; a_uident{m}; module_binding0{mb}; ";"; S{el} ->
           {| let module $m = $mb in $(FanOps.mksequence ~loc:_loc el) |}
       | "let"; "open"; module_longident{i}; "in"; S{e} ->
           {| let open $id:i in $e |}
       (* FIXME Ant should be able to be followed *)      
       | `Ant (("list" as n),s) -> {| $(anti:mk_anti ~c:"expr;" n s) |}
       | expr{e}; sequence'{k} -> k e ]
       sequence':
       [ -> fun e -> e
       | ";" -> fun e -> e
       | ";"; sequence{el} -> fun e -> {| $e; $el |} ]       
       infixop1:
       [  [ "&" | "&&" ]{x} -> {| $lid:x |} ]
       infixop0:
       [  [ "or" | "||" ]{x} -> {| $lid:x |} ]
       sem_expr_for_list:
       [ expr{e}; ";"; S{el} -> fun acc -> {| [ $e :: $(el acc) ] |}
       | expr{e}; ";" -> fun acc -> {| [ $e :: $acc ] |}
       | expr{e} -> fun acc -> {| [ $e :: $acc ] |} ]
       comma_expr:
       [ S{e1}; ","; S{e2} -> {| $e1, $e2 |}
       | `Ant (("list" as n),s) -> {| $(anti:mk_anti ~c:"expr," n s) |}
       | expr Level "top"{e} -> e ]
       dummy:
       [ -> () ] |};

  with binding
      {:extend|
        binding_quot:
        [ binding{x} -> x  ] 
        binding:
        [ `Ant (("binding"|"list" as n),s) ->
          {| $(anti:mk_anti ~c:"binding" n s) |}
        | `Ant ((""|"anti" as n),s); "="; expr{e} ->
            {| $(anti:mk_anti ~c:"patt" n s) = $e |}
        | `Ant ((""|"anti" as n),s) -> {| $(anti:mk_anti ~c:"binding" n s) |}
        | S{b1}; "and"; S{b2} -> {| $b1 and $b2 |}
        | let_binding{b} -> b ] 
        let_binding:
        [ patt{p}; fun_binding{e} -> {| $p = $e |} ] |};

  with match_case
    {:extend|
      match_case:
      [ "["; L1 match_case0 SEP "|"{l}; "]" -> or_of_list1 l (* {|  $list:l  |} *) (* FIXME *)
      | patt{p}; "->"; expr{e} -> `Case(_loc,p,e)(* {| $pat:p -> $e |} *) ]
      match_case0:
      [ `Ant (("match_case"|"list"| "anti"|"" as n),s) ->
        `Ant (_loc, (mk_anti ~c:"match_case" n s))
      | patt_as_patt_opt{p}; "when"; expr{w};  "->"; expr{e} ->
           `CaseWhen (_loc, p, w, e)
      | patt_as_patt_opt{p}; "->";expr{e} -> `Case(_loc,p,e)]
      match_case_quot:
      [ L1 match_case0 SEP "|"{x} -> or_of_list1 x]  |};
  with rec_expr
      {:extend|
        rec_expr_quot:
        [ label_expr_list{x} -> x  ]
        label_expr:
        [ `Ant (("rec_expr" |""|"anti"|"list" as n),s) -> 
          `Ant (_loc, (mk_anti ~c:"rec_expr" n s))
        | label_longident{i}; fun_binding{e} -> {| $id:i = $e |}
        | label_longident{i} ->
            `RecBind (_loc, i, (`Id (_loc, (`Lid (_loc, (FanOps.to_lid i))))))]
        field_expr:
        [ `Ant ((""|"bi"|"anti" |"list" as n),s) -> {| $(anti:mk_anti ~c:"rec_expr" n s) |}
        | a_lident{l}; "=";  expr Level "top"{e} ->
            `RecBind (_loc, (l:>ident), e) (* {| $lid:l = $e |} *) ]
        label_expr_list:
        [ label_expr{b1}; ";"; S{b2} -> {| $b1 ; $b2 |}
        | label_expr{b1}; ";"            -> b1
        | label_expr{b1}                 -> b1  ]
        field_expr_list:
        [ field_expr{b1}; ";"; S{b2} -> {| $b1 ; $b2 |}
        | field_expr{b1}; ";"            -> b1
        | field_expr{b1}                 -> b1  ] |};
  with patt
    {:extend| local: patt_constr;
       patt_quot:
       [ patt{x}; ","; comma_patt{y} -> `Com(_loc,x,y)
       | patt{x}; ";"; sem_patt{y} -> `Sem(_loc,x,y)
       | patt{x} -> x]
       patt_as_patt_opt:
       [ patt{p1}; "as"; a_lident{s} -> {| ($p1 as $s) |}
       | patt{p} -> p ]
       patt_constr:
       [module_longident{i} -> {| $id:i |}

       |"`"; luident{s}  -> {| $vrn:s|}
       |`Ant ((""|"pat"|"anti"|"vrn" as n), s) -> {|$(anti:mk_anti ~c:"patt" n s)|} ]
       patt:
       { "|" LA
        [ S{p1}; "|"; S{p2} -> {| $p1 | $p2 |} ]
       ".." NA
        [ S{p1}; ".."; S{p2} -> {| $p1 .. $p2 |} ]
       "apply" LA
        [ patt_constr{p1}; S{p2} ->
          match p2 with
            [ {| ($tup:p) |} ->
              List.fold_left (fun p1 p2 -> {| $p1 $p2 |}) p1
                (list_of_com p []) (* precise *)
            | _ -> {|$p1 $p2 |}  ]
        | patt_constr{p1} -> p1
        | "lazy"; S{p} -> {| lazy $p |}  ]
       "simple"
        [ `Ant ((""|"pat"|"anti"|"tup"|"int"|"`int"|"int32"|"`int32"|"int64"|"`int64"
                |"vrn"
                |"nativeint"|"`nativeint"|"flo"|"`flo"|"chr"|"`chr"|"str"|"`str" as n),s)
          -> {| $(anti:mk_anti ~c:"patt" n s) |}
        | ident{i} -> {| $id:i |}
        | `INT(_,s) -> {|$int:s|}
        | `INT32(_,s) -> {|$int32:s|}
        | `INT64(_,s) -> {|$int64:s|}
        | `Flo(_,s) -> {|$flo:s|}
        | `CHAR(_,s) -> {|$chr:s|}
        | `STR(_,s) -> {|$str:s|}
        | "-"; `INT(_,s) -> {|$(int:String.neg s)|}
        | "-"; `INT32(_,s) -> {|$(int32:String.neg s)|}
        | "-"; `INT64(_,s) -> {|$(int64:String.neg s)|}
        | "-"; `NATIVEINT(_,s) -> {|$(int64:String.neg s)|}
        | "-"; `Flo(_,s) -> {|$(flo:String.neg s)|}
        | "["; "]" -> {| [] |}
        | "["; sem_patt_for_list{mk_list}; "::"; patt{last}; "]" -> mk_list last
        | "["; sem_patt_for_list{mk_list}; "]" -> mk_list {| [] |}
        | "[|"; "|]" -> `ArrayEmpty(_loc)
        | "[|"; sem_patt{pl}; "|]" -> `Array(_loc,pl)
        | "{"; label_patt_list{pl}; "}" -> `Record(_loc,pl)
            (* {| { $((pl : rec_patt :>patt)) } |} *)
        | "("; ")" -> {| () |}
        | "("; "module"; a_uident{m}; ")" -> `ModuleUnpack(_loc,m)
            (* {| (module $m) |} *)
        | "("; "module"; a_uident{m}; ":"; (* package_type *)module_type{pt}; ")" ->
            `ModuleConstraint(_loc,m, `Package(_loc,pt))
              (* {| ( module $m :  $pt )|} *)
        | "(";"module"; a_uident{m};":"; `Ant(("opt" as n),s ); ")" ->
            `ModuleConstraint (_loc, m, `Ant (_loc, (mk_anti n s)))
            (* {| (module $m : $(opt: `Ant(_loc,mk_anti n s)))|} *)
        | "("; S{p}; ")" -> p
        | "("; S{p}; ":"; ctyp{t}; ")" -> {| ($p : $t) |}
        | "("; S{p}; "as";  a_lident{s}; ")" -> {| ($p as $s )|}
        | "("; S{p}; ","; comma_patt{pl}; ")" -> {| ($p, $pl) |}
        | "`"; luident{s} -> {|$vrn:s|}
          (* duplicated may be removed later with [patt Level "apply"] *)
        | "#"; type_longident{i} -> {| # $i |}
        | `QUOTATION x -> AstQuotation.expand _loc x DynAst.patt_tag
        | "_" -> {| _ |}
        | `LABEL i; S{p} -> {| ~ $lid:i : $p |}
        | "~"; a_lident{i}; ":"; S{p} -> (* CHANGE *) {| ~$i : $p|}
        | "~"; a_lident{i} -> `LabelS(_loc,i)
        | `OPTLABEL i; "("; patt_tcon{p}; "="; expr{e}; ")" ->
            `OptLablExpr(_loc,`Lid(_loc,i),p,e)
            (* {| ?$lid:i : ($p=$e)|} *)
        | `OPTLABEL i; "("; patt_tcon{p}; ")"  ->
            `OptLabl(_loc,`Lid(_loc,i),p)
            (* {| ? $lid:i : ($p)|} *)
        | "?"; a_lident{i};":"; "("; patt_tcon{p}; "="; expr{e}; ")" ->
            `OptLablExpr(_loc,i,p,e)
            (* {| ?$i:($p=$e)|} *)
        | "?"; a_lident{i};":"; "("; patt_tcon{p}; "="; `Ant(("opt" as n),s); ")" ->
            `OptLablExpr (_loc, i, p, (`Ant (_loc, (mk_anti n s))))
            (* {| ?$i : ($p = $(opt: `Ant(_loc, mk_anti n s )) )|} *)
        | "?"; a_lident{i}; ":"; "("; patt_tcon{p}; ")"  ->
            `OptLabl(_loc,i,p)
            (* {| ? $i:($p)|} *)
        | "?"; a_lident{i} -> `OptLablS(_loc,i )
        | "?"; "("; ipatt_tcon{p}; ")" -> `OptLabl(_loc,`Lid(_loc,""),p) (* FIXME*)

        | "?"; "("; ipatt_tcon{p}; "="; expr{e}; ")" ->
            `OptLablExpr(_loc,`Lid(_loc,""),p,e)
            (* {| ? ($p = $e) |}; *)
        ] }
       ipatt:
        [ "{"; label_patt_list{pl}; "}" ->
          {| { $pl }|}
          (* {| { $((pl: rec_patt :>patt)) } |} *)
        | `Ant ((""|"pat"|"anti"|"tup" as n),s) -> {| $(anti:mk_anti ~c:"patt" n s) |}
        | "("; ")" -> {| () |}
        | "("; "module"; a_uident{m}; ")" -> `ModuleUnpack(_loc,m)
            (* {| (module $m) |} *)
        | "("; "module"; a_uident{m}; ":"; (* package_type *)module_type{pt}; ")" ->
             `ModuleConstraint (_loc, m, ( (`Package (_loc, pt))))
              (* {| (module $m : $pt )|} *)
        | "(";"module"; a_uident{m};":"; `Ant(("opt" as n),s ); ")" ->
             `ModuleConstraint (_loc, m, (`Ant (_loc, (mk_anti n s))))
            (* {| (module $m : $(opt: `Ant(_loc,mk_anti n s)))|} *)
        | "("; S{p}; ")" -> p
        | "("; S{p}; ":"; ctyp{t}; ")" -> {| ($p : $t) |}
        | "("; S{p}; "as"; a_lident{s}; ")" -> {| ($p as $s) |}
        | "("; S{p}; ","; comma_ipatt{pl}; ")" -> {| ($p, $pl) |}
        | a_lident{s} -> {| $(id:(s:>ident)) |}
        | `QUOTATION x -> AstQuotation.expand _loc x DynAst.patt_tag                            
        | "_" -> {| _ |}
        | `LABEL i; S{p} -> {| ~ $lid:i : $p |}
        | "~"; a_lident{i};":";S{p} -> {| ~$i : $p|}
        | "~"; a_lident{i} ->  `LabelS(_loc,i)
        | `OPTLABEL i; "("; patt_tcon{p}; "="; expr{e}; ")" ->
            `OptLablExpr(_loc,`Lid(_loc,i),p,e)
            (* {| ?$lid:i : ($p=$e)|} *)
        | `OPTLABEL i; "("; patt_tcon{p}; ")"  ->
            `OptLabl(_loc,`Lid(_loc,i),p)
            (* {| ? $lid:i : ($p)|} *)
        | "?"; a_lident{i};":"; "("; patt_tcon{p}; "="; expr{e}; ")" ->
            `OptLablExpr(_loc,i,p,e)
            (* {| ?$i:($p=$e)|} *)
        | "?"; a_lident{i};":"; "("; patt_tcon{p}; "="; `Ant(("opt" as n),s); ")" ->
            `OptLablExpr (_loc, i, p, (`Ant (_loc, (mk_anti n s))))
            (* {| ?$i : ($p = $(opt: `Ant(_loc, mk_anti n s )) )|} *)
        | "?"; a_lident{i}; ":"; "("; patt_tcon{p}; ")"  ->
            `OptLabl(_loc,i,p)
            (* {| ? $i:($p)|} *)
        | "?"; a_lident{i} -> `OptLablS(_loc,i ) 
        | "?"; "("; ipatt_tcon{p}; ")" ->
            `OptLabl(_loc,`Lid(_loc,""),p)
            (* {| ? ($p) |} *)
        | "?"; "("; ipatt_tcon{p}; "="; expr{e}; ")" ->
            `OptLablExpr(_loc,`Lid(_loc,""),p,e)
            (* {| ? ($p = $e) |} *)
   ]
       sem_patt:
       [`Ant (("list" as n),s) -> {| $(anti:mk_anti ~c:"patt;" n s) |}
       | patt{p1}; ";"; S{p2} -> `Sem(_loc,p1,p2)
       | patt{p}; ";" -> p
       | patt{p} -> p ] 
       sem_patt_for_list:
       [ patt{p}; ";"; S{pl} -> fun acc -> {| [ $p :: $(pl acc) ] |}
       | patt{p}; ";" -> fun acc -> {| [ $p :: $acc ] |}
       | patt{p} -> fun acc -> {| [ $p :: $acc ] |}  ]
       patt_tcon:
       [ patt{p}; ":"; ctyp{t} -> {| ($p : $t) |}
       | patt{p} -> p ]
       ipatt_tcon:
       [ `Ant((""|"anti" as n),s) -> {| $(anti:mk_anti ~c:"patt" n s ) |}
       | a_lident{i} -> {|$(id:(i:>ident))|}
       | a_lident{i}; ":"; ctyp{t} -> {| ($(id:(i:>ident)) : $t) |}]
       comma_ipatt:
       [ S{p1}; ","; S{p2} -> {| $p1, $p2 |}
       | `Ant (("list" as n),s) -> {| $(anti:mk_anti ~c:"patt," n s) |}
       | ipatt{p} -> p ]
       comma_patt:
       [ S{p1}; ","; S{p2} -> {| $p1, $p2 |}
       | `Ant (("list" as n),s) -> {| $(anti:mk_anti ~c:"patt," n s) |}
       | patt{p} -> p ]
       label_patt_list:
       [ label_patt{p1}; ";"; S{p2} -> {| $p1 ; $p2 |}
       | label_patt{p1}; ";"; "_"       -> {| $p1 ; _ |}
       | label_patt{p1}; ";"; "_"; ";"  -> {| $p1 ; _ |}
       | label_patt{p1}; ";"            -> p1
       | label_patt{p1}                 -> p1   ] 
       label_patt:
       [ `Ant ((""|"pat"|"anti" as n),s) -> {| $(anti:mk_anti ~c:"patt" n s) |}
       (* | `QUOTATION x -> AstQuotation.expand _loc x DynAst.patt_tag
        *) (* FIXME restore it later *)
       | `Ant (("list" as n),s) -> {| $(anti:mk_anti ~c:"patt;" n s) |}
       | label_longident{i}; "="; patt{p} -> (* {| $i = $p |} *) `RecBind(_loc,i,p)
       | label_longident{i} ->
           `RecBind(_loc,i,`Id(_loc,`Lid(_loc,FanOps.to_lid i)))
           (* {| $i = $(lid:Ident.to_lid i) |} *)
       ] |};
    
    with ident
    {:extend|

      (* parse [a] [B], depreacated  *)

      luident: [`Lid i -> i | `Uid i -> i]
      (* parse [a] [B] *)
      aident: [ a_lident{i} -> (i:>ident) | a_uident{i} -> (i:>ident)]
      astr:
      [`Lid i -> `C (_loc,i) | `Uid i -> `C(_loc,i) |
      `Ant (n,s) -> `Ant(_loc,mk_anti n s)]
      ident_quot:
      { "."
        [ S{i}; "."; S{j} -> {| $i.$j  |} ]
        "simple"
        [ `Ant ((""|"id"|"anti"|"list" |"uid" as n),s) ->
          `Ant (_loc, (mk_anti ~c:"ident" n s))
        | `Ant (("lid" as n), s) -> `Ant (_loc, (mk_anti ~c:"ident" n s))
        | `Ant ((""|"id"|"anti"|"list"|"uid" as n),s); "."; S{i} ->
            `Dot (_loc, (`Ant (_loc, (mk_anti ~c:"ident" n s))), i)
        | `Lid i -> {| $lid:i |}
        | `Uid i -> {| $uid:i |}
        | `Uid s ; "." ; S{j} -> {|$uid:s.$j|}
        | "("; S{i};S{j}; ")" -> `App _loc i j  ] }

      (* parse [a] [b], [a.b] [A.b]*)
      ident:
      [ `Ant ((""|"id"|"anti"|"list" |"uid" as n),s) -> `Ant (_loc, mk_anti ~c:"ident" n s)
      | `Ant (("lid" as n), s) -> `Ant (_loc, mk_anti ~c:"ident" n s)
      | `Ant ((""|"id"|"anti"|"list"|"uid" as n),s); "."; S{i} ->
           `Dot (_loc, (`Ant (_loc, (mk_anti ~c:"ident" n s))), i)
      | `Lid i -> `Lid(_loc,i)
      | `Uid i -> `Uid(_loc,i)
      | `Uid s ; "." ; S{j} ->  `Dot (_loc, `Uid (_loc, s), j)]

      uident:
      [`Uid s -> `Uid(_loc,s)
      | `Ant((""|"id"|"anti"|"list"|"uid" as n),s) ->
          `Ant(_loc,mk_anti ~c:"uident" n s)
      |`Uid s; "."; S{l} -> dot (`Uid (_loc,s)) l
      |`Ant((""|"id"|"anti"|"list"|"uid" as n),s) ;"." ; S{i} ->
          dot (`Ant(_loc,mk_anti ~c:"uident" n s)) i]


      dot_namespace:
      [ `Uid i; "."; S{xs} -> [i::xs]
      | `Uid i -> [i]]
      (* parse [a.b.c] no antiquot *)
      dot_lstrings:
      [ `Lid i -> (`Sub[],i)
      | `Uid i ; "." ; S {xs} ->
          match xs with
          [(`Sub xs,v) -> (`Sub [i::xs],v)
          | _ -> raise (XStream.Error "impossible dot_lstrings")]  

      | "."; `Uid i; "."; S{xs} ->
          match xs with
          [(`Sub xs,v) -> (`Absolute [i::xs],v)
          | _ -> raise (XStream.Error "impossible dot_lstrings") ]]

      (* parse [A.B.(] *)
      module_longident_dot_lparen:
      [ `Ant ((""|"id"|"anti"|"list"|"uid" as n),s); "."; "(" ->
        {| $(anti:mk_anti ~c:"ident" n s) |}

      | `Uid i; "."; S{l} -> {|$uid:i.$l|}
      | `Uid i; "."; "(" -> {|$uid:i|}
      | `Ant (("uid"|"" as n),s); "."; S{l} -> {| $(anti:mk_anti ~c:"ident" n s).$l|} ]
      (* parse [A.B] *)
      module_longident:
      [ `Ant ((""|"id"|"anti"|"list" as n),s) ->
        {| $(anti:mk_anti ~c:"ident" n s) |}
      | `Uid i; "."; S{l} -> {| $uid:i.$l|}
      | `Uid i -> {|$uid:i|}
      | `Ant ((""|"uid" as n),s) -> {| $(anti:mk_anti ~c:"ident" n s) |}
      | `Ant((""|"uid" as n), s); "."; S{l} -> {| $(anti:mk_anti ~c:"ident" n s).$l |} ]

      module_longident_with_app:
      { "apply"
        [ S{i}; S{j} -> {| ($i $j) |} ]
       "."
        [ S{i}; "."; S{j} -> {| $i.$j |} ]
       "simple"
        [ `Ant ((""|"id"|"anti"|"list"|"uid" as n),s) ->
          `Ant (_loc, (mk_anti ~c:"ident" n s))
        | `Uid i -> `Uid(_loc,i)
        | "("; S{i}; ")" -> i ] }

      (* parse [(A B).c ]*)
      type_longident: (* FIXME *)
      { "apply" (* No parens *)
        [ S{i}; S{j} -> {| ($i $j) |} ]
        "."
        [ S{i}; "."; S{j} -> {| $i.$j |} ]
        "simple"
        [ `Ant ((""|"id"|"anti"|"list"|"uid"|"lid" as n),s) ->
          {| $(anti:mk_anti ~c:"ident" n s) |}
        | `Lid i -> {|$lid:i|}
        | `Uid i -> {|$uid:i|}
        | "("; S{i}; ")" -> i ] }

      label_longident:
      [ `Ant ((""|"id"|"anti"|"list"|"lid" as n),s) ->
        {| $(anti:mk_anti ~c:"ident" n s) |}
      | `Lid i -> {|$lid:i|}
      | `Uid i; "."; S{l} -> {|$uid:i.$l|}
      | `Ant((""|"uid" as n),s); "."; S{l} -> {|$(anti:mk_anti ~c:"ident" n s).$l|} ]
      
      class_type_longident: [ type_longident{x} -> x ]
      val_longident:[ ident{x} -> x ]
      class_longident:
      [ label_longident{x} -> x ]
      
      method_opt_override:
      [ "method"; "!" -> {:override_flag| ! |}
      | "method"; `Ant (((""|"override"|"anti") as n),s) ->
          `Ant (_loc,mk_anti ~c:"override_flag" n s)
            (* {:override_flag|$(anti:mk_anti ~c:"override_flag" n s)|} *)
      | "method" -> {:override_flag||}  ] 
      opt_override:
      [ "!" -> {:override_flag| ! |}
      | `Ant ((("!"|"override"|"anti") as n),s) ->
          (* {:override_flag|$(anti:mk_anti ~c:"override_flag" n s) |} *)
          `Ant (_loc,mk_anti ~c:"override_flag" n s)
      | -> {:override_flag||} ]
      
      value_val_opt_override:
      [ "val"; "!" -> {:override_flag| ! |}
      | "val"; `Ant (((""|"override"|"anti"|"!") as n),s) ->
          (* {:override_flag|$(anti:mk_anti ~c:"override_flag" n s) |} *)
            `Ant (_loc,mk_anti ~c:"override_flag" n s)
      | "val" -> {:override_flag||}   ] 
      (* opt_as_lident: *)
      (* [ "as"; a_lident{i} -> `Some (i) *)
      (* | -> `None *)
      (* | `Ant ((""|"as") as n,s) -> `Ant(_loc, mk_anti n s)]  *)

      direction_flag:
      [ "to" -> {:direction_flag| to |}
      | "downto" -> {:direction_flag| downto |}
      | `Ant (("to"|"anti"|"" as n),s) ->
          (* {:direction_flag|$(anti:mk_anti ~c:"direction_flag" n s)|} *)
          `Ant (_loc,mk_anti ~c:"direction_flag" n s)
      ]

      opt_private:
      [ "private" -> {:private_flag| private |}
      | `Ant (("private"|"anti" as n),s) ->
          (* {:private_flag| $(anti:mk_anti ~c:"private_flag" n s)|} *)
          `Ant (_loc,mk_anti ~c:"private_flag" n s)
      | -> {:private_flag||}  ] 
      opt_mutable:
      [ "mutable" -> {:mutable_flag| mutable |}
      | `Ant (("mutable"|"anti" as n),s) ->
          (* {:mutable_flag| $(anti:mk_anti ~c:"mutable_flag" n s) |} *)
          `Ant (_loc,mk_anti ~c:"mutable_flag" n s)
      | -> {:mutable_flag||}  ] 
      opt_virtual:
      [ "virtual" -> {:virtual_flag| virtual |}
      | `Ant (("virtual"|"anti" as n),s) ->
          (* {:virtual_flag|$(anti:(mk_anti ~c:"virtual_flag" n s))|} *)
            (* let _ =  *)`Ant (_loc,mk_anti ~c:"virtual_flag" n s)
      | -> {:virtual_flag||}  ] 
      opt_dot_dot:
      [ ".." -> {:row_var_flag| .. |}
      | `Ant ((".."|"anti" as n),s) ->
          (* {:row_var_flag|$(anti:mk_anti ~c:"row_var_flag" n s) |} *)
          (* let _ =  *)`Ant (_loc,mk_anti ~c:"row_var_flag" n s)
      | -> {:row_var_flag||}  ]

      (*opt_rec@inline *)
      opt_rec:
      [ "rec" -> {:rec_flag| rec |}
      | `Ant (("rec"|"anti" as n),s) ->
          (* {:rec_flag|$(anti:mk_anti ~c:"rec_flag" n s) |} *)
            `Ant (_loc,mk_anti ~c:"rec_flag" n s)
      | -> {:rec_flag||} ] 

      a_string:
      [ `Ant((""|"lid") as n,s) -> `Ant (_loc, mk_anti n s)
      |  `Lid s -> `C (_loc, s )
      |  `Uid s -> `C (_loc,s)]
      a_lident:
      [ `Ant((""|"lid") as n,s) -> `Ant (_loc,mk_anti ~c:"a_lident" n s)
      | `Lid s  -> `Lid (_loc, s) ]
      a_uident:
      [ `Ant((""|"uid") as n,s) -> `Ant (_loc,mk_anti ~c:"a_uident" n s)
      | `Uid s  -> `Uid (_loc, s) ]
      string_list:
      [ `Ant ((""(* |"str_list" *)),s) -> `Ant (_loc,mk_anti "str_list" s)
      | `Ant("",s) ; S{xs} -> `App(_loc,`Ant(_loc,mk_anti "" s), xs)
      | `STR (_, x) -> `Str(_loc,x)
      | `STR (_, x); S{xs} -> `App(_loc,`Str(_loc,x),xs)
          (* `LCons (x, xs) *)] 
      semi: [ ";" -> () ]
      rec_flag_quot:  [ opt_rec{x} -> x ]
      direction_flag_quot:  [ direction_flag{x} -> x ] 
      mutable_flag_quot: [  opt_mutable{x} -> x ] 
      private_flag_quot: [  opt_private{x} -> x ]
      virtual_flag_quot: [  opt_virtual{x} -> x ] 
      row_var_flag_quot: [  opt_dot_dot{x} -> x ] 
      override_flag_quot:[  opt_override{x} -> x ] 
      patt_eoi:  [ patt{x}; `EOI -> x ] 
      expr_eoi:  [ expr{x}; `EOI -> x ]  |};
  with str_item
    {:extend|
    (* ml entrance *)    
      implem:
      [ "#"; a_lident{n}; expr{dp}; ";;" ->
        ([ `Directive(_loc,n,dp) ],  Some _loc)
      | "#"; a_lident{n}; ";;" ->
        ([`DirectiveSimple(_loc,n)], Some _loc)
      | "#";"import"; dot_namespace{x};";;" -> 
          (FanToken.paths := [ `Absolute  x :: !FanToken.paths];
            ([`DirectiveSimple(_loc,`Lid(_loc,"import"))],Some _loc))

      | str_item{si}; semi;  S{(sil, stopped)} -> ([si :: sil], stopped)
      | `EOI -> ([], None) ]
      str_items: (* FIXME dump seems to be incorrect *)
      [ `Ant ((""|"stri"|"anti"|"list" as n),s) -> {| $(anti:mk_anti n ~c:"str_item" s) |}
      | `Ant ((""|"stri"|"anti"|"list" as n),s); semi; S{st} -> {| $(anti:mk_anti n ~c:"str_item" s); $st |}
      | L1 [ str_item{st}; semi -> st ]{l} -> sem_of_list1 l (* {| $list:l |} *) ]
      top_phrase:
      [ "#"; a_lident{n}; expr{dp}; ";;" -> Some (`Directive(_loc,n,dp))
      | "#"; a_lident{n}; ";;" -> Some (`DirectiveSimple(_loc,n))

      | "#";"import"; dot_namespace{x} -> 
            (FanToken.paths := [ `Absolute  x :: !FanToken.paths];
            None)
      | str_item{st}; semi -> Some st
      | `EOI -> None ]
      str_item_quot:
      [ "#"; a_lident{n}; expr{dp} -> `Directive(_loc,n,dp)
      | "#"; a_lident{n} -> `DirectiveSimple(_loc,n)
      | str_item{st1}; semi; S{st2} -> `Sem(_loc,st1,st2)
      | str_item{st} -> st]

      str_item:
      { "top"
        [ "exception"; constructor_declaration{t} ->
            (* {| exception $t |} *)
            `Exception(_loc,t)
        (* | "exception"; constructor_declaration{t}; "="; type_longident{i} -> *)
        (*     {| exception $t = $i |} *)
        | "external"; a_lident{i};":"; ctyp{t};"="; string_list{sl} ->
            `External (_loc, i, t, sl)
            (* {| external $i: $t = $sl |} *)
              
        | "include"; module_expr{me} -> {| include $me |}
        | "module"; a_uident{i}; module_binding0{mb} ->
            {| module $i = $mb |}
        | "module"; "rec"; module_binding{mb} ->
            {| module rec $mb |}
        | "module"; "type"; a_uident{i}; "="; module_type{mt} ->
            {| module type $i = $mt |}
        | "open"; module_longident{i} -> {| open $i |}
        | "type"; type_declaration{td} ->
            {| type $td |}
        | "let"; opt_rec{r}; binding{bi}; "in"; expr{x} ->
              {| let $rec:r $bi in $x |}
        | "let"; opt_rec{r}; binding{bi} ->   match bi with
            [ {:binding| _ = $e |} -> {| $exp:e |}
            | _ -> {| let $rec:r $bi |} ]
        | "let"; "module"; a_uident{m}; module_binding0{mb}; "in"; expr{e} ->
              {| let module $m = $mb in $e |}
        | "let"; "open"; module_longident{i}; "in"; expr{e} -> {| let open $id:i in $e |}
              
        | "let"; "try"; opt_rec{r}; binding{bi}; "in"; expr{x}; "with"; match_case{a} ->
            {| let try $rec:r $bi in $x with [ $a ]|}
        | "class"; class_declaration{cd} ->  `Class(_loc,cd)
        | "class"; "type"; class_type_declaration{ctd} ->
            `ClassType (_loc, ctd)
        | `Ant ((""|"stri"|"anti"|"list" as n),s) ->
            {| $(anti:mk_anti ~c:"str_item" n s) |}
        | `QUOTATION x -> AstQuotation.expand _loc x DynAst.str_item_tag
        | expr{e} -> `StExp(_loc,e)
              (* this entry makes {| let $rec:r $bi in $x |} parsable *)
        ] }   |};

  with class_sig_item
    {:extend|
      class_sig_item_quot:
      [ class_sig_item{x1}; semi; S{x2} ->
        (* match x2 with *)
        (* [ `Nil _ -> x1 *)
        (* | _ -> *) `Sem(_loc,x1,x2) (* ] *)
      | class_sig_item{x} -> x
      (* | -> `Nil _loc  *)]
      class_signature:
      [ `Ant ((""|"csg"|"anti"|"list" as n),s) -> {| $(anti:mk_anti ~c:"class_sig_item" n s) |}
      | `Ant ((""|"csg"|"anti"|"list" as n),s); semi; S{csg} ->
          {| $(anti:mk_anti ~c:"class_sig_item" n s); $csg |}
      | L1 [ class_sig_item{csg}; semi -> csg ]{l} -> sem_of_list1 l ]
      class_sig_item:
      [ `Ant ((""|"csg"|"anti"|"list" as n),s) -> {| $(anti:mk_anti ~c:"class_sig_item" n s) |}
      | `QUOTATION x -> AstQuotation.expand _loc x DynAst.class_sig_item_tag
      | "inherit"; class_type{cs} ->
          `SigInherit(_loc,cs)
          (* {| inherit $cs |} *)
      | "val"; opt_mutable{mf}; opt_virtual{mv};a_lident{l}; ":"; ctyp{t} ->
          {| val $mutable:mf $virtual:mv $l : $t |}
      | "method"; "virtual"; opt_private{pf}; a_lident{l}; ":"; (* poly_type *)ctyp{t} ->
          {| method virtual $private:pf $l : $t |}
      | "method"; opt_private{pf}; a_lident{l}; ":"; (* poly_type *)ctyp{t} ->
          {| method $private:pf $l : $t |}
      | (* type_constraint *)"constraint"; ctyp{t1}; "="; ctyp{t2} ->
          (* {| type $t1 = $t2 |} *) {|constraint $t1 = $t2|} ] |};  
  with class_str_item
    {:extend|
      class_structure:
        [ `Ant ((""|"cst"|"anti"|"list" as n),s) -> {| $(anti:mk_anti ~c:"class_str_item" n s) |}
        | `Ant ((""|"cst"|"anti"|"list" as n),s); semi; S{cst} ->
            {| $(anti:mk_anti ~c:"class_str_item" n s); $cst |}
        | L0 [ class_str_item{cst}; semi -> cst ]{l} -> sem_of_list l  ]
      class_str_item:
        [ `Ant ((""|"cst"|"anti"|"list" as n),s) ->
            {| $(anti:mk_anti ~c:"class_str_item" n s) |}
        | `QUOTATION x -> AstQuotation.expand _loc x DynAst.class_str_item_tag
        | "inherit"; opt_override{o}; class_expr{ce}(* ; opt_as_lident{pb} *) ->
            `Inherit(_loc,o,ce)
            (* `InheritAs(_loc,o,ce,pb) *)
            (* {| inherit $!:o $ce $as:pb |} *)
        | "inherit"; opt_override{o}; class_expr{ce}; "as"; a_lident{i} ->
            `InheritAs(_loc,o,ce,i)
        | value_val_opt_override{o}; opt_mutable{mf}; a_lident{lab}; cvalue_binding{e}
          ->
            {| val $override:o $mutable:mf $lab = $e |}
        | value_val_opt_override{o}; "virtual"; opt_mutable{mf}; a_lident{l}; ":";
                (* poly_type *)ctyp{t} ->
                match o with
                [ {:override_flag@_||} ->{| val virtual $mutable:mf $l : $t |}
                | _ -> raise (XStream.Error "override (!) is incompatible with virtual")]                    
        | method_opt_override{o}; "virtual"; opt_private{pf}; a_lident{l}; ":";
                (* poly_type *)ctyp{t} ->
                match o with
                [ {:override_flag@_||} -> {| method virtual $private:pf $l : $t |}
                | _ -> raise (XStream.Error "override (!) is incompatible with virtual")]  
        | method_opt_override{o}; opt_private{pf}; a_lident{l}; opt_polyt{topt};
                fun_binding{e} ->
            {| method $override:o $private:pf $l : $topt = $e |}
        | (* type_constraint *) "constraint"; ctyp{t1}; "="; ctyp{t2} ->
            (* {| type $t1 = $t2 |} *) {|constraint $t1 = $t2|}
        | "initializer"; expr{se} -> {| initializer $se |} ]
      class_str_item_quot:
        [ class_str_item{x1}; semi; S{x2} ->
          match x2 with
          [ `Nil _ -> x1
          | _ -> `Sem(_loc,x1,x2) ]
        | class_str_item{x} -> x
        | -> `Nil _loc ]
    |};
    
  with class_expr
    {:extend|
      class_expr_quot:
      [ S{ce1}; "and"; S{ce2} -> {| $ce1 and $ce2 |}
      | S{ce1}; "="; S{ce2} -> {| $ce1 = $ce2 |}
      | "virtual";   class_name_and_param{(i, ot)} ->
          `CeCon (_loc, `Virtual _loc, (i :>ident), ot)
            (* {| virtual $((i:>ident)) [ $ot ]|} *)
      | `Ant (("virtual" as n),s); ident{i}; opt_comma_ctyp{ot} ->
          let anti = `Ant (_loc,mk_anti ~c:"class_expr" n s) in
          `CeCon (_loc, anti, i, ot)
          (* {| $virtual:anti $id:i [ $ot ] |} *)
      | class_expr{x} -> x
      | -> `Nil _loc  ]
      class_declaration:
      [ S{c1}; "and"; S{c2} -> {| $c1 and $c2 |}
      | `Ant ((""|"cdcl"|"anti"|"list" as n),s) -> {| $(anti:mk_anti ~c:"class_expr" n s) |}
      | `QUOTATION x -> AstQuotation.expand _loc x DynAst.class_expr_tag
      | class_info_for_class_expr{ci}; class_fun_binding{ce} -> {| $ci = $ce |} ]
      class_fun_binding:
      [ "="; class_expr{ce} -> ce
      | ":"; class_type_plus{ct}; "="; class_expr{ce} -> {| ($ce : $ct) |}
      | ipatt{p}; S{cfb} -> {| fun $p -> $cfb |}  ]
      class_info_for_class_expr:
      [ opt_virtual{mv};  class_name_and_param{(i, ot)} ->
        `CeCon(_loc,mv,(i:>ident),ot)  ]
      class_fun_def:
      [ ipatt{p}; S{ce} -> {| fun $p -> $ce |}  | "->"; class_expr{ce} -> ce ]
      class_expr:
      { "top"
          [ "fun"; ipatt{p}; class_fun_def{ce} -> {| fun $p -> $ce |}
          | "function"; ipatt{p}; class_fun_def{ce} -> {| fun $p -> $ce |}
          | "let"; opt_rec{rf}; binding{bi}; "in"; S{ce} ->
              {| let $rec:rf $bi in $ce |} ]
        "apply" NA
          [ S{ce}; expr Level "label"{e} -> {| $ce $e |} ]
        "simple"
          [ `Ant ((""|"cexp"|"anti" as n),s) -> {| $(anti:mk_anti ~c:"class_expr" n s) |}
          | `QUOTATION x -> AstQuotation.expand _loc x DynAst.class_expr_tag
          | class_longident_and_param{ce} -> ce
          | "object"; "("; patt{p}; ")" ; class_structure{cst};"end" ->
              `ObjPat(_loc,p,cst)
          | "object";"("; patt{p};":";ctyp{t};")"; class_structure{cst};"end" ->
              `ObjPat(_loc,`Constraint(_loc,p,t),cst)
          | "object"; class_structure{cst};"end" ->
              `Obj(_loc,cst)
          | "("; S{ce}; ":"; class_type{ct}; ")" -> {| ($ce : $ct) |}
          | "("; S{ce}; ")" -> ce ] }
      class_longident_and_param:
      [ class_longident{ci}; "["; comma_ctyp{t}; "]" ->
        `CeCon (_loc, (`ViNil _loc), ci, t)
          (* {| $id:ci [ $t ] |} *)
      | class_longident{ci} -> {| $id:ci |}  ]  |};
  with class_type
    {:extend|
      class_description:
      [ S{cd1}; "and"; S{cd2} -> {| $cd1 and $cd2 |}
      | `Ant ((""|"typ"|"anti"|"list" as n),s) ->
          {| $(anti:mk_anti ~c:"class_type" n s) |}
      | `QUOTATION x -> AstQuotation.expand _loc x DynAst.class_type_tag
      | class_info_for_class_type{ci}; ":"; class_type_plus{ct} -> {| $ci : $ct |}  ]
      class_type_declaration:
      [ S{cd1}; "and"; S{cd2} -> {| $cd1 and $cd2 |}
      | `Ant ((""|"typ"|"anti"|"list" as n),s) -> {| $(anti:mk_anti ~c:"class_type" n s) |}
      | `QUOTATION x -> AstQuotation.expand _loc x DynAst.class_type_tag
      | class_info_for_class_type{ci}; "="; class_type{ct} -> {| $ci = $ct |} ]
      class_info_for_class_type:
      [ opt_virtual{mv};  class_name_and_param{(i, ot)} ->
        `CtCon (_loc, mv, (i :>ident), ot)
        (* {| $virtual:mv $(id:(i:>ident)) [ $ot ] |} *) ]
      class_type_quot:
      [ S{ct1}; "and"; S{ct2} -> {| $ct1 and $ct2 |}
      | S{ct1}; "="; S{ct2} -> {| $ct1 = $ct2 |}
      | S{ct1}; ":"; S{ct2} -> {| $ct1 : $ct2 |}
      | "virtual";  class_name_and_param{(i, ot)} ->
          `CtCon (_loc, `Virtual _loc, (i :>ident), ot)
          (* {| virtual $((i:>ident)) [ $ot ] |} (\* types *\) *)
      | `Ant (("virtual" as n),s); ident{i}; opt_comma_ctyp{ot} ->
          let anti = `Ant (_loc,mk_anti ~c:"class_type" n s) in
          `CtCon (_loc, anti, i, ot)
          (* {| $virtual:anti $id:i [ $ot ] |} *)
      | class_type_plus{x} -> x
      | -> `Nil _loc   ]
      class_type_plus:
      [ "["; ctyp{t}; "]"; "->"; S{ct} -> {| [ $t ] -> $ct |}
      | class_type{ct} -> ct ]
      class_type:
      [ `Ant ((""|"ctyp"|"anti" as n),s) -> {| $(anti:mk_anti ~c:"class_type" n s) |}
      | `QUOTATION x -> AstQuotation.expand _loc x DynAst.class_type_tag
      | class_type_longident_and_param{ct} -> ct

      | "object"; opt_class_self_type{cst}; class_signature{csg}; "end" ->
          `CtSig(_loc,cst,csg)
      | "object";opt_class_self_type{cst};"end" ->
          `CtSigEnd(_loc,cst)
      ]
      
      class_type_longident_and_param:
      [ class_type_longident{i}; "["; comma_ctyp{t}; "]" ->
        `CtCon (_loc, (`ViNil _loc), i, t)
        (* {| $id:i [ $t ] |} *)
      | class_type_longident{i} -> {| $id:i |}   ] |} ;
end;


let apply_ctyp () = begin
  with ctyp
    {:extend|
      ctyp_quot:
      [
       (* more_ctyp{x}; ","; comma_ctyp{y} ->         `Com(_loc,x,y) *)
      (* | *) more_ctyp{x}; "*"; star_ctyp{y} -> `Sta (_loc, x, y)
      | more_ctyp{x} -> x
      | -> `Nil _loc  ]
      more_ctyp:
      [ctyp{x} -> x |
      type_parameter{x} -> x   ]
      unquoted_typevars:
      [ S{t1}; S{t2} -> {| $t1 $t2 |}
      | `Ant ((""|"typ" as n),s) ->  {| $(anti:mk_anti ~c:"ctyp" n s) |}
      | `QUOTATION x -> AstQuotation.expand _loc x DynAst.ctyp_tag
      | a_lident{i} -> `Id(_loc,(i:>ident))]
      type_parameter:
      [ `Ant ((""|"typ"|"anti" as n),s) -> `Ant (_loc, (mk_anti n s))
        (* {| $(anti:mk_anti n s) |} *)
      | `QUOTATION x -> AstQuotation.expand _loc x DynAst.ctyp_tag
      | "'"; a_lident{i} ->
          (* `Quote(_loc,`Normal _loc, `Some i) *)
          `Quote(_loc,`Normal _loc, i)
          (* {| '$i |} *)
      | "+"; "'"; a_lident{i} ->
          `Quote (_loc, `Positive _loc,  i)
          (* `Quote (_loc, `Positive _loc, (`Some i)) *)
          (* {| +'$i |} *)
      | "-"; "'"; a_lident{i} ->
          `Quote (_loc, (`Negative _loc),  i)
          (* {| -'$i |} *)
      | "+"; "_" -> `QuoteAny (_loc, `Positive _loc)
          (* {| + _|} *)
      | "-"; "_" -> `QuoteAny (_loc, `Negative _loc)
          (* {| - _ |} *)
      | "_" ->  `Any _loc (* {| _ |} *)]
      type_longident_and_parameters:
      [ "("; type_parameters{tpl}; ")";type_longident{i} -> tpl {| $id:i|}
      | type_parameter{tpl} ; type_longident{i} -> `App(_loc,{|$id:i|},tpl)
      | type_longident{i} -> {|$id:i|} 
      | `Ant ((""|"anti" as n),s) -> {|$(anti:mk_anti n s ~c:"ctyp")|} ]
      type_parameters:
      [ type_parameter{t1}; S{t2} -> fun acc -> t2 {| $acc $t1 |}
      | type_parameter{t} -> fun acc -> {| $acc $t |}
      | -> fun t -> t  ]
      opt_class_self_type:
      [ "("; ctyp{t}; ")" -> t | -> `Nil _loc ]
      meth_list:
      [ meth_decl{m}; ";"; S{(ml, v) }  -> (`Sem(_loc,m,ml)(* {| $m; $ml |} *), v)
      | meth_decl{m}; ";"; opt_dot_dot{v} -> (m, v)
      | meth_decl{m}; opt_dot_dot{v}      -> (m, v)  ]
      meth_decl:
      [ `Ant ((""|"typ" as n),s)        -> {| $(anti:mk_anti ~c:"ctyp" n s) |}
      | `Ant (("list" as n),s)          -> {| $(anti:mk_anti ~c:"ctyp;" n s) |}
      (* | `QUOTATION x                       -> AstQuotation.expand _loc x DynAst.ctyp_tag *)
      | a_lident{lab}; ":"; ctyp{t} -> `TyCol(_loc,`Id(_loc, (lab :> ident)),t)]
      opt_meth_list:
      [ meth_list{(ml, v) } -> `TyObj (_loc, ml, v)
      | opt_dot_dot{v}     -> `TyObj (_loc, (`Nil _loc), v)]
      row_field:
      [ `Ant ((""|"typ" as n),s) -> `Ant (_loc, (mk_anti ~c:"ctyp" n s))
      | `Ant (("list" as n),s) -> `Ant (_loc, (mk_anti ~c:"ctyp|" n s))
      | S{t1}; "|"; S{t2} -> (* {| $t1 | $t2 |} *) `Or(_loc,t1,t2)
      | "`"; astr{i} -> (* {| `$i |} *) `TyVrn(_loc,i)
      (* | "`"; astr{i}; "of"; "&"; amp_ctyp{t} -> *)
      (*     `TyOfAmp (_loc, (`TyVrn (_loc, i)), t) *)
          (* {| `$i of & $t |} *)
      | "`"; astr{i}; "of"; (* amp_ctyp *)ctyp{t} -> `TyVrnOf(_loc,i,t)
      | ctyp{t} -> `Ctyp(_loc,t) ]

      (* only used in row_field *)
      (* amp_ctyp: *)
      (* [ S{t1}; "&"; S{t2} -> `Amp(_loc,t1,t2) *)
      (* | `Ant (("list" as n),s) -> {| $(anti:mk_anti ~c:"ctyp&" n s) |} *)
      (* | ctyp{t} -> t ] *)

      (* only used in ctyps *)
      name_tags:
      [ `Ant ((""|"typ" as n),s) ->  {| $(anti:mk_anti ~c:"ctyp" n s) |}
      | S{t1}; S{t2} -> `App (_loc, t1, t2)
      | "`"; astr{i} -> `TyVrn (_loc, i)  ]

      (* only used in class_str_item *)
      opt_polyt:
      [ ":"; ctyp{t} -> t  | ->`Nil _loc ]
      
      type_declaration:
      [ `Ant ((""|"typ"|"anti" as n),s) -> {| $(anti:mk_anti ~c:"ctyp" n s) |}
      | `Ant (("list" as n),s) ->          {| $(anti:mk_anti ~c:"ctypand" n s) |}
      (* | `QUOTATION x -> AstQuotation.expand _loc x DynAst.ctyp_tag *)
      | S{t1}; "and"; S{t2} ->  `And(_loc,t1,t2)
      |  type_ident_and_parameters{(n, tpl)}; "="; type_info{tk}; L0 constrain{cl}
        -> `TyDcl (_loc, n, tpl, tk, cl)
      | type_ident_and_parameters{(n,tpl)}; L0 constrain{cl} ->
        `TyDcl(_loc,n,tpl,`Nil _loc,cl)]
      type_info:
      [type_repr{t2} -> `TyRepr(_loc,`PrNil _loc,t2)
      | ctyp{t1}; "="; type_repr{t2} -> `TyMan(_loc, t1, `PrNil _loc, t2)
      |  ctyp{t1} -> `TyEq(_loc,`PrNil _loc, t1)
      | "private"; ctyp{t1} -> `TyEq(_loc,`Private _loc,t1)
      |  ctyp{t1}; "=";"private"; type_repr{t2} ->
          `TyMan(_loc, t1, `Private _loc,t2)
      | "private"; type_repr{t2} -> `TyRepr(_loc,`Private _loc, t2)]

      type_repr:
      ["["; constructor_declarations{t}; "]" -> `Sum(_loc,t )
      | "["; "]" -> `Sum(_loc,`Nil _loc)
      | "{"; label_declaration_list{t}; "}" -> `Record (_loc, t)]
      type_ident_and_parameters:
      [ "(";  L1 type_parameter SEP ","{tpl}; ")"; a_lident{i} -> (i, tpl)
      |  type_parameter{t};  a_lident{i} -> (i, [t])
      |  a_lident{i} -> (i, [])]
      constrain:
      [ "constraint"; ctyp{t1}; "="; ctyp{t2} -> (t1, t2) ]
      typevars:
      [ S{t1}; S{t2} -> {| $t1 $t2 |}
      | `Ant ((""|"typ" as n),s) ->  {| $(anti:mk_anti ~c:"ctyp" n s) |}
      | `Ant(("list" as n),s) ->     {| $(anti:mk_anti ~c:"forall" n s)|}
      | `QUOTATION x -> AstQuotation.expand _loc x DynAst.ctyp_tag
      | "'"; a_lident{i} ->  `Quote (_loc, `Normal _loc, i)
            (* {| '$i |} *)]
      ctyp:
      {
       "alias" LA
        [ S{t1}; "as"; "'"; a_lident{i} -> `Alias(_loc,t1,i)]
       "forall" LA
        [ "!"; typevars{t1}; "."; ctyp{t2} -> {| ! $t1 . $t2 |} ]
       "arrow" RA
        [ S{t1}; "->"; S{t2} ->  {| $t1 -> $t2 |} ]
       "label" NA
        [ "~"; a_lident{i}; ":"; S{t} -> {| ~ $i : $t |}
        | `LABEL s ; ":"; S{t} -> {| ~$lid:s : $t |}
        | `OPTLABEL s ; S{t} -> `OptLabl(_loc,`Lid(_loc,s),t)
        | "?"; a_lident{i}; ":"; S{t} -> `OptLabl(_loc,i,t)]
       "apply" LA
        [ S{t1}; S{t2} ->
          let t = `App(_loc,t1,t2) in
          try `Id(_loc,ident_of_ctyp t)
          with [ Invalid_argument _ -> t ]]
       "." LA
        [ S{t1}; "."; S{t2} ->
            try
              `Id (_loc, (`Dot (_loc, (ident_of_ctyp t1), (ident_of_ctyp t2))))
            with [ Invalid_argument s -> raise (XStream.Error s) ] ]
       "simple"
        [ "'"; a_lident{i} ->  `Quote (_loc, `Normal _loc,  i)
        | "_" -> `Any _loc
        | `Ant ((""|"typ"|"anti"|"tup" as n),s) -> `Ant (_loc, (mk_anti ~c:"ctyp" n s))
        | `Ant (("id" as n),s) -> `Id (_loc, (`Ant (_loc, (mk_anti ~c:"ident" n s))))
        | `QUOTATION x -> AstQuotation.expand _loc x DynAst.ctyp_tag
        | a_lident{i}->  `Id(_loc,(i:>ident))
        | a_uident{i} -> `Id(_loc,(i:>ident))
        | "("; S{t}; "*"; star_ctyp{tl}; ")" -> `Tup (_loc, `Sta (_loc, t, tl))
        | "("; S{t}; ")" -> t
        | "[="; row_field{rfl}; "]" -> `PolyEq(_loc,rfl)
        | "[>"; "]" -> `PolySup (_loc, (`Nil _loc))
        | "[>"; row_field{rfl}; "]" ->   `PolySup (_loc, rfl)
        | "[<"; row_field{rfl}; "]" -> `PolyInf(_loc,rfl)
        | "[<"; row_field{rfl}; ">"; name_tags{ntl}; "]" -> `PolyInfSup(_loc,rfl,ntl)
        | "#"; class_longident{i} -> {| #$i |}
        | "<"; opt_meth_list{t}; ">" -> t
        | "("; "module"; module_type{p}; ")" -> `Package(_loc,p)  ] }
      star_ctyp:
      [ `Ant ((""|"typ" as n),s) -> `Ant (_loc, (mk_anti ~c:"ctyp" n s))
      | `Ant (("list" as n),s) ->  `Ant (_loc, (mk_anti ~c:"ctyp*" n s))
      | S{t1}; "*"; S{t2} -> `Sta(_loc,t1,t2)
      | ctyp{t} -> t  ]
      constructor_declarations:
      [ `Ant ((""|"typ" as n),s) -> `Ant (_loc, (mk_anti ~c:"ctyp" n s)) 
      | `Ant (("list" as n),s) ->   `Ant (_loc, (mk_anti ~c:"ctyp|" n s))
      (* | `QUOTATION x -> AstQuotation.expand _loc x DynAst.ctyp_tag *)
      | S{t1}; "|"; S{t2} ->    `Or(_loc,t1,t2)
      | a_uident{s}; "of"; constructor_arg_list{t} -> `Of(_loc,`Id(_loc,(s:>ident)),t)
      (* GADT to be improved *)      
      | a_uident{s}; ":"; ctyp{t} ->
          let (tl, rt) = FanOps.to_generalized t in
            (* {| $(id:(s:>ident)) : ($(FanAst.and_of_list tl) -> $rt) |} *)
            `TyCol
            (_loc, (`Id (_loc, (s :>ident))),
             (`Arrow (_loc, (sta_of_list tl), rt)))
      | a_uident{s} -> `Id(_loc,(s:>ident)) ]
      constructor_declaration:
      [ `Ant ((""|"typ" as n),s) ->  {| $(anti:mk_anti ~c:"ctyp" n s) |}
      (* | `QUOTATION x -> AstQuotation.expand _loc x DynAst.ctyp_tag *)
      | a_uident{s}; "of"; constructor_arg_list{t} -> `Of(_loc,`Id(_loc,(s:>ident)),t)
      | a_uident{s} -> `Id(_loc,(s:>ident))  ]
      constructor_arg_list:
      [ `Ant (("list" as n),s) ->  `Ant(_loc,mk_anti ~c:"ctyp*" n s)
      | S{t1}; "*"; S{t2} -> `Sta(_loc,t1,t2)
      | ctyp{t} -> t  ]
      label_declaration_list:
      [ label_declaration{t1}; ";"; S{t2} -> `Sem(_loc,t1,t2)
      | label_declaration{t1}; ";"            -> t1
      | label_declaration{t1}                 -> t1  ]
      label_declaration:
      [ `Ant ((""|"typ" as n),s) -> `Ant (_loc, (mk_anti ~c:"ctyp" n s))
      | `Ant (("list" as n),s) -> `Ant (_loc, (mk_anti ~c:"ctyp;" n s))
      (* | `QUOTATION x -> AstQuotation.expand _loc x DynAst.ctyp_tag *)
      | a_lident{s}; ":"; ctyp{t} -> `TyCol (_loc, (`Id (_loc, (s :>ident))), t)
      | "mutable"; a_lident{s}; ":";  ctyp{t} -> `TyColMut(_loc,`Id(_loc,(s:>ident)),t)]
      class_name_and_param:
      [ a_lident{i}; "["; comma_type_parameter{x}; "]" -> (i, x)
      | a_lident{i} -> (i, `Nil _loc )  ]
      comma_type_parameter:
      [ S{t1}; ","; S{t2} ->  `Com (_loc, t1, t2)
      | `Ant (("list" as n),s) -> `Ant (_loc, (mk_anti ~c:"ctyp," n s))
      | type_parameter{t} -> `Ctyp(_loc, t)  ]
      opt_comma_ctyp:
      [ "["; comma_ctyp{x}; "]" -> x | -> `Nil _loc  ]
      comma_ctyp:
      [ S{t1}; ","; S{t2} -> `Com (_loc, t1, t2) 
      | `Ant (("list" | "" as n),s) -> `Ant (_loc, (mk_anti ~c:"ctyp," n s))
      | ctyp{t} -> `Ctyp(_loc,t)  ]  |};
end;

  
AstParsers.register_parser
    ("revise",fun () -> begin apply (); apply_ctyp () end);









