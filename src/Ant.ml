open Ast;
open FanUtil;
open Lib.Meta;


let meta_loc_exp _loc loc =
  match !AstQuotation.current_loc_name with
  [ None -> {:expr| $(lid:!FanLoc.name) |}
  | Some "here" -> meta_loc _loc loc
  | Some x -> {:expr| $lid:x |} ];;


let meta_loc_patt _loc _ =  {:patt| _ |}; (* we use [subst_first_loc] *)

  
  
let gm () =
  match !FanConfig.compilation_unit with
  [Some "FanAst" -> ( (* eprintf "Compilation unit: FanAst";  *)"" )
  | Some _ -> ( (* eprintf "Compilation unit: %s@." x;  *)"FanAst" )
  | None ->  ((* eprintf "Compilation unit None@." ;  *)"FanAst")];

(*    
let ant_patt  ~parse_patt (x:ant) k = with patt 
  match x with 
  [`Ant(_loc, {cxt;sep;decorations;content=code}) ->
      let mloc _loc =meta_loc_patt  _loc _loc in
      let e = parse_patt _loc code in
      match (decorations,cxt,sep) with
      [("anti",_,_) -> k {| `Ant ($(mloc _loc), $e) |}
      |("uid",_,_) -> k {|`Uid($(mloc _loc), $e)|}
      |("lid",_,_) ->  {|`Lid($(mloc _loc), $e)|}
            (* |("id","ctyp",_) -> {|`Id($(mloc _loc),$e)|} *)
      |("tup",_,_) ->  Some {| `Tup ($(mloc _loc), $e)|}
      |("seq",_,_) -> Some {| `Seq ($(mloc _loc), $e) |}
      |("flo",_,_) -> Some {| `Flo($(mloc _loc), $e)|}
      |("int",_,_) -> Some {| `Int ($(mloc _loc), $e)|}
      |("int32",_,_)-> Some {| `Int32 ($(mloc _loc),$e)|}
      |("int64",_,_) -> Some {| `Int64($(mloc _loc),$e)|}
      |("nativeint",_,_) -> Some {|`NativeInt ($(mloc _loc),$e)|}
      |("chr",_,_) -> Some {|`Chr($(mloc _loc),$e)|}
      |("str",_,_) -> Some {|`Str($(mloc _loc),$e)|}
      |("vrn","expr",_) -> Some {|`Vrn($(mloc _loc),$e)|}
      |("vrn","patt",_) -> Some {|`Vrn($(mloc _loc),$e)|}
      | _ -> None ] ];
