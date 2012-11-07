open Structure
open Format
let pp = fprintf
let name_of_descr = function | (`Antiquot,s) -> "$" ^ s | (_,s) -> s
let name_of_symbol entry =
  (function
   | `Snterm e -> "[" ^ (e.ename ^ "]")
   | `Snterml (e,l) -> "[" ^ (e.ename ^ (" level " ^ (l ^ "]")))
   | `Sself|`Snext -> "[" ^ (entry.ename ^ "]")
   | `Stoken (_,descr) -> name_of_descr descr
   | `Skeyword kwd -> "\"" ^ (kwd ^ "\"")
   | _ -> "???" : [> symbol] -> string )
let rec name_of_symbol_failed entry =
          (function
           | `Slist0 s|`Slist0sep (s,_)|`Slist1 s|`Slist1sep (s,_)|`Sopt s|
               `Stry s -> name_of_symbol_failed entry s
           | `Stree t -> name_of_tree_failed entry t
           | s -> name_of_symbol entry s : [> symbol] -> string )
and name_of_tree_failed entry x =
      match x with
      | Node ({ node = s; brother = bro; son } as y) ->
          (match Tools.get_terminals y with
           | None  ->
               let txt = name_of_symbol_failed entry s in
               let txt =
                 match (s, son) with
                 | (`Sopt _,Node _) ->
                     txt ^ (" or " ^ (name_of_tree_failed entry son))
                 | _ -> txt in
               let txt =
                 match bro with
                 | DeadEnd |LocAct (_,_) -> txt
                 | Node _ -> txt ^ (" or " ^ (name_of_tree_failed entry bro)) in
               txt
           | Some (tokl,_,_) ->
               List.fold_left
                 (fun s  tok  ->
                    (if s = "" then "" else s ^ " then ") ^
                      (match tok with
                       | `Stoken (_,descr) -> name_of_descr descr
                       | `Skeyword kwd -> kwd)) "" tokl)
      | DeadEnd |LocAct (_,_) -> "???"
let magic _s x = Obj.magic x
let tree_failed entry prev_symb_result prev_symb tree =
  let txt = name_of_tree_failed entry tree in
  let txt =
    match prev_symb with
    | `Slist0 s ->
        let txt1 = name_of_symbol_failed entry s in
        txt1 ^ (" or " ^ (txt ^ " expected"))
    | `Slist1 s ->
        let txt1 = name_of_symbol_failed entry s in
        txt1 ^ (" or " ^ (txt ^ " expected"))
    | `Slist0sep (s,sep) ->
        (match magic "tree_failed: 'a -> list 'b" prev_symb_result with
         | [] ->
             let txt1 = name_of_symbol_failed entry s in
             txt1 ^ (" or " ^ (txt ^ " expected"))
         | _ ->
             let txt1 = name_of_symbol_failed entry sep in
             txt1 ^ (" or " ^ (txt ^ " expected")))
    | `Slist1sep (s,sep) ->
        (match magic "tree_failed: 'a -> list 'b" prev_symb_result with
         | [] ->
             let txt1 = name_of_symbol_failed entry s in
             txt1 ^ (" or " ^ (txt ^ " expected"))
         | _ ->
             let txt1 = name_of_symbol_failed entry sep in
             txt1 ^ (" or " ^ (txt ^ " expected")))
    | `Stry _|`Sopt _|`Stree _ -> txt ^ " expected"
    | _ -> txt ^ (" expected after " ^ (name_of_symbol entry prev_symb)) in
  if ((entry.egram).error_verbose).contents
  then
    (let tree = Search.tree_in_entry prev_symb tree entry.edesc in
     let f = err_formatter in
     pp f
       ("@[<v 0>@,----------------------------------@," ^^
          ("Parse error in entry [%s], rule:@;<0 2>@[%a@]@," ^^
             "----------------------------------@,@]@.")) entry.ename
       Print.text#rules (flatten_tree tree))
  else ();
  txt ^ (" (in [" ^ (entry.ename ^ "])"))
let symb_failed entry prev_symb_result prev_symb symb =
  let tree = Node { node = symb; brother = DeadEnd; son = DeadEnd } in
  tree_failed entry prev_symb_result prev_symb tree
let symb_failed_txt e s1 s2 = symb_failed e 0 s1 s2