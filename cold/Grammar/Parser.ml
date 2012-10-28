open Structure
open FanUtil
let loc_bp = Tools.get_cur_loc
let loc_ep = Tools.get_prev_loc
let add_loc bp parse_fun strm =
  let x = (parse_fun strm) in
  let ep = (loc_ep strm) in
  let loc =
    if (( (FanLoc.start_off bp) ) > ( (FanLoc.stop_off ep) )) then begin
      (FanLoc.join bp)
    end else begin
      (FanLoc.merge bp ep)
    end in
  (x,loc)
module StreamOrig = Stream
module Stream = struct
  type 'a t = 'a StreamOrig.t   exception Failure = StreamOrig.Failure
  exception Error = StreamOrig.Error let peek = StreamOrig.peek
  let junk = StreamOrig.junk
  let dup strm =
    let rec loop n =
      (function
      | []  ->   None
      | x::[]  ->   if (n = 0) then begin
                      Some (x)
                    end else begin
                      None
                    end
      | _::l ->   (loop ( (n - 1) ) l)) in
    let peek_nth n = (loop n ( (Stream.npeek ( (n + 1) ) strm) )) in
    (Stream.from peek_nth)
  end
let try_parser ps strm =
  let strm' = (Stream.dup strm) in
  let r = begin try
    (ps strm')
    with
    | Stream.Error _|FanLoc.Exc_located (_,Stream.Error _) ->
        (raise Stream.Failure )
    | exc ->   (raise exc)
  end in begin
    (njunk ( (StreamOrig.count strm') ) strm);
    r
    end
let level_number entry lab =
  let rec lookup levn =
    (function
    | []  ->   (failwith ( ("unknown level " ^ lab) ))
    | lev::levs ->
        if (Tools.is_level_labelled lab lev) then begin
          levn
        end else begin
          (lookup ( (succ levn) ) levs)
        end) in
  begin match entry.edesc with
    | Dlevels elev ->   (lookup 0 elev)
    | Dparser _ ->   (raise Not_found ) end
let strict_parsing = (ref false )
let strict_parsing_warning = (ref false )
let rec top_symb entry =
  (function
  | `Sself|`Snext ->   `Snterm (entry)
  | `Snterml (e,_) ->   `Snterm (e)
  | `Slist1sep (s,sep) ->   `Slist1sep ((( (top_symb entry s) ),sep))
  | _ ->   (raise Stream.Failure ))
let top_tree entry =
  (function
  | Node {node = s;brother = bro;son = son} ->
      Node ({node = ( (top_symb entry s) );brother = bro;son = son})
  | LocAct (_,_)|DeadEnd  ->   (raise Stream.Failure ))
let entry_of_symb entry =
  (function
  | `Sself|`Snext ->   entry
  | `Snterm e ->   e
  | `Snterml (e,_) ->   e
  | _ ->   (raise Stream.Failure ))
let continue entry loc a s son p1 (__strm : _ Stream.t ) =
  let a = (((entry_of_symb entry s).econtinue) 0 loc a __strm) in
  let act = begin try (p1 __strm)
    with
    | Stream.Failure  ->
      (raise ( Stream.Error ((Failed.tree_failed entry a s son)) ))
  end in (Action.mk ( (fun _ -> (Action.getf act a)) ))
let skip_if_empty bp strm =
  if (( (loc_bp strm) ) = bp) then begin
    (Action.mk ( (fun _ -> (raise Stream.Failure )) ))
  end else begin
    (raise Stream.Failure )
  end
let do_recover parser_of_tree entry nlevn alevn loc a s son
  (__strm : _ Stream.t ) = begin try
  (parser_of_tree entry nlevn alevn ( (top_tree entry son) ) __strm)
  with
  | Stream.Failure  ->
    begin try (skip_if_empty loc __strm)
    with
    | Stream.Failure  ->
      (continue entry loc a s son ( (parser_of_tree entry nlevn alevn son) )
        __strm)
  end end
let recover parser_of_tree entry nlevn alevn loc a s son strm =
  if strict_parsing.contents then begin
    (raise ( Stream.Error ((Failed.tree_failed entry a s son)) ))
  end else begin
    let _ =
      if strict_parsing_warning.contents then begin
        let msg = (Failed.tree_failed entry a s son) in
        begin
          (Format.eprintf "Warning: trying to recover from syntax error");
          if (( entry.ename ) <> "") then begin
            (Format.eprintf " in [%s]" ( entry.ename ))
          end else begin
            ()
          end;
          (Format.eprintf "\n%s%a@." msg FanLoc.print loc)
          end
      end else begin
        ()
      end in
    (do_recover parser_of_tree entry nlevn alevn loc a s son strm)
  end
let rec parser_of_tree entry nlevn alevn =
  (function
  | DeadEnd  ->   (fun (__strm : _ Stream.t ) -> (raise Stream.Failure ))
  | LocAct (act,_) ->   (fun (__strm : _ Stream.t ) -> act)
  | Node {node = `Sself;son = LocAct (act,_);brother = DeadEnd } ->
      (fun (__strm : _ Stream.t ) ->
        let a = ((entry.estart) alevn __strm) in (Action.getf act a))
  | Node {node = `Sself;son = LocAct (act,_);brother = bro} ->
      let p2 = (parser_of_tree entry nlevn alevn bro) in
      (fun (__strm : _ Stream.t ) -> begin match begin try
        Some (((entry.estart) alevn __strm))
        with
        | Stream.Failure  ->   None end with
        | Some a ->   (Action.getf act a)
        | _ ->   (p2 __strm) end)
  | Node {node = s;son = son;brother = DeadEnd } ->
      let tokl = begin match s with
        | `Stoken _|`Skeyword _ ->   (Tools.get_token_list entry []  s son)
        | _ ->   None end in
      begin match tokl with
        | None  ->
            let ps = (parser_of_symbol entry nlevn s) in
            let p1 = (parser_of_tree entry nlevn alevn son) in
            let p1 = (parser_cont p1 entry nlevn alevn s son) in
            (fun strm ->
              let bp = (loc_bp strm) in
              let (__strm : _ Stream.t ) = strm in
              let a = (ps __strm) in
              let act = begin try (p1 bp a __strm)
                with
                | Stream.Failure  ->   (raise ( Stream.Error ("") ))
              end in (Action.getf act a))
        | Some (tokl,last_tok,son) ->
            let p1 = (parser_of_tree entry nlevn alevn son) in
            let p1 = (parser_cont p1 entry nlevn alevn last_tok son) in
            (parser_of_token_list p1 tokl)
        end
  | Node {node = s;son = son;brother = bro} ->
      let tokl = begin match s with
        | `Stoken _|`Skeyword _ ->   (Tools.get_token_list entry []  s son)
        | _ ->   None end in
      begin match tokl with
        | None  ->
            let ps = (parser_of_symbol entry nlevn s) in
            let p1 = (parser_of_tree entry nlevn alevn son) in
            let p1 = (parser_cont p1 entry nlevn alevn s son) in
            let p2 = (parser_of_tree entry nlevn alevn bro) in
            (fun strm ->
              let bp = (loc_bp strm) in
              let (__strm : _ Stream.t ) = strm in begin match begin try
                Some ((ps __strm))
                with
                | Stream.Failure  ->   None
              end with
                | Some a ->
                    let act = begin try (p1 bp a __strm)
                      with
                      | Stream.Failure  ->   (raise ( Stream.Error ("") ))
                    end in (Action.getf act a)
                | _ ->   (p2 __strm) end)
        | Some (tokl,last_tok,son) ->
            let p1 = (parser_of_tree entry nlevn alevn son) in
            let p1 = (parser_cont p1 entry nlevn alevn last_tok son) in
            let p1 = (parser_of_token_list p1 tokl) in
            let p2 = (parser_of_tree entry nlevn alevn bro) in
            (fun (__strm : _ Stream.t ) -> begin try
              (p1 __strm)
              with
              | Stream.Failure  ->   (p2 __strm) end)
        end) and parser_cont p1 entry nlevn alevn s son loc a
  (__strm : _ Stream.t ) = begin try (p1 __strm)
  with
  | Stream.Failure  ->
    begin try
    (recover parser_of_tree entry nlevn alevn loc a s son __strm)
    with
    | Stream.Failure  ->
      (raise ( Stream.Error ((Failed.tree_failed entry a s son)) ))
  end end and parser_of_token_list p1 tokl =
  let rec loop n =
    (function
    | `Stoken (tematch,_)::tokl ->
        begin match tokl with
        | []  ->
            let ps strm = begin match (stream_peek_nth n strm) with
              | Some (tok,_) when (tematch tok) ->
                  begin
                  (njunk n strm);
                  (Action.mk tok)
                  end
              | _ ->   (raise Stream.Failure ) end in
            (fun strm ->
              let bp = (loc_bp strm) in
              let (__strm : _ Stream.t ) = strm in
              let a = (ps __strm) in
              let act = begin try (p1 bp a __strm)
                with
                | Stream.Failure  ->   (raise ( Stream.Error ("") ))
              end in (Action.getf act a))
        | _ ->
            let ps strm = begin match (stream_peek_nth n strm) with
              | Some (tok,_) when (tematch tok) ->   tok
              | _ ->   (raise Stream.Failure ) end in
            let p1 = (loop ( (n + 1) ) tokl) in
            (fun (__strm : _ Stream.t ) ->
              let tok = (ps __strm) in
              let s = __strm in let act = (p1 s) in (Action.getf act tok))
        end
    | `Skeyword kwd::tokl ->
        begin match tokl with
        | []  ->
            let ps strm = begin match (stream_peek_nth n strm) with
              | Some (tok,_) when (FanToken.match_keyword kwd tok) ->
                  begin
                  (njunk n strm);
                  (Action.mk tok)
                  end
              | _ ->   (raise Stream.Failure ) end in
            (fun strm ->
              let bp = (loc_bp strm) in
              let (__strm : _ Stream.t ) = strm in
              let a = (ps __strm) in
              let act = begin try (p1 bp a __strm)
                with
                | Stream.Failure  ->   (raise ( Stream.Error ("") ))
              end in (Action.getf act a))
        | _ ->
            let ps strm = begin match (stream_peek_nth n strm) with
              | Some (tok,_) when (FanToken.match_keyword kwd tok) ->   tok
              | _ ->   (raise Stream.Failure ) end in
            let p1 = (loop ( (n + 1) ) tokl) in
            (fun (__strm : _ Stream.t ) ->
              let tok = (ps __strm) in
              let s = __strm in let act = (p1 s) in (Action.getf act tok))
        end
    | _ ->   (invalid_arg "parser_of_token_list")) in
  (loop 1 tokl) and parser_of_symbol entry nlevn =
  (function
  | `Smeta (_,symbl,act) ->
      let act = (Obj.magic act entry symbl) in
      let pl = (List.map ( (parser_of_symbol entry nlevn) ) symbl) in
      (Obj.magic (
        (List.fold_left ( (fun act -> (fun p -> (Obj.magic act p))) ) act pl)
        ))
  | `Slist0 s ->
      let ps = (parser_of_symbol entry nlevn s) in
      let rec loop al (__strm : _ Stream.t ) = begin match begin try
        Some ((ps __strm))
        with
        | Stream.Failure  ->   None
      end with | Some a ->   (loop ( a::al ) __strm)
               | _ ->   al
        end in
      (fun (__strm : _ Stream.t ) ->
        let a = (loop []  __strm) in (Action.mk ( (List.rev a) )))
  | `Slist0sep (symb,sep) ->
      let ps = (parser_of_symbol entry nlevn symb) in
      let pt = (parser_of_symbol entry nlevn sep) in
      let rec kont al (__strm : _ Stream.t ) = begin match begin try
        Some ((pt __strm))
        with
        | Stream.Failure  ->   None
      end with
        | Some v ->
            let a = begin try (ps __strm)
              with
              | Stream.Failure  ->
                (raise ( Stream.Error ((Failed.symb_failed entry v sep symb))
                  ))
            end in (kont ( a::al ) __strm)
        | _ ->   al end in
      (fun (__strm : _ Stream.t ) -> begin match begin try
        Some ((ps __strm))
        with
        | Stream.Failure  ->   None end with
        | Some a ->
            let s = __strm in (Action.mk ( (List.rev ( (kont ( [a] ) s) )) ))
        | _ ->   (Action.mk [] ) end)
  | `Slist1 s ->
      let ps = (parser_of_symbol entry nlevn s) in
      let rec loop al (__strm : _ Stream.t ) = begin match begin try
        Some ((ps __strm))
        with
        | Stream.Failure  ->   None
      end with | Some a ->   (loop ( a::al ) __strm)
               | _ ->   al
        end in
      (fun (__strm : _ Stream.t ) ->
        let a = (ps __strm) in
        let s = __strm in (Action.mk ( (List.rev ( (loop ( [a] ) s) )) )))
  | `Slist1sep (symb,sep) ->
      let ps = (parser_of_symbol entry nlevn symb) in
      let pt = (parser_of_symbol entry nlevn sep) in
      let rec kont al (__strm : _ Stream.t ) = begin match begin try
        Some ((pt __strm))
        with
        | Stream.Failure  ->   None
      end with
        | Some v ->
            let a = begin try (ps __strm)
              with
              | Stream.Failure  ->
                begin try
                (parse_top_symb entry symb __strm)
                with
                | Stream.Failure  ->
                  (raise (
                    Stream.Error ((Failed.symb_failed entry v sep symb)) ))
              end
            end in (kont ( a::al ) __strm)
        | _ ->   al end in
      (fun (__strm : _ Stream.t ) ->
        let a = (ps __strm) in
        let s = __strm in (Action.mk ( (List.rev ( (kont ( [a] ) s) )) )))
  | `Sopt s ->
      let ps = (parser_of_symbol entry nlevn s) in
      (fun (__strm : _ Stream.t ) -> begin match begin try
        Some ((ps __strm))
        with
        | Stream.Failure  ->   None end with
        | Some a ->   (Action.mk ( Some (a) ))
        | _ ->   (Action.mk None ) end)
  | `Stry s ->   let ps = (parser_of_symbol entry nlevn s) in (try_parser ps)
  | `Stree t ->
      let pt = (parser_of_tree entry 1 0 t) in
      (fun strm ->
        let bp = (loc_bp strm) in
        let (__strm : _ Stream.t ) = strm in
        let (act,loc) = (add_loc bp pt __strm) in (Action.getf act loc))
  | `Snterm e ->   (fun (__strm : _ Stream.t ) -> ((e.estart) 0 __strm))
  | `Snterml (e,l) ->
      (fun (__strm : _ Stream.t ) ->
        ((e.estart) ( (level_number e l) ) __strm))
  | `Sself ->   (fun (__strm : _ Stream.t ) -> ((entry.estart) 0 __strm))
  | `Snext ->   (fun (__strm : _ Stream.t ) -> ((entry.estart) nlevn __strm))
  | `Skeyword kwd ->
      (fun (__strm : _ Stream.t ) -> begin match (Stream.peek __strm) with
        | Some (tok,_) when (FanToken.match_keyword kwd tok) ->
            begin
            (Stream.junk __strm);
            (Action.mk tok)
            end
        | _ ->   (raise Stream.Failure ) end)
  | `Stoken (f,_) ->
      (fun (__strm : _ Stream.t ) -> begin match (Stream.peek __strm) with
        | Some (tok,_) when (f tok) ->
            begin
            (Stream.junk __strm);
            (Action.mk tok)
            end
        | _ ->   (raise Stream.Failure ) end)) and parse_top_symb entry symb
  strm = (parser_of_symbol entry 0 ( (top_symb entry symb) ) strm)
let rec start_parser_of_levels entry clevn =
  (function
  | []  ->
      (fun _ -> (fun (__strm : _ Stream.t ) -> (raise Stream.Failure )))
  | lev::levs ->
      let p1 = (start_parser_of_levels entry ( (succ clevn) ) levs) in begin
        match lev.lprefix with
        | DeadEnd  ->   p1
        | tree ->
            let alevn = begin match lev.assoc with
              | `LA|`NA ->   (succ clevn)
              | `RA ->   clevn end in
            let p2 = (parser_of_tree entry ( (succ clevn) ) alevn tree) in
            begin match levs with
              | []  ->
                  (fun levn ->
                    (fun strm ->
                      let bp = (loc_bp strm) in
                      let (__strm : _ Stream.t ) = strm in
                      let (act,loc) = (add_loc bp p2 __strm) in
                      let strm = __strm in
                      let a = (Action.getf act loc) in
                      ((entry.econtinue) levn loc a strm)))
              | _ ->
                  (fun levn ->
                    (fun strm ->
                      if (levn > clevn) then begin
                        (p1 levn strm)
                      end else begin
                        let bp = (loc_bp strm) in
                        let (__strm : _ Stream.t ) = strm in begin match
                          begin try
                          Some ((add_loc bp p2 __strm))
                          with
                          | Stream.Failure  ->   None
                        end with
                          | Some (act,loc) ->
                              let a = (Action.getf act loc) in
                              ((entry.econtinue) levn loc a strm)
                          | _ ->   (p1 levn __strm) end
                      end))
              end
        end)
let start_parser_of_entry entry = begin match entry.edesc with
  | Dlevels ([] ) ->   (Tools.empty_entry ( entry.ename ))
  | Dlevels elev ->   (start_parser_of_levels entry 0 elev)
  | Dparser p ->   (fun _ -> p) end
let rec continue_parser_of_levels entry clevn =
  (function
  | []  ->
      (fun _ ->
        (fun _ ->
          (fun _ -> (fun (__strm : _ Stream.t ) -> (raise Stream.Failure )))))
  | lev::levs ->
      let p1 = (continue_parser_of_levels entry ( (succ clevn) ) levs) in
      begin match lev.lsuffix with
        | DeadEnd  ->   p1
        | tree ->
            let alevn = begin match lev.assoc with
              | `LA|`NA ->   (succ clevn)
              | `RA ->   clevn end in
            let p2 = (parser_of_tree entry ( (succ clevn) ) alevn tree) in
            (fun levn ->
              (fun bp ->
                (fun a ->
                  (fun strm ->
                    if (levn > clevn) then begin
                      (p1 levn bp a strm)
                    end else begin
                      let (__strm : _ Stream.t ) = strm in begin try
                        (p1 levn bp a __strm)
                        with
                        | Stream.Failure  ->
                          let (act,loc) = (add_loc bp p2 __strm) in
                          let a = (Action.getf2 act a loc) in
                          ((entry.econtinue) levn loc a strm)
                      end
                    end))))
        end)
let continue_parser_of_entry entry = begin match entry.edesc with
  | Dlevels elev ->
      let p = (continue_parser_of_levels entry 0 elev) in
      (fun levn ->
        (fun bp ->
          (fun a ->
            (fun (__strm : _ Stream.t ) -> begin try
              (p levn bp a __strm)
              with
              | Stream.Failure  ->   a end))))
  | Dparser _ ->
      (fun _ ->
        (fun _ ->
          (fun _ -> (fun (__strm : _ Stream.t ) -> (raise Stream.Failure )))))
  end