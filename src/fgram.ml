open LibUtil

open Format
include Gstructure
  
include Gentry
include Gstru
    
module Action = Gaction

let default_keywords =
  ["&&"; "functor"; "||"; "private"; "sig"; "include";
   "exception"; "inherit"; "<"; "~"; "and"; 
   "when"; ","; "mod"; "then"; "|]"; "initializer";
   "#";  "!"; "-." ; "_"; ">]" ; "??" ; "in"
     ; "->"; "downto"; "lsr"; "as"; "function"; "begin";
   ".."; ")"; "="; ":"; "|"; "[<"; 
   "class"; "=="; "."; "{<"; "land"; ">}"; "lxor"; "do";
   "end"; "assert"; "external";  "+"; "virtual";
   "to"; "try"; ":>"; "lsl"; "struct"; "else"; "*"; "val"
     ;  "constraint"; "type"; "new"; "of";
   "<-"; "done"; "for"; "&"; ";;"; "{"; "fun"; "method"
     ; "'"; ";"; "mutable"; "lazy"; "["; "}";
   "[|"; "with"; "[^"; "`"; "::"; "]"; "asr"; "[>";
   ":=";  "if"; "while" ; "rec"; "parser"; "object"; "or"; "-"; "("; "match"
     ; "open"; "module";  "?"; ">"; "let"; "lor"; "["]

let gkeywords = ref (SSet.of_list default_keywords)
  

let rec fan_filter = parser
  | ( #Ftoken.space_token,_); 'xs -> fan_filter xs
  |  x; 'xs  ->
      {:stream| x; ' fan_filter xs |}
  |  -> {:stream||}

let rec ignore_layout : Ftoken.filter =
  parser
    | (#Ftoken.space_token,_); 'xs -> ignore_layout  xs
    | x ; 'xs  ->
        {:stream|x; 'ignore_layout xs |}
    | -> {:stream||}
          
let gram =  {
  annot="Fan";
  gfilter =
  { kwds =   SSet.of_list default_keywords ;
    filter = fan_filter;  }
}

let filter = FanTokenFilter.filter gram.gfilter
  
let create_lexer ?(filter=ignore_layout) ~annot ~keywords   () = {
  annot;
  gfilter = {
  kwds = SSet.of_list keywords;
  filter;  
  }
 }


(* FIXME duplicate some code from Entry *)
let mk f = mk_dynamic gram f

let of_parser name strm = of_parser gram name strm

let get_filter () = gram.gfilter


let token_stream_of_string s =
    lex_string FLoc.string_loc s

  
let debug_origin_token_stream (entry:'a t ) tokens : 'a =
  parse_origin_tokens entry (XStream.map (fun t -> (t,FLoc.ghost)) tokens)
  
let debug_filtered_token_stream entry tokens =
  filter_and_parse_tokens entry (XStream.map (fun t -> (t,FLoc.ghost)) tokens)

(* with a special exception handler *)  
let parse_string_safe ?(loc=FLoc.string_loc) entry  s =
  try
    parse_string entry ~loc s
  with FLoc.Exc_located(loc, e) -> begin
      eprintf "%s" (Printexc.to_string e);
      FLoc.error_report (loc,s);
      FLoc.raise loc e ;
  end 
;;
    
    
(* let parse_file_with ~rule file  = *)
(*   if Sys.file_exists file then *)
(*     let ch = open_in file in *)
(*     let st = XStream.of_channel ch in  *)
(*     parse rule (FLoc.mk file) st *)
(*   else  failwithf "@[file: %s not found@]@." file; *)
  


(* FIXME [srules] the productions are also scanned  *)  
(* let srules rl = *)
(*     `Stree (List.fold_right Ginsert.add_production   rl DeadEnd) *)

{:import|
Gfold:
  sfold0
  sfold1
  sfold0sep
  sfold1sep
  ;
|};;    


(* [eoi_entry] could be improved   *)
let eoi_entry entry =
  let open! Gstru in
  let g = gram_of_entry entry in
  let entry_eoi = (mk_dynamic g (name entry ^ "_eoi")) in
  ({:extend| entry_eoi: [  entry{x}; `EOI -> x ] |} ;
   entry_eoi)

let find_level ?position (entry:Gstructure.entry) =
  match entry.desc with
  | Dparser _ -> invalid_arg "Fgram.find_level"
  | Dlevels levs -> let (_,f,_) = Ginsert.find_level ?position entry levs in f



(*************************************************************************)
(** utilities for parsing *)      
let parse_include_file entry =
  let dir_ok file dir = Sys.file_exists (dir ^ file) in
  fun file ->
    let file =
      try (List.find (dir_ok file) ( "./" :: !FConfig.include_dirs )) ^ file
      with | Not_found -> file  in
    let ch = open_in file in
    let st = XStream.of_channel ch in
      parse entry (FLoc.mk file) st
    

let error_report (loc,s) = begin
  prerr_endline (FLoc.to_string loc);
  let (start_bol,stop_bol,
         start_off, stop_off) =
    FLoc.( (start_bol loc,
             stop_bol loc,
             start_off loc,
             stop_off loc)
           ) in
  let abs_start_off = start_bol + start_off in
  let abs_stop_off = stop_bol + stop_off in
  let err_location = String.sub s abs_start_off
      (abs_stop_off - abs_start_off + 1) in
  prerr_endline (sprintf "err: ^%s^" err_location);
end 

let parse_string_of_entry ?(loc=FLoc.mk "<string>") entry  s =
  try parse_string entry  ~loc s  with
    FLoc.Exc_located(loc, e) -> begin
      eprintf "%s" (Printexc.to_string e);
      error_report (loc,s);
      FLoc.raise loc e ;
  end

let wrap_stream_parser ?(loc=FLoc.mk "<stream>") p s =
  try p ~loc s
  with FLoc.Exc_located(loc,e) -> begin
    eprintf "error: %s" (FLoc.to_string loc) ;
    FLoc.raise loc e;
  end 










