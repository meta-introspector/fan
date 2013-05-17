open AstN


type col = {
    col_label:string;
    col_mutable:bool;
    col_ctyp:ctyp
  }

type vbranch =
   [ `variant of (string* ctyp list )
   | `abbrev of ident ]
type branch =
   [ `branch of (string * ctyp list) ]

type named_type = (string* typedecl)
and and_types = named_type list
and types =
    [ `Mutual of and_types
    | `Single of named_type ]

and mtyps =  types list

type destination =
  |Obj of kind
  |Str_item
and kind =
  | Fold
  | Iter (* Iter style *) 
  | Map (* Map style *)
  | Concrete of ctyp


type warning_type =
  | Abstract of string 
  | Qualified of string 


val arrow_of_list : ctyp list -> ctyp
val app_arrow : ctyp list -> ctyp -> ctyp
val ( <+ ) : string list -> ctyp -> ctyp
val ( +> ) : ctyp list -> ctyp -> ctyp
val name_length_of_tydcl : typedecl -> string * int

val gen_ty_of_tydcl : off:int -> typedecl -> ctyp
val of_id_len : off:int -> ident * int -> ctyp
val of_name_len : off:int -> string * int -> ctyp


val list_of_record : name_ctyp -> col list
val gen_tuple_n : ctyp -> int -> ctyp
val repeat_arrow_n : ctyp -> int -> ctyp

(**
     [result] is a keyword
   {[
   let (name,len) =
   ({:stru| type list 'a  'b = [A of int | B of 'a] |}
     |> function {:stru|type $x |} -> name_length_of_tydcl x)
   let f = mk_method_type ~number:2 ~prefix:["fmt"]
   ({:ident| $lid:name |},len);

   open Fan_sig
   
   f (Obj Map)|> eprint;
   ! 'all_a0 'all_a1 'all_b0 'all_b1.
  ('self_type -> 'fmt -> 'all_a0 -> 'all_a0 -> 'all_b0) ->
  ('self_type -> 'fmt -> 'all_a1 -> 'all_a1 -> 'all_b1) ->
  'fmt ->
  list 'all_a0 'all_a1 -> list 'all_a0 'all_a1 -> list 'all_b0 'all_b1

  f (Obj Iter)|> eprint;
  ! 'all_a0 'all_a1.
  ('self_type -> 'fmt -> 'all_a0 -> 'all_a0 -> 'result) ->
  ('self_type -> 'fmt -> 'all_a1 -> 'all_a1 -> 'result) ->
  'fmt -> list 'all_a0 'all_a1 -> list 'all_a0 'all_a1 -> 'result
  
  f (Obj Fold) |> eprint;
  ! 'all_a0 'all_a1.
  ('self_type -> 'fmt -> 'all_a0 -> 'all_a0 -> 'self_type) ->
  ('self_type -> 'fmt -> 'all_a1 -> 'all_a1 -> 'self_type) ->
  'fmt -> list 'all_a0 'all_a1 -> list 'all_a0 'all_a1 -> 'self_type
  
  f Str_item |> eprint;
  ! 'all_a0 'all_a1.
  ('fmt -> 'all_a0 -> 'all_a0 -> 'result) ->
  ('fmt -> 'all_a1 -> 'all_a1 -> 'result) ->
  'fmt -> list 'all_a0 'all_a1 -> list 'all_a0 'all_a1 -> 'result

 *)
val mk_method_type :
  number:int ->
  prefix:string list -> ident * int -> destination -> (ctyp*ctyp)


(**
   
 *)
val mk_method_type_of_name :
  number:int ->
  prefix:string list -> string * int -> destination -> (ctyp*ctyp)
      
(* val mk_dest_type: destination:destination -> ident * int -> ctyp  *)
        
val mk_obj : string -> string -> clfield -> stru
val is_recursive : typedecl -> bool
val is_abstract : typedecl -> bool

val abstract_list : typedecl -> int option
    
val qualified_app_list : ctyp -> (ident * ctyp list) option


(* val eq : ctyp -> ctyp -> bool *)
(* val eq_list : ctyp list -> ctyp list -> bool *)
(* val mk_transform_type_eq : *)
(*   unit -> FanAst.map *)
  
val transform_mtyps : mtyps ->
  (string * ident * int) list * mtyps

val reduce_data_ctors:
    or_ctyp ->
      'a -> compose:('e -> 'a  -> 'a) -> (string -> ctyp list -> 'e) -> 'a    
(* @raise Invalid_argument *)        
(* val of_stru: stru -> typedecl *)

val view_sum: or_ctyp -> branch list
val view_variant: row_field -> vbranch list    

(* val ty_name_of_tydcl : typedecl -> ctyp *)    
(* val gen_quantifiers : arity:int -> int -> ctyp *)
