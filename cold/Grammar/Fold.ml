let sfold0 f e _entry _symbl psymb =
  let rec fold accu (__strm : _ Stream.t ) =
    match try Some (psymb __strm) with | Stream.Failure  -> None with
    | Some a -> fold (f a accu) __strm
    | _ -> accu in
  fun (__strm : _ Stream.t ) -> fold e __strm
let sfold1 f e _entry _symbl psymb =
  let rec fold accu (__strm : _ Stream.t ) =
    match try Some (psymb __strm) with | Stream.Failure  -> None with
    | Some a -> fold (f a accu) __strm
    | _ -> accu in
  fun (__strm : _ Stream.t ) ->
    let a = psymb __strm in
    try fold (f a e) __strm with | Stream.Failure  -> raise (Stream.Error "")
let sfold0sep f e entry symbl psymb psep =
  let failed =
    function
    | symb::sep::[] -> Failed.symb_failed_txt entry sep symb
    | _ -> "failed" in
  let rec kont accu (__strm : _ Stream.t ) =
    match try Some (psep __strm) with | Stream.Failure  -> None with
    | Some () ->
        let a =
          (try psymb __strm
           with | Stream.Failure  -> raise (Stream.Error (failed symbl))) in
        kont (f a accu) __strm
    | _ -> accu in
  fun (__strm : _ Stream.t ) ->
    match try Some (psymb __strm) with | Stream.Failure  -> None with
    | Some a -> kont (f a e) __strm
    | _ -> e