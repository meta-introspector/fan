


open Structure;
open Format;
open LibUtil;

let higher s1 s2 =
  match (s1, s2) with
  [ (#terminal,#terminal) -> false
  | (#terminal, _) -> true
  | _ -> false ];

(* {[ Structure.symbol -> bool ]}*)    
let rec derive_eps : symbol -> bool = fun
  [ `Slist0 _ | `Slist0sep (_, _) | `Sopt _ | `Speek _ -> true
  | `Stry s -> derive_eps s
  | `Stree t -> tree_derive_eps t
  | `Slist1 _ | `Slist1sep (_, _) | `Stoken _ | `Skeyword _ ->
      (* For sure we cannot derive epsilon from these *)
      false
  | `Smeta (_, _, _) | `Snterm _ | `Snterml (_, _) | `Snext | `Sself ->
        (* Approximation *)
      false ]
and tree_derive_eps : tree -> bool = fun
    [ LocAct (_, _) -> true
    | Node {node = s; brother = bro; son = son} ->
        derive_eps s && tree_derive_eps son || tree_derive_eps bro
    | DeadEnd -> false ];

(* create an empty level *)
let empty_lev lname assoc =
  {assoc ; lname ; lsuffix = DeadEnd; lprefix = DeadEnd};

(* here [name] is only used to emit error message
   The idea case is that extend should [care] about assocativity, since
   the extend rules should [always] follow the existing levels.
 *)  
let change_lev lev name lname assoc =  begin 
  if assoc <> lev.assoc && !(FanConfig.gram_warning_verbose) then
    eprintf "<W> Changing associativity of level %S aborted@." name;
  if  lname<> "" && lname <> lev.lname && !(FanConfig.gram_warning_verbose) then 
    eprintf "<W> Level label (%S: %S) ignored@." lname lev.lname;
  lev
end ;

(* *)  
let change_to_self entry = fun
  [ `Snterm e when e == entry -> `Sself
  | x -> x ];


let levels_of_entry  e =
  match e.edesc with
  [Dlevels ls -> Some ls
  |_ -> None];
    
(* given [entry] [position] and [levs]  return [levs* (label name * assoc ) -> level  *levs]*)
let find_level ?position entry  levs =
  let find x n  ls = 
    let rec get = fun
      [ [] -> 
        failwithf "Insert.find_level: No level labelled %S in entry %S @." n entry.ename
    | [lev::levs] ->
      if Tools.is_level_labelled n lev then
        match x with
        [`Level _ ->
            ([], change_lev lev n, levs)
        |`Before _ ->
            ([], empty_lev, [lev::levs])
        |`After _ ->
           ([lev], empty_lev, levs)]  
      else
        let (levs1,rlev,levs2) = get levs in
        ([lev::levs1], rlev, levs2) ] in
    get ls in 
  match position with
  [ Some `First -> ([], empty_lev, levs)
  | Some `Last -> (levs, empty_lev, [])
  | Some ((`Level n | `Before n | `After n)  as x) ->
      find x n levs 
  | None ->
      match levs with
      [ [lev :: levs] -> ([], change_lev lev "<top>", levs)
      | [] -> ([], empty_lev, []) ] ];

let rec check_gram entry = fun
  [ `Snterm e ->
    if e.egram != entry.egram then 
      failwithf  "Gram.extend: entries %S and %S do not belong to the same grammar.@."
        entry.ename e.ename
  | `Snterml (e, _) ->
      if e.egram != entry.egram then 
        failwithf
          "Gram.extend Error: entries %S and %S do not belong to the same grammar.@."
          entry.ename e.ename

  | `Smeta (_, sl, _) -> List.iter (check_gram entry) sl
  | `Slist0sep (s, t) -> begin check_gram entry t; check_gram entry s end
  | `Slist1sep (s, t) -> begin check_gram entry t; check_gram entry s end
  | `Slist0 s | `Slist1 s | `Sopt s | `Stry s | `Speek s -> check_gram entry s
  | `Stree t -> tree_check_gram entry t
  | `Snext | `Sself | `Stoken _ | `Skeyword _ -> () ]
and tree_check_gram entry = fun
  [ Node {node ; brother; son } -> begin 
    check_gram entry node;
    tree_check_gram entry brother;
    tree_check_gram entry son
  end
  | LocAct  _ | DeadEnd -> () ];

let get_initial = fun
    [ [`Sself :: symbols] -> (true, symbols)
    | symbols -> (false, symbols) ];

(* Insert the symbol list into the gram,
   it will create side effect which will
   update the keyword table in the gram
 *)
let insert_tokens gram symbols =
  let rec insert = fun
    [ `Smeta (_, sl, _) -> List.iter insert sl
    | `Slist0 s | `Slist1 s | `Sopt s | `Stry s | `Speek s -> insert s
    | `Slist0sep (s, t) -> begin  insert s; insert t  end
    | `Slist1sep (s, t) -> begin  insert s; insert t  end
    | `Stree t -> tinsert t
    | `Skeyword kwd -> using gram kwd (* main meat *)
    | `Snterm _ | `Snterml (_, _) | `Snext | `Sself | `Stoken _ -> () ]
  and tinsert = fun
    [ Node {node = s; brother = bro; son = son} ->
      begin insert s; tinsert bro; tinsert son end
    | LocAct (_, _) | DeadEnd -> () ] in
  List.iter insert symbols ;

(* given an [entry] [symbols] and [action] a tree, return a new [tree]
   [ename] is only used for error message
 *)
let insert_production_in_tree ename (gsymbols, action) tree =
  let rec try_insert s sl tree =
    match tree with
    [ Node ( {node ; son ; brother} as x) ->
      if Tools.eq_symbol s node then
        Some (Node { x with son = insert sl son})
      else
        match try_insert s sl brother with
        [ Some y -> Some (Node {x with brother=y})
        | None ->
            if higher node s || (derive_eps s && not (derive_eps node)) then
              (* node has higher priority *)
              Some (Node {(x) with brother = Node {(x) with node = s; son = insert sl DeadEnd}})
            else None ]
    | LocAct (_, _) | DeadEnd -> None ] 
  and  insert_in_tree s sl tree =
    match try_insert s sl tree with
    [ Some t -> t
    | None -> Node {node = s; son = insert sl DeadEnd; brother = tree} ] 
  and  insert symbols tree =
    match symbols with
    [ [s :: sl] -> insert_in_tree s sl tree 
    | [] -> match tree with
        [ Node ({ brother;_} as x) ->  Node {(x) with brother = insert [] brother }
        | LocAct (old_action, action_list) ->
            let () =
              if !(FanConfig.gram_warning_verbose) then
                eprintf "<W> Grammar extension: in [%s] some rule has been masked@."
                  ename
              else ()in
            LocAct action [old_action :: action_list]
        | DeadEnd -> LocAct action [] ] ] in 
  insert gsymbols tree ;
  
let insert_production_in_level ename e1 (symbols, action) slev =
  if e1 then
    {slev with lsuffix = insert_production_in_tree ename (symbols, action) slev.lsuffix}
  else
    {slev with lprefix = insert_production_in_tree ename (symbols ,action) slev.lprefix};


let insert_to_exist_level entry (la:level) (lb:olevel) =
  let (lname1,assoc1,rules1) = lb in
  if not (la.lname = lname1 &&  la.assoc = assoc1) then
    failwith "insert_to_exist_level does not agree (name)"
  else  begin 
    List.fold_right
      (fun (symbols,action) lev ->
        let symbols = List.map (change_to_self entry) symbols in
        (* let () = List.iter (check_gram entry) symbols in *)
        let (e1,symbols) = get_initial symbols in
        (* let () = insert_tokens entry.egram symbols in  *)
        insert_production_in_level entry.ename e1 (symbols,action) lev)  rules1 la;
  end;
let insert_level entry (lb:olevel) : level =
  let (lname,assoc,rules) = lb in
  let  la = empty_lev lname assoc in
    List.fold_right
      (fun (symbols,action) lev ->
        let symbols = List.map (change_to_self entry) symbols in
        (* let () = List.iter (check_gram entry) symbols in *)
        let (e1,symbols) = get_initial symbols in
        (* let () = insert_tokens entry.egram symbols in  *)
        insert_production_in_level entry.ename e1 (symbols,action) lev) rules la;
(* given an [entry] [position] and [rules] return a new list of [levels]*)  
let insert_olevels_in_levels entry position olevels =
  let elev = match entry.edesc with
    [ Dlevels elev -> elev
    | Dparser _ ->
        failwithf "Grammar.extend: Error: entry not extensible: %S@." entry.ename ] in
  if olevels = [] then
    elev
  else
    let (levs1, make_lev, levs2) = find_level ?position entry  elev in
    let (levs, _) =
      List.fold_left
        (fun (levs, make_lev) (lname, assoc, rules) ->
          let lev = make_lev lname assoc in
          let lev =
            List.fold_right
              (fun  (symbols, action) lev ->
                let symbols = List.map (change_to_self entry) symbols in 
                (* let () = List.iter (check_gram entry) symbols in  *)
                let (e1, symbols) = get_initial symbols in 
                (* let () =   insert_tokens entry.egram symbols in  *)
                insert_production_in_level entry.ename e1 (symbols, action) lev)
              rules lev in ([lev :: levs], empty_lev))
        ([], make_lev)  olevels in
      levs1 @ List.rev levs @ levs2 ;


(* for the side effects,
   check whether the [gram]  is identical
   and insert the [keywords] here 
 *)    
let rec scan_olevels entry (levels: list olevel) =
  List.iter  (scan_olevel entry) levels
and scan_olevel entry (_,_,prods) =
  List.iter (scan_product entry) prods
and scan_product entry (symbols,_) = begin
  insert_tokens entry.egram symbols;
  List.iter (check_gram entry) symbols;
end;

  
(* mutate the [estart] and [econtinue]
   The previous version is lazy. We should find a way to exploit both in the future
 *)    
let extend entry (position, levels) =
  let elev = insert_olevels_in_levels entry position levels in begin
    scan_olevels entry levels; (* for side effect *)
    entry.edesc <- Dlevels elev;
    entry.estart <-Parser.start_parser_of_entry entry;
    entry.econtinue <- Parser.continue_parser_of_entry entry;
  end;


