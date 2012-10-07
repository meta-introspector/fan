
open FanUtil;
module Ast= Camlp4Ast; (* it contains a module named Meta *)
(*
  {[
  
  sep_expr [] <:expr< A.B.g.h>>; ;
  [(, ["A"; "B"], ExId (, IdLid (, "g"))); (, [], ExId (, IdLid (, "h")))]

  The first two dots are IdAcc, the last dot is ExAcc

  sep_expr [] <:expr< A.B.g.h + 3 >>
  [(, [],
  ExApp (,
   ExApp (, ExId (, IdLid (, "+")),
    ExAcc (,
     ExId (, IdAcc (, IdUid (, "A"), IdAcc (, IdUid (, "B"), IdLid (, "g")))),
     ExId (, IdLid (, "h")))),
   ExInt (, "3")))]


  sep_expr [] <:expr< A.B.g.h.i>>; ;
  [(, ["A"; "B"], ExId (, IdLid (, "g"))); (, [], ExId (, IdLid (, "h")));
  (, [], ExId (, IdLid (, "i")))]

  sep_expr [] <:expr< $(uid:"").t >> ; ;
  - : (Camlp4Ast.Ast.loc * string list * Camlp4Ast.Ast.expr) list =
  [(, [""], Camlp4Ast.Ast.ExId (, Camlp4Ast.Ast.IdLid (, "t")))]

  ]}
 *)

let rec sep_expr acc = fun
  [ <:expr< $e1.$e2>> ->
    sep_expr (sep_expr acc e2) e1
  | <:expr@loc< $uid:s >> as e ->
      match acc with
      [ [] -> [(loc, [], e)]
      | [(loc', sl, e) :: l] -> [(FanLoc.merge loc loc', [s :: sl], e) :: l] ]
  | <:expr< $(id:(<:ident< $_.$_ >> as i)) >> ->
      sep_expr acc (Ident.normalize_acc i)
  | e -> [(Ast.loc_of_expr e, [], e) :: acc] ];


let rec fa al = fun
  [ <:expr< $f $a >> ->fa [a :: al] f
  | f -> (f, al) ];


let rec apply accu = fun
  [ [] -> accu
  | [x :: xs] ->
      let _loc = Ast.loc_of_expr x
      in apply <:expr< $accu $x >> xs ];

let mklist _loc =
  let rec loop top =  fun
    [ [] -> <:expr< [] >>
    | [e1 :: el] ->
        let _loc =
          if top then _loc else FanLoc.merge (Ast.loc_of_expr e1) _loc in
        <:expr< [$e1 :: $(loop False el)] >> ] in loop True ;
  
let mkumin _loc f arg = match arg with
  [ <:expr< $int:n >> -> <:expr< $(int:neg_string n) >>
  | <:expr< $int32:n >> -> <:expr< $(int32:neg_string n) >>
  | <:expr< $(int64:n) >> -> <:expr< $(int64:neg_string n) >>
  | <:expr< $nativeint:n >> -> <:expr< $(nativeint:neg_string n) >>
  | <:expr< $flo:n >> -> <:expr< $(flo:neg_string n) >>
  | _ -> <:expr< $(lid:"~" ^ f) $arg >> ];
  
let mkassert _loc = fun
  [ <:expr< False >> ->
    <:expr< assert False >>
   (* this case takes care about
      the special assert false node *)
  | e -> <:expr< assert $e >> ] ;


let mklist_last ?last _loc  =
  let rec loop top = fun
    [ [] -> match last with
      [ Some e -> e
      | None -> <:expr< [] >> ]
    | [e1 :: el] ->
        let _loc =
          if top then _loc else FanLoc.merge (Ast.loc_of_expr e1) _loc in
        <:expr< [$e1 :: $(loop False el)] >> ] in
  loop True ;

let mksequence _loc = fun
  [ <:expr< $_; $_ >> | <:expr< $anti:_ >> as e -> <:expr< do { $e } >>
  | e -> e ];

let mksequence' _loc = fun
  [ <:expr< $_; $_ >> as e -> <:expr< do { $e } >>
  | e -> e ];


let bigarray_get _loc arr arg =
  let coords =  match arg with
  [ <:expr< ($e1, $e2) >> | <:expr< $e1, $e2 >> ->
      Ast.list_of_expr e1 (Ast.list_of_expr e2 [])
  | _ -> [arg] ] in
  match coords with
  [ [] -> failwith "bigarray_get null list"
  | [c1] -> <:expr< $arr.{$c1} >>  
  | [c1; c2] -> <:expr< $arr.{$c1,$c2} >>  
  | [c1; c2; c3] -> <:expr< $arr.{$c1,$c2,$c3} >> 
  | [c1;c2;c3::coords] ->
      <:expr< $arr.{$c1,$c2,$c3,$(Ast.exSem_of_list coords) } >> ]; (* FIXME 1.ExArr, 2. can we just write $list:coords? *)

let bigarray_set _loc var newval = match var with
    [ <:expr<  $arr.{$c1} >> ->
        Some <:expr< $arr.{$c1} := $newval >> 
    | <:expr<  $arr.{$c1, $c2} >> ->
        Some <:expr<  $arr.{$c1, $c2} :=  $newval >>
    | <:expr<  $arr.{$c1, $c2, $c3} >> ->
        Some <:expr< $arr.{$c1,$c2,$c3} := $newval >> 
    |  <:expr< Bigarray.Genarray.get $arr [| $coords |] >> -> (* FIXME how to remove Bigarray here?*)
        Some <:expr< Bigarray.Genarray.set $arr [| $coords |] $newval >>
    | _ -> None ];
  

