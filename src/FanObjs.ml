open Objs;
open LibUtil;
let dump = new print;

let dump_type_parameters = to_string_of_printer dump#type_parameters;  
let dump_row_field = to_string_of_printer dump#row_field;
let dump_or_ctyp = to_string_of_printer dump#or_ctyp;  
let dump_type_repr = to_string_of_printer dump#type_repr;
let dump_type_info = to_string_of_printer dump#type_info;  
let dump_typedecl = to_string_of_printer dump#typedecl;
let dump_ctyp = to_string_of_printer dump#ctyp;
let dump_name_ctyp = to_string_of_printer dump#name_ctyp;  
let dump_with_constr = to_string_of_printer dump#with_constr;
let dump_module_type = to_string_of_printer dump#module_type;
let dump_exp = to_string_of_printer dump#exp;
let dump_patt = to_string_of_printer dump#patt;
let dump_class_type = to_string_of_printer dump#class_type;
let dump_class_exp = to_string_of_printer dump#class_exp;
let dump_ident = to_string_of_printer dump#ident;
let dump_type_constr = to_string_of_printer dump#type_constr;  
let dump_case = to_string_of_printer dump#case;
let dump_rec_exp = to_string_of_printer dump#rec_exp;  
let dump_stru = to_string_of_printer dump#stru;
let dump_sig_item = to_string_of_printer dump#sig_item;
let dump_module_binding  = to_string_of_printer dump#module_binding;
let dump_module_exp = to_string_of_printer dump#module_exp;  
let dump_class_sig_item = to_string_of_printer dump#class_sig_item;
let dump_cstru = to_string_of_printer dump#cstru;  
let dump_decl_param = to_string_of_printer dump#decl_param;
let dump_decl_params = to_string_of_printer dump#decl_params;

let map_exp f = object
  inherit Objs.map as super;
  method! exp x = f (super#exp x);
end;
let map_patt f = object
  inherit Objs.map as super;
  method! patt x = f (super#patt x);
end;
let map_ctyp f = object
  inherit Objs.map as super;
  method! ctyp x = f (super#ctyp x);
end;
let map_stru f = object
  inherit Objs.map as super;
  method! stru x = f (super#stru x);
end;
let map_sig_item f = object
  inherit Objs.map as super;
  method! sig_item x = f (super#sig_item x);
end;
let map_ctyp f = object
  inherit Objs.map as super;
  method! ctyp x = f (super#ctyp x);
end;
let map_loc f = object
  inherit Objs.map as super;
  method! loc x = f (super#loc x);
end;


(* class clean_ast = object *)
(*   inherit Objs.map as super; *)
(*   (\* method! ctyp t = *\) *)
(*   (\*   match super#ctyp t with *\) *)
(*   (\*   [ `TyPol (_loc,`Nil _l,t)|`Arrow (_loc,t,`Nil _l)|`Arrow (_loc,`Nil _l,t) *\) *)
(*   (\*   |`Sta (_loc,`Nil _l,t)|`Sta (_loc,t,`Nil _l) -> t *\) *)
(*   (\*   | t -> t]; *\) *)
(*   (\* (\\* method! type_parameters t = *\\) *\) *)
(*   (\* (\\*   match super#type_parameters t with *\\) *\) *)
(*   (\* (\\*     [`Com(_,t, `Nil _ ) -> t | `Com (_,`Nil _, t) -> t | t -> t]; *\\) *\) *)
(*   (\* method! or_ctyp t = *\) *)
(*   (\*   match super#or_ctyp t with [ `Or(_,t,`Nil _) -> t | `Or(_,`Nil _,t) -> t| t -> t]; *\) *)
(*   (\* method! typedecl t = *\) *)
(*   (\*    match super#typedecl t with [`And(_,t,`Nil _) | `And(_,`Nil _,t) -> t | t -> t]; *\) *)
(*   (\* (\\* method! poly_ctyp t = *\\) *\) *)
(*   (\* (\\*   match super#poly_ctyp t with *\\) *\) *)
(*   (\* (\\*   [`TyPol(_,`Nil _,t) -> t | t ->t ]; *\\) *\) *)
(*   (\* method! name_ctyp t = *\) *)
(*   (\*   match super#name_ctyp t with *\) *)
(*   (\*   [`Sem(_,t,`Nil _) *\) *)
(*   (\*   |`Sem(_,`Nil _,t) -> t | t -> t ]  ; *\) *)
(* end; *)

(* change all the [loc] to [ghost] *)    
class reloc _loc = object
  inherit Objs.map ;
  method! loc _ = _loc;
end;

(*
  {[]}
 *)  
let wildcarder = object (self)
  inherit Objs.map as super;
  method! patt = fun
  [ {:patt| $lid:_ |} -> {:patt| _ |}
  | {:patt| ($p as $_) |} -> self#patt p
  | p -> super#patt p ];
end;