let ant_expr ~parse_expr (x:ant) =  with expr 
  match x with 
  [`Ant(_loc,{cxt;sep;decorations;content=code}) ->
    let mloc _loc = (meta_loc_exp _loc _loc :> expr) in
      let e = parse_expr _loc code in
      match (decorations,cxt,sep) with
      [ ("anti",_,__) -> {|`Ant($(mloc _loc),$e)|}
      | ("tup",_,_) -> {|`Tup($(mloc _loc),$e)|}
      | ("seq",_,_) -> {|`Seq($(mloc _loc),$e)|}
      | ("vrn","expr",_) -> {|`Vrn($(mloc _loc),$e)|}
      | ("vrn","patt",_) -> {|`Vrn($(mloc _loc),$e)|}
      | ("lid",_,_) -> {|`Lid($(mloc _loc),$e)|}
      | ("uid",_,_) -> {|`Uid($(mloc _loc),$e)|}
      | ("str",_,_) ->  {|`Str($(mloc _loc),$e)|}
      | ("chr",_,_) -> {|`Chr ($(mloc _loc), $e)|}
      | ("int",_,_) -> {|`Int($(mloc _loc),$e)|}
      | ("int32",_,_) -> {|`Int32($(mloc _loc),$e)|}
      | ("int64",_,_) -> {|`Int64($(mloc _loc),$e)|}
      | ("flo",_,_) -> {|`Flo($(mloc _loc),$e)|}
      | ("nativeint",_,_) -> {|`NativeInt ($(mloc _loc),$e)|}
      | ("`nativeint",_,_) ->
          let e = {| Nativeint.to_string $e |} in
          {| `NativeInt ($(mloc _loc), $e) |}
      | ("`int",_,_) ->
          let e = {|string_of_int $e |} in
          {| `Int ($(mloc _loc), $e) |}
      | ("`int32",_,_) ->
          let e = {|Int32.to_string $e |} in
          {| `Int32 ($(mloc _loc), $e) |}
      | ("`int64",_,_) ->
          let e = {|Int64.to_string $e |} in
          {| `Int64 ($(mloc _loc), $e) |}
      | ("`chr",_,_) ->
          let e = {|Char.escaped $e|} in
          {| `Chr ($(mloc _loc), $e) |}
      | ("`str",_,_) ->
          let e = {|String.escaped $e |} in
          {| `Str ($(mloc _loc), $e) |}
      | ("`flo",_,_) ->
          let e = {| FanUtil.float_repres $e |} in
          {| `Flo ($(mloc _loc), $e) |}
      | ("`bool",_,_) ->
          let x = {| `Lid ($(mloc _loc), (if $e then "true" else "false" )) |} in
          {| {| $(id:$x)  |} |}
      | ("list","module_expr",_) ->
          {| $(uid:gm()).app_of_list $e |}
      | ("list","module_type",_) ->
          {| $(uid:gm()).mtApp_of_list $e |}
      | ("list","ident",_) ->
          {| $(uid:gm()).dot_of_list $e |}
      | ("list",
         ("binding"|"module_binding"|
          "with_constr"|"class_type"|
          "class_expr"|"ctypand"),_) ->
            {| $(uid:gm()).and_of_list $e |}
      |("list","ctyp*",_) ->
          {| $(uid:gm()).sta_of_list $e |}
      |("list","ctyp|",_)
      |("list","case",_) ->
          {| $(uid:gm()).or_of_list $e |}
      |("list","ctyp&",_) ->
          {| $(uid:gm()).amp_of_list $e |}
      |("listlettry","case",_) ->
          {| (($(uid:gm()).match_pre)#case
                ($(uid:gm()).or_of_list $e)) |}
      |("antilettry","case",_) ->
          {| $(uid:gm()).match_pre#case (`Ant ($(mloc _loc), $e)) |}
      |("lettry","case",_) ->
          {| $(uid:gm()).match_pre#case $e |}
      |("list",("ctyp,"|"patt,"|"expr,"),_) ->
          {| $(uid:gm()).com_of_list $e |}
      |("list",
        ("binding;"|"stru"
      |"sig_item"|"class_sig_item"
            |"cstru"|"rec_expr"
            |"ctyp;"|"patt;"|"expr;"),_) ->
                {| $(uid:gm()).sem_of_list $e |} ]];
*)

  
let antiquot_expander ~parse_patt ~parse_expr = object
  inherit Objs.map as super;
  method! patt (x:patt)= with patt
    match x with 
    [`Ant(_loc, {cxt;sep;decorations;content=code}) ->
      (* when the antiquotation appears in the pattern position,
         its final context is [patt]
       *)
      let mloc _loc =meta_loc_patt  _loc _loc in
      let e = parse_patt _loc code in
      match (decorations,cxt,sep) with
      [("anti",_,_) -> {| `Ant ($(mloc _loc), $e) |}
      |("uid",_,_) -> {|`Uid($(mloc _loc), $e)|}
      |("lid",_,_) -> {|`Lid($(mloc _loc), $e)|}
            (* |("id","ctyp",_) -> {|`Id($(mloc _loc),$e)|} *)
      |("tup",_,_) ->  {| `Tup ($(mloc _loc), $e)|}
      |("seq",_,_) -> {| `Seq ($(mloc _loc), $e) |}
      |("flo",_,_) -> {| `Flo($(mloc _loc), $e)|}
      |("int",_,_) -> {| `Int ($(mloc _loc), $e)|}
      |("int32",_,_)-> {| `Int32 ($(mloc _loc),$e)|}
      |("int64",_,_) -> {| `Int64($(mloc _loc),$e)|}
      |("nativeint",_,_) -> {|`NativeInt ($(mloc _loc),$e)|}
      |("chr",_,_) -> {|`Chr($(mloc _loc),$e)|}
      |("str",_,_) -> {|`Str($(mloc _loc),$e)|}
      |("vrn","expr",_) -> {|`Vrn($(mloc _loc),$e)|}
      |("vrn","patt",_) -> {|`Vrn($(mloc _loc),$e)|}
    | _ -> super#patt e ]
 | e -> super#patt e];
  method! expr (x:expr) = with expr
    match x with 
    [`Ant(_loc,{cxt;sep;decorations;content=code}) ->
      let mloc _loc = (meta_loc_exp _loc _loc :> expr) in
      let e = parse_expr _loc code in
      match (decorations,cxt,sep) with
      [ ("anti",_,__) -> {|`Ant($(mloc _loc),$e)|}
      | ("tup",_,_) -> {|`Tup($(mloc _loc),$e)|}
      | ("seq",_,_) -> {|`Seq($(mloc _loc),$e)|}
      | ("vrn","expr",_) -> {|`Vrn($(mloc _loc),$e)|}
      | ("vrn","patt",_) -> {|`Vrn($(mloc _loc),$e)|}
      | ("lid",_,_) -> {|`Lid($(mloc _loc),$e)|}
      | ("uid",_,_) -> {|`Uid($(mloc _loc),$e)|}
      | ("str",_,_) ->  {|`Str($(mloc _loc),$e)|}
      | ("chr",_,_) -> {|`Chr ($(mloc _loc), $e)|}
      | ("int",_,_) -> {|`Int($(mloc _loc),$e)|}
      | ("int32",_,_) -> {|`Int32($(mloc _loc),$e)|}
      | ("int64",_,_) -> {|`Int64($(mloc _loc),$e)|}
      | ("flo",_,_) -> {|`Flo($(mloc _loc),$e)|}
      | ("nativeint",_,_) -> {|`NativeInt ($(mloc _loc),$e)|}
      | ("`nativeint",_,_) ->
          let e = {| Nativeint.to_string $e |} in
          {| `NativeInt ($(mloc _loc), $e) |}
      | ("`int",_,_) ->
          let e = {|string_of_int $e |} in
          {| `Int ($(mloc _loc), $e) |}
      | ("`int32",_,_) ->
          let e = {|Int32.to_string $e |} in
          {| `Int32 ($(mloc _loc), $e) |}
      | ("`int64",_,_) ->
          let e = {|Int64.to_string $e |} in
          {| `Int64 ($(mloc _loc), $e) |}
      | ("`chr",_,_) ->
          let e = {|Char.escaped $e|} in
          {| `Chr ($(mloc _loc), $e) |}
      | ("`str",_,_) ->
          let e = {|String.escaped $e |} in
          {| `Str ($(mloc _loc), $e) |}
      | ("`flo",_,_) ->
          let e = {| FanUtil.float_repres $e |} in
          {| `Flo ($(mloc _loc), $e) |}
      | ("`bool",_,_) ->
          let x = {| `Lid ($(mloc _loc), (if $e then "true" else "false" )) |} in
          {| {| $(id:$x)  |} |}
      | ("list","module_expr",_) ->
          {| $(uid:gm()).app_of_list $e |}
      | ("list","module_type",_) ->
          {| $(uid:gm()).mtApp_of_list $e |}
      | ("list","ident",_) ->
          {| $(uid:gm()).dot_of_list $e |}
      | ("list",
         ("binding"|"module_binding"|
          "with_constr"|"class_type"|
          "class_expr"|"ctypand"),_) ->
            {| $(uid:gm()).and_of_list $e |}
      |("list","ctyp*",_) ->
          {| $(uid:gm()).sta_of_list $e |}
      |("list","ctyp|",_)
      |("list","case",_) ->
          {| $(uid:gm()).or_of_list $e |}
      |("list","ctyp&",_) ->
          {| $(uid:gm()).amp_of_list $e |}
      |("listlettry","case",_) ->
          {| (($(uid:gm()).match_pre)#case
                ($(uid:gm()).or_of_list $e)) |}
      |("antilettry","case",_) ->
          {| $(uid:gm()).match_pre#case (`Ant ($(mloc _loc), $e)) |}
      |("lettry","case",_) ->
          {| $(uid:gm()).match_pre#case $e |}
      |("list",("ctyp,"|"patt,"|"expr,"),_) ->
          {| $(uid:gm()).com_of_list $e |}
      |("list",
        ("binding;"|"stru"
      |"sig_item"|"class_sig_item"
            |"cstru"|"rec_expr"
            |"ctyp;"|"patt;"|"expr;"),_) ->
                {| $(uid:gm()).sem_of_list $e |}
      | _ -> super#expr e]
      | e -> super#expr e];
  end;
                  

(* broken
   ideas add type annotations for specific variants, some
   variants can be annoated, some can not
   
   {:ctyp| ! 'a 'b 'c. 'a -> 'b -> 'c|}
   `TyPol
             (_loc,
             (`App
             (_loc,
             (`App
              (_loc,
                (`Quote (_loc, (`Normal _loc), (`Some (`Lid (_loc, "a"))))),
                (`Quote (_loc, (`Normal _loc), (`Some (`Lid (_loc, "b"))))))),
           (`Quote (_loc, (`Normal _loc), (`Some (`Lid (_loc, "c"))))))),
             (`Arrow
             (_loc, (`Quote (_loc, (`Normal _loc), (`Some (`Lid (_loc, "a"))))),
             (`Arrow
             (_loc,
             (`Quote (_loc, (`Normal _loc), (`Some (`Lid (_loc, "b"))))),
             (`Quote (_loc, (`Normal _loc), (`Some (`Lid (_loc, "c"))))))))))
           *)        
          (* |("list","forall",_) -> *)
          (*     {| $(uid:gm()).tyVarApp_of_list $e |} *)