(*************************************************************************)
(* List comprehension *)  
let map _loc p e l =  match (p, e) with
  [ (<:patt< $lid:x >>, <:expr< $lid:y >>) when x = y -> l
  | _ ->
      if Ast.is_irrefut_patt p then
        <:expr< List.map (fun $p -> $e) $l >>
      else
        <:expr< List.fold_right
          (fun
            [ $pat:p when True -> (fun x xs -> [ x :: xs ]) $e
            | _ -> (fun l -> l) ])
          $l [] >> ];


let filter _loc p b l =
    if Ast.is_irrefut_patt p then
      <:expr< List.filter (fun $p -> $b) $l >>
    else
      <:expr< List.filter (fun [ $p when True -> $b | _ -> False ]) $l >>;
let concat _loc l = <:expr< List.concat $l >>;
(* only this function needs to be exposed *)
let rec compr _loc e =  fun
    [ [`gen (p, l)] -> map _loc p e l
    | [`gen (p, l); `cond b :: items] ->
        compr _loc e [`gen (p, filter _loc p b l) :: items]
    | [`gen (p, l) :: ([ `gen (_, _) :: _ ] as is )] ->
        concat _loc (map _loc p (compr _loc e is) l)
    | _ -> raise Stream.Failure ];

(*************************************************************************)    

(*************************************************************************)
(* Utility for macro *)
let bad_patt _loc =
  FanLoc.raise _loc
    (Failure
       "this macro cannot be used in a pattern (see its definition)");
let substp _loc env =
  let rec loop = fun
      [ <:expr< $e1 $e2 >> -> <:patt< $(loop e1) $(loop e2) >>
      | <:expr< >> -> <:patt< >>
      | <:expr< $lid:x >> ->
          try List.assoc x env with
          [ Not_found -> <:patt< $lid:x >> ]
      | <:expr< $uid:x >> ->
          try List.assoc x env with
          [ Not_found -> <:patt< $uid:x >> ]
      | <:expr< $int:x >> -> <:patt< $int:x >>
      | <:expr< $str:s >> -> <:patt< $str:s >>
      | <:expr< ($tup:x) >> -> <:patt< $(tup:loop x) >>
      | <:expr< $x1, $x2 >> -> <:patt< $(loop x1), $(loop x2) >>
      | <:expr< { $bi } >> ->
          let rec substbi = fun
            [ <:rec_binding< $b1; $b2 >> -> <:patt< $(substbi b1); $(substbi b2) >>
            | <:rec_binding< $i = $e >> -> <:patt< $i = $(loop e) >>
            | _ -> bad_patt _loc ]
          in <:patt< { $(substbi bi) } >>
      | _ -> bad_patt _loc ] in loop;
  
  class subst _loc env = object
    inherit Ast.reloc _loc as super;
    method! expr =
      fun
      [ <:expr< $lid:x >> | <:expr< $uid:x >> as e ->
          try List.assoc x env with
          [ Not_found -> super#expr e ]
      | <:expr@_loc< LOCATION_OF $lid:x >> | <:expr@_loc< LOCATION_OF $uid:x >> as e ->
          try
            let loc = Ast.loc_of_expr (List.assoc x env) in
            let (a, b, c, d, e, f, g, h) = FanLoc.to_tuple loc in
            <:expr< FanLoc.of_tuple
              ($`str:a, $`int:b, $`int:c, $`int:d,
               $`int:e, $`int:f, $`int:g,
               $(if h then <:expr< True >> else <:expr< False >> )) >>
          with [ Not_found -> super#expr e ]
      | e -> super#expr e ];

    method! patt =  fun
      [ <:patt< $lid:x >> | <:patt< $uid:x >> as p ->
         try substp _loc [] (List.assoc x env) with
         [ Not_found -> super#patt p ]
      | p -> super#patt p ];
  end;

(*************************************************************************)
(* utilit for MakeNothing *)
 let map_expr = fun
   [ <:expr< $e NOTHING >> | <:expr< fun $(<:patt< NOTHING >> ) -> $e >> -> e
   | <:expr@_loc< $(lid:"__FILE__") >> -> <:expr< $(`str:FanLoc.file_name _loc) >>
   | <:expr@_loc< $(lid:"__LOCATION__") >> ->
     let (a, b, c, d, e, f, g, h) = FanLoc.to_tuple _loc in
     <:expr< FanLoc.of_tuple
       ($`str:a, $`int:b, $`int:c, $`int:d,
        $`int:e, $`int:f, $`int:g,
        $(if h then <:expr< True >> else <:expr< False >> )) >>
   | e -> e];
    



let antiquot_expander ~parse_patt ~parse_expr = object
  inherit Ast.map as super;
  method! patt = fun
    [ <:patt@_loc< $anti:s >> | <:patt@_loc< $str:s >> as p ->
      let mloc _loc = Meta.MetaLocQuotation.meta_loc_patt _loc _loc in
      handle_antiquot_in_string ~s ~default:p ~parse:parse_patt ~loc:_loc
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
          let mloc _loc = Meta.MetaLocQuotation.meta_loc_expr _loc _loc in
          handle_antiquot_in_string ~s ~default:e ~parse:parse_expr ~loc:_loc
            ~decorate:(fun n e -> (* e is the parsed Ast node already *)
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
  
(* let capture_antiquot = object *)
(*   inherit Ast.map as super; *)
(*   method! patt = fun *)
(*   [ <:patt@_loc< $anti:s >> | <:patt@_loc< $str:s >> as p -> *)
(*     () *)
(*   | p -> super#patt p *)
(*   ]; *)
(* end; *)
