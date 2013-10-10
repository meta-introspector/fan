
(** *)    

open OUnit

let (===) = assert_equal



let get_tokens s =
  List.map fst
    (Flex_lib.list_of_string ~verbose:false s )
    
let test_empty_string _ =
  get_tokens {:str|""|}
    ===
  [ `Str "" ; `EOI]  

let test_escaped_string _ =
  get_tokens {:str|"a\n"|}
    ===
  [`Str "a\n"; `EOI]
    
let test_comment_string _ =
  get_tokens {:str|(*(**)*)|}
    ===
  [`Comment"(*(**)*)";`EOI]

let test_char _ =
  get_tokens {:str|'
'|}
    ===
  [`Chr "\n"; `EOI]
;;

(** maybe a bug. Quotation should be loyal to its
    layout *)
let test_string _ =
  get_tokens {:str|"hsoghsogho\n
    haha\
    hahah"|}
    ===
  [`Str "hsoghsogho\n\n    hahahahah"; `EOI]
    
(* This can not be made an unittest
   since our lexer depends on the context which is bad
*)   
let test_quotation _ =
  (Flex_lib.list_of_string ~verbose:false {:str|{:lexer|abcdef|}|} |> List.hd)
  ===
  (`Quot
   {Ftoken.name = (`Sub [], "lexer");
    loc =
     {FLoc.loc_start =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 0};
      loc_end =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0;
        pos_cnum = 16};
      loc_ghost = false};
    meta = None; shift = 8; content = "{:lexer|abcdef|}";retract=2},
 {FLoc.loc_start =
   {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 0};
  loc_end =
   {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 16};
  loc_ghost = false})


let test_ant _ =
  Ref.protect FConfig.antiquotations true @@ fun _ ->
    Flex_lib.list_of_string ~verbose:false "$aa:a"
      ===
    [(`Ant ("aa", "a"),
      {FLoc.loc_start =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 4};
       loc_end =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 5};
       loc_ghost = false});
     (`EOI,
      {FLoc.loc_start =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 5};
       loc_end =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 1; pos_cnum = 6};
       loc_ghost = false})]

let test_ant_quot _ =       
  Ref.protect FConfig.antiquotations true @@ fun _ ->
    Flex_lib.list_of_string ~verbose:false "$(lid:{|)|})"
      ===
    [(`Ant ("lid", "({|)|})"),
      {FLoc.loc_start =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 5};
       loc_end =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 12};
       loc_ghost = false});
     (`EOI,
      {FLoc.loc_start =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 12};
       loc_end =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 1; pos_cnum = 13};
       loc_ghost = false})]

let test_ant_paren _ =       
  Ref.protect FConfig.antiquotations true @@ fun _ ->
    Flex_lib.list_of_string ~verbose:false "$((l:>FAst.pat))"
      ===
    [(`Ant ("", "((l:>FAst.pat))"),
      {FLoc.loc_start =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 1};
       loc_end =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 16};
       loc_ghost = false});
     (`EOI,
      {FLoc.loc_start =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 16};
       loc_end =
       {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 1; pos_cnum = 17};
       loc_ghost = false})]

let test_ant_str _ =
  Ref.protect FConfig.antiquotations true @@ fun _ -> Flex_lib.get_tokens {:str|$(")")|}
      ===
    [`Ant ("", "(\")\")"); `EOI]

let test_ant_chr _ = 
  Ref.protect FConfig.antiquotations true @@ fun _ -> Flex_lib.get_tokens {:str|$(')')|}
      ===
    [`Ant("","(')')"); `EOI ]

let test_comment_pos _ =
  Flex_lib.list_of_string ~verbose:false {:str|(*    (**) *)|}
    ===
  [(`Comment "(*    (**) *)",
  {FLoc.loc_start =
    {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 0};
   loc_end =
    {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 13};
   loc_ghost = false});
   (`EOI,
    {FLoc.loc_start =
     {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 13};
     loc_end =
     {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 1; pos_cnum = 14};
     loc_ghost = false})]

let test_lex_simple_quot _ =
  fst @@ Lex_lex.token (Lexing.from_string {:str|{ (** gshoghso *) bhgo "ghos" }|})
    ===
  `Quot {
         Ftoken.name = (`Sub [], "");
         loc =
         {FLoc.loc_start =
          {FLoc.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 0};
          loc_end =
          {FLoc.pos_fname = ""; pos_lnum = 1; pos_bol = 0; pos_cnum = 31};
          loc_ghost = false};
         meta = None; shift = 1; content = "{ * gshoghso *) bhgo \"ghos\" }";
         retract = 1}

let test_symb _ =
  Flex_lib.list_of_string ~verbose:false "(%***{)"
    ===
  [(`Sym "(",
  {FLoc.loc_start =
    {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 0};
   loc_end =
    {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 1};
   loc_ghost = false});
 (`Sym "%***",
  {FLoc.loc_start =
    {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 1};
   loc_end =
    {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 5};
   loc_ghost = false});
 (`Sym "{",
  {FLoc.loc_start =
    {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 5};
   loc_end =
    {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 6};
   loc_ghost = false});
 (`Sym ")",
  {FLoc.loc_start =
    {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 6};
   loc_end =
    {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 7};
   loc_ghost = false});
 (`EOI,
  {FLoc.loc_start =
    {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 0; pos_cnum = 7};
   loc_end =
    {FLoc.pos_fname = "<string>"; pos_lnum = 1; pos_bol = 1; pos_cnum = 8};
   loc_ghost = false})]

    
(* let test_simple_arith _ = *)
(*   assert_equal ~msg:("\n" ^ {:here||}) 3 4 *)
           
let suite =
  "Lexing_test" >:::
  [
  "test_comment_pos" >:: test_comment_pos;

   "test_ant_chr" >:: test_ant_chr;

   "test_empty_string" >:: test_empty_string;

   "test_escaped_string" >:: test_escaped_string;

   "test_comment_string" >:: test_comment_string;

   "test_quotation" >:: test_quotation;

   "test_string" >:: test_string;
   
   "test_char" >:: test_char;
   "test_ant" >:: test_ant;
   "test_ant_quot" >:: test_ant_quot;
   "test_ant_paren" >:: test_ant_paren;
   "test_ant_str" >:: test_ant_str;
   "test_lex_simple_quot" >:: test_lex_simple_quot;
   "test_symb" >:: test_symb
   (* "test_simple_arith" >:: test_simple_arith *)
 ]

    
(* local variables: *)
(* compile-command: "cd ../unitest_annot && pmake lexing_test.cmo" *)
(* end: *)
