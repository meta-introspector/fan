open LibUtil
open FanAst
open Basic
let gen_tuple_abbrev ~arity  ~annot  ~destination  name e =
  let args: patt list =
    List.init arity
      (fun i  ->
         `Alias (_loc, (`PaTyp (_loc, name)), (`Lid (_loc, (x ~off:i 0))))) in
  let exps = List.init arity (fun i  -> `Id (_loc, (xid ~off:i 0))) in
  let e = Expr.apply e exps in
  let pat = args |> tuple_com in
  let open FSig in
    match destination with
    | Obj (Map ) ->
        `Case
          (_loc, pat, (`Nil _loc),
            (`Coercion (_loc, e, (`Id (_loc, name)), annot)))
    | _ ->
        `Case
          (_loc, pat, (`Nil _loc), (`Coercion (_loc, e, (`Nil _loc), annot)))