let gm = Compile_gram.gm
let module_name = Compile_gram.module_name
let mk_entry = Compile_gram.mk_entry
let mk_level = Compile_gram.mk_level
let mk_rule = Compile_gram.mk_rule
let mk_slist = Compile_gram.mk_slist
let mk_symbol = Compile_gram.mk_symbol
let make = Compile_gram.make
let is_irrefut_pat = Fan_ops.is_irrefut_pat
let sem_of_list = Ast_gen.sem_of_list
let loc_of = Ast_gen.loc_of
let seq_sem = Ast_gen.seq_sem
let tuple_com = Ast_gen.tuple_com
let mk_name _loc (i : FAst.vid) =
  (let rec aux x =
     match (x : FAst.vid ) with
     | `Lid (_,x)|`Uid (_,x) -> x
     | `Dot (_,`Uid (_,x),xs) -> x ^ ("__" ^ (aux xs))
     | _ -> failwith "internal error in the Grammar extension" in
   { exp = (i :>FAst.exp); tvar = (aux i); loc = _loc } : Gram_def.name )
open FAst
open Util
let g =
  Gramf.create_lexer ~annot:"Grammar's lexer"
    ~keywords:["(";
              ")";
              ",";
              "as";
              "|";
              "_";
              ":";
              ".";
              ";";
              "{";
              "}";
              "let";
              "[";
              "]";
              "SEP";
              "LEVEL";
              "S";
              "EOI";
              "Lid";
              "Uid";
              "Ant";
              "Quot";
              "DirQuotation";
              "Str";
              "Label";
              "Optlabel";
              "Chr";
              "Int";
              "Int32";
              "Int64";
              "Int64";
              "Nativeint";
              "Flo";
              "OPT";
              "TRY";
              "PEEK";
              "L0";
              "L1";
              "First";
              "Last";
              "Before";
              "After";
              "Level";
              "LA";
              "RA";
              "NA";
              "+";
              "*";
              "?";
              "=";
              "@";
              "Inline"] ()
let inline_rules: (string,Gram_def.rule list) Hashtbl.t = Hashtbl.create 50
let query_inline (x : string) = Hashtblf.find_opt inline_rules x
let extend_header = Gramf.mk_dynamic g "extend_header"
let qualuid: vid Gramf.t = Gramf.mk_dynamic g "qualuid"
let qualid: vid Gramf.t = Gramf.mk_dynamic g "qualid"
let t_qualid: vid Gramf.t = Gramf.mk_dynamic g "t_qualid"
let entry_name:
  ([ `name of Tokenf.name option | `non]* Gram_def.name) Gramf.t =
  Gramf.mk_dynamic g "entry_name"
let position = Gramf.mk_dynamic g "position"
let assoc = Gramf.mk_dynamic g "assoc"
let name = Gramf.mk_dynamic g "name"
let string = Gramf.mk_dynamic g "string"
let rules = Gramf.mk_dynamic g "rules"
let symbol = Gramf.mk_dynamic g "symbol"
let rule = Gramf.mk_dynamic g "rule"
let meta_rule = Gramf.mk_dynamic g "meta_rule"
let rule_list = Gramf.mk_dynamic g "rule_list"
let psymbol = Gramf.mk_dynamic g "psymbol"
let level = Gramf.mk_dynamic g "level"
let level_list = Gramf.mk_dynamic g "level_list"
let entry: Gram_def.entry option Gramf.t = Gramf.mk_dynamic g "entry"
let extend_body = Gramf.mk_dynamic g "extend_body"
let unsafe_extend_body = Gramf.mk_dynamic g "unsafe_extend_body"
let simple: Gram_def.symbol list Gramf.t = Gramf.mk_dynamic g "simple"
let _ =
  let grammar_entry_create x = Gramf.mk_dynamic g x in
  let or_words: 'or_words Gramf.t = grammar_entry_create "or_words"
  and str: 'str Gramf.t = grammar_entry_create "str"
  and or_strs: 'or_strs Gramf.t = grammar_entry_create "or_strs"
  and str0: 'str0 Gramf.t = grammar_entry_create "str0"
  and level_str: 'level_str Gramf.t = grammar_entry_create "level_str"
  and sep_symbol: 'sep_symbol Gramf.t = grammar_entry_create "sep_symbol"
  and brace_pattern: 'brace_pattern Gramf.t =
    grammar_entry_create "brace_pattern" in
  Gramf.extend_single (or_words : 'or_words Gramf.t )
    (None,
      (None, None,
        [([`Slist1sep
             ((`Snterm (Gramf.obj (str : 'str Gramf.t ))), (`Skeyword "|"))],
           ("(v, None)\n",
             (Gramf.mk_action
                (fun (v : 'str list)  (_loc : Locf.t)  ->
                   ((v, None) : 'or_words )))));
        ([`Slist1sep
            ((`Snterm (Gramf.obj (str : 'str Gramf.t ))), (`Skeyword "|"));
         `Skeyword "as";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid s")],
          ("(v, (Some (xloc, s)))\n",
            (Gramf.mk_action
               (fun (__fan_2 : Tokenf.t)  _  (v : 'str list)  (_loc : Locf.t)
                   ->
                  match __fan_2 with
                  | `Lid ({ loc = xloc; txt = s;_} : Tokenf.txt) ->
                      ((v, (Some (xloc, s))) : 'or_words )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_2))))))]));
  Gramf.extend_single (str : 'str Gramf.t )
    (None,
      (None, None,
        [([`Stoken
             (((function | `Str _ -> true | _ -> false)), (4153489, `Any),
               "`Str s")],
           ("(s, _loc)\n",
             (Gramf.mk_action
                (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                   match __fan_0 with
                   | `Str ({ txt = s;_} : Tokenf.txt) -> ((s, _loc) : 'str )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))))]));
  Gramf.extend_single (simple : 'simple Gramf.t )
    (None,
      (None, None,
        [([`Skeyword "EOI"],
           ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, \"EOI\")), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Empty\"))))) in\nlet des_str = Gram_pat.to_string (`Vrn (_loc, v)) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern = None\n }]\n",
             (Gramf.mk_action
                (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                   match __fan_0 with
                   | `Key ({ txt = v;_} : Tokenf.txt) ->
                       (let i = hash_variant v in
                        let pred: FAst.exp =
                          `Fun
                            (_loc,
                              (`Bar
                                 (_loc,
                                   (`Case
                                      (_loc,
                                        (`App
                                           (_loc, (`Vrn (_loc, "EOI")),
                                             (`Any _loc))),
                                        (`Lid (_loc, "true")))),
                                   (`Case
                                      (_loc, (`Any _loc),
                                        (`Lid (_loc, "false"))))))) in
                        let des: FAst.exp =
                          `Par
                            (_loc,
                              (`Com
                                 (_loc, (`Int (_loc, (string_of_int i))),
                                   (`Vrn (_loc, "Empty"))))) in
                        let des_str = Gram_pat.to_string (`Vrn (_loc, v)) in
                        [{
                           Gram_def.text =
                             (`Stoken (_loc, pred, des, des_str));
                           styp = (`Tok _loc);
                           pattern = None
                         }] : 'simple )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Lid";
         `Stoken
           (((function | `Str _ -> true | _ -> false)), (4153489, `Any),
             "`Str x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc,\n                (`App\n                   (_loc, (`Vrn (_loc, v)),\n                     (`Constraint\n                        (_loc,\n                          (`Record\n                             (_loc,\n                               (`Sem\n                                  (_loc,\n                                    (`RecBind\n                                       (_loc, (`Lid (_loc, \"txt\")),\n                                         (`Str (_loc, x)))), (`Any _loc))))),\n                          (`Dot\n                             (_loc, (`Uid (_loc, \"Tokenf\")),\n                               (`Lid (_loc, \"txt\")))))))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com\n         (_loc, (`Int (_loc, (string_of_int i))),\n           (`App (_loc, (`Vrn (_loc, \"A\")), (`Str (_loc, x))))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Str (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Str (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Str ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Constraint
                                               (_loc,
                                                 (`Record
                                                    (_loc,
                                                      (`Sem
                                                         (_loc,
                                                           (`RecBind
                                                              (_loc,
                                                                (`Lid
                                                                   (_loc,
                                                                    "txt")),
                                                                (`Str
                                                                   (_loc, x)))),
                                                           (`Any _loc))))),
                                                 (`Dot
                                                    (_loc,
                                                      (`Uid (_loc, "Tokenf")),
                                                      (`Lid (_loc, "txt")))))))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`App
                                     (_loc, (`Vrn (_loc, "A")),
                                       (`Str (_loc, x))))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Str (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Str (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Uid";
         `Stoken
           (((function | `Str _ -> true | _ -> false)), (4153489, `Any),
             "`Str x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc,\n                (`App\n                   (_loc, (`Vrn (_loc, v)),\n                     (`Constraint\n                        (_loc,\n                          (`Record\n                             (_loc,\n                               (`Sem\n                                  (_loc,\n                                    (`RecBind\n                                       (_loc, (`Lid (_loc, \"txt\")),\n                                         (`Str (_loc, x)))), (`Any _loc))))),\n                          (`Dot\n                             (_loc, (`Uid (_loc, \"Tokenf\")),\n                               (`Lid (_loc, \"txt\")))))))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com\n         (_loc, (`Int (_loc, (string_of_int i))),\n           (`App (_loc, (`Vrn (_loc, \"A\")), (`Str (_loc, x))))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Str (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Str (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Str ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Constraint
                                               (_loc,
                                                 (`Record
                                                    (_loc,
                                                      (`Sem
                                                         (_loc,
                                                           (`RecBind
                                                              (_loc,
                                                                (`Lid
                                                                   (_loc,
                                                                    "txt")),
                                                                (`Str
                                                                   (_loc, x)))),
                                                           (`Any _loc))))),
                                                 (`Dot
                                                    (_loc,
                                                      (`Uid (_loc, "Tokenf")),
                                                      (`Lid (_loc, "txt")))))))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`App
                                     (_loc, (`Vrn (_loc, "A")),
                                       (`Str (_loc, x))))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Str (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Str (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Str";
         `Stoken
           (((function | `Str _ -> true | _ -> false)), (4153489, `Any),
             "`Str x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc,\n                (`App\n                   (_loc, (`Vrn (_loc, v)),\n                     (`Constraint\n                        (_loc,\n                          (`Record\n                             (_loc,\n                               (`Sem\n                                  (_loc,\n                                    (`RecBind\n                                       (_loc, (`Lid (_loc, \"txt\")),\n                                         (`Str (_loc, x)))), (`Any _loc))))),\n                          (`Dot\n                             (_loc, (`Uid (_loc, \"Tokenf\")),\n                               (`Lid (_loc, \"txt\")))))))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com\n         (_loc, (`Int (_loc, (string_of_int i))),\n           (`App (_loc, (`Vrn (_loc, \"A\")), (`Str (_loc, x))))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Str (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Str (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Str ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Constraint
                                               (_loc,
                                                 (`Record
                                                    (_loc,
                                                      (`Sem
                                                         (_loc,
                                                           (`RecBind
                                                              (_loc,
                                                                (`Lid
                                                                   (_loc,
                                                                    "txt")),
                                                                (`Str
                                                                   (_loc, x)))),
                                                           (`Any _loc))))),
                                                 (`Dot
                                                    (_loc,
                                                      (`Uid (_loc, "Tokenf")),
                                                      (`Lid (_loc, "txt")))))))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`App
                                     (_loc, (`Vrn (_loc, "A")),
                                       (`Str (_loc, x))))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Str (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Str (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Lid";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Lid (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Lid (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Uid";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Lid (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Lid (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Int";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Lid (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Lid (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Int32";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Lid (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Lid (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Int64";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Lid (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Lid (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Nativeint";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Lid (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Lid (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Flo";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Lid (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Lid (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Chr";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Lid (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Lid (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Label";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Lid (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Lid (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Optlabel";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Lid (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Lid (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Str";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"txt\")), (`Lid (xloc, x)))),\n                        (`Any xloc))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "txt")),
                                                    (`Lid (xloc, x)))),
                                               (`Any xloc))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Lid";
         `Skeyword "@";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid loc");
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"loc\")), (`Lid (xloc, loc)))),\n                        (`Sem\n                           (xloc,\n                             (`RecBind\n                                (xloc, (`Lid (xloc, \"txt\")),\n                                  (`Lid (xloc, x)))), (`Any xloc))))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_3 : Tokenf.t)  (__fan_2 : Tokenf.t)  _ 
                  (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match (__fan_3, __fan_2, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Lid
                                                                    ({
                                                                    txt = loc;_}
                                                                    :
                                                                    Tokenf.txt),
                     `Key ({ txt = v;_} : Tokenf.txt)) ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "loc")),
                                                    (`Lid (xloc, loc)))),
                                               (`Sem
                                                  (xloc,
                                                    (`RecBind
                                                       (xloc,
                                                         (`Lid (xloc, "txt")),
                                                         (`Lid (xloc, x)))),
                                                    (`Any xloc))))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s %s" (Tokenf.to_string __fan_3)
                           (Tokenf.to_string __fan_2)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Uid";
         `Skeyword "@";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid loc");
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"loc\")), (`Lid (xloc, loc)))),\n                        (`Sem\n                           (xloc,\n                             (`RecBind\n                                (xloc, (`Lid (xloc, \"txt\")),\n                                  (`Lid (xloc, x)))), (`Any xloc))))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_3 : Tokenf.t)  (__fan_2 : Tokenf.t)  _ 
                  (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match (__fan_3, __fan_2, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Lid
                                                                    ({
                                                                    txt = loc;_}
                                                                    :
                                                                    Tokenf.txt),
                     `Key ({ txt = v;_} : Tokenf.txt)) ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "loc")),
                                                    (`Lid (xloc, loc)))),
                                               (`Sem
                                                  (xloc,
                                                    (`RecBind
                                                       (xloc,
                                                         (`Lid (xloc, "txt")),
                                                         (`Lid (xloc, x)))),
                                                    (`Any xloc))))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s %s" (Tokenf.to_string __fan_3)
                           (Tokenf.to_string __fan_2)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Str";
         `Skeyword "@";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid loc");
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str =\n  Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in\nlet pattern =\n  Some\n    (`App\n       (xloc, (`Vrn (xloc, v)),\n         (`Constraint\n            (xloc,\n              (`Record\n                 (xloc,\n                   (`Sem\n                      (xloc,\n                        (`RecBind\n                           (xloc, (`Lid (xloc, \"loc\")), (`Lid (xloc, loc)))),\n                        (`Sem\n                           (xloc,\n                             (`RecBind\n                                (xloc, (`Lid (xloc, \"txt\")),\n                                  (`Lid (xloc, x)))), (`Any xloc))))))),\n              (`Dot (xloc, (`Uid (xloc, \"Tokenf\")), (`Lid (xloc, \"txt\"))))))) : \n    FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_3 : Tokenf.t)  (__fan_2 : Tokenf.t)  _ 
                  (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match (__fan_3, __fan_2, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = x;_} : Tokenf.txt),`Lid
                                                                    ({
                                                                    txt = loc;_}
                                                                    :
                                                                    Tokenf.txt),
                     `Key ({ txt = v;_} : Tokenf.txt)) ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x)))) in
                       let pattern =
                         Some
                           (`App
                              (xloc, (`Vrn (xloc, v)),
                                (`Constraint
                                   (xloc,
                                     (`Record
                                        (xloc,
                                          (`Sem
                                             (xloc,
                                               (`RecBind
                                                  (xloc,
                                                    (`Lid (xloc, "loc")),
                                                    (`Lid (xloc, loc)))),
                                               (`Sem
                                                  (xloc,
                                                    (`RecBind
                                                       (xloc,
                                                         (`Lid (xloc, "txt")),
                                                         (`Lid (xloc, x)))),
                                                    (`Any xloc))))))),
                                     (`Dot
                                        (xloc, (`Uid (xloc, "Tokenf")),
                                          (`Lid (xloc, "txt"))))))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s %s" (Tokenf.to_string __fan_3)
                           (Tokenf.to_string __fan_2)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Lid"],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str = Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))) in\nlet pattern = None in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Key ({ txt = v;_} : Tokenf.txt) ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))) in
                       let pattern = None in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Uid"],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str = Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))) in\nlet pattern = None in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Key ({ txt = v;_} : Tokenf.txt) ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))) in
                       let pattern = None in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Str"],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str = Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))) in\nlet pattern = None in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Key ({ txt = v;_} : Tokenf.txt) ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))) in
                       let pattern = None in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Quot";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str = Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))) in\nlet pattern =\n  Some (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x))) : FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ txt = x;_} : Tokenf.txt),`Key
                                                        ({ txt = v;_} :
                                                          Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))) in
                       let pattern =
                         Some
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "DirQuotation";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("let i = hash_variant v in\nlet pred: FAst.exp =\n  `Fun\n    (_loc,\n      (`Bar\n         (_loc,\n           (`Case\n              (_loc, (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))),\n                (`Lid (_loc, \"true\")))),\n           (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\nlet des: FAst.exp =\n  `Par\n    (_loc,\n      (`Com (_loc, (`Int (_loc, (string_of_int i))), (`Vrn (_loc, \"Any\"))))) in\nlet des_str = Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))) in\nlet pattern =\n  Some (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x))) : FAst.pat ) in\n[{\n   Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n   styp = (`Tok _loc);\n   pattern\n }]\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_1, __fan_0) with
                  | (`Lid ({ txt = x;_} : Tokenf.txt),`Key
                                                        ({ txt = v;_} :
                                                          Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let pred: FAst.exp =
                         `Fun
                           (_loc,
                             (`Bar
                                (_loc,
                                  (`Case
                                     (_loc,
                                       (`App
                                          (_loc, (`Vrn (_loc, v)),
                                            (`Any _loc))),
                                       (`Lid (_loc, "true")))),
                                  (`Case
                                     (_loc, (`Any _loc),
                                       (`Lid (_loc, "false"))))))) in
                       let des: FAst.exp =
                         `Par
                           (_loc,
                             (`Com
                                (_loc, (`Int (_loc, (string_of_int i))),
                                  (`Vrn (_loc, "Any"))))) in
                       let des_str =
                         Gram_pat.to_string
                           (`App (_loc, (`Vrn (_loc, v)), (`Any _loc))) in
                       let pattern =
                         Some
                           (`App (_loc, (`Vrn (_loc, v)), (`Lid (_loc, x))) : 
                           FAst.pat ) in
                       [{
                          Gram_def.text =
                            (`Stoken (_loc, pred, des, des_str));
                          styp = (`Tok _loc);
                          pattern
                        }] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_1)
                           (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Ant";
         `Skeyword "(";
         `Snterm (Gramf.obj (or_words : 'or_words Gramf.t ));
         `Skeyword ",";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid s");
         `Skeyword ")"],
          ("let i = hash_variant v in\nlet p = `Lid (xloc, s) in\nmatch ps with\n| (vs,y) ->\n    vs |>\n      (List.map\n         (fun (x,xloc)  ->\n            let z = `Str (xloc, x) in\n            let pred: FAst.exp =\n              `Fun\n                (_loc,\n                  (`Bar\n                     (_loc,\n                       (`Case\n                          (_loc,\n                            (`App\n                               (_loc, (`Vrn (_loc, v)),\n                                 (`Constraint\n                                    (_loc,\n                                      (`Record\n                                         (_loc,\n                                           (`Sem\n                                              (_loc,\n                                                (`RecBind\n                                                   (_loc,\n                                                     (`Lid (_loc, \"kind\")),\n                                                     z)), (`Any _loc))))),\n                                      (`Dot\n                                         (_loc, (`Uid (_loc, \"Tokenf\")),\n                                           (`Lid (_loc, \"ant\")))))))),\n                            (`Lid (_loc, \"true\")))),\n                       (`Case (_loc, (`Any _loc), (`Lid (_loc, \"false\"))))))) in\n            let des: FAst.exp =\n              `Par\n                (_loc,\n                  (`Com\n                     (_loc, (`Int (_loc, (string_of_int i))),\n                       (`App (_loc, (`Vrn (_loc, \"A\")), z))))) in\n            let des_str =\n              Gram_pat.to_string (`App (_loc, (`Vrn (_loc, v)), p)) in\n            let pp =\n              match y with\n              | None  -> (z : FAst.pat )\n              | Some (xloc,u) ->\n                  (`Alias (xloc, z, (`Lid (xloc, u))) : FAst.pat ) in\n            let pattern =\n              Some\n                (`App\n                   (_loc, (`Vrn (_loc, v)),\n                     (`Constraint\n                        (_loc,\n                          (`Alias\n                             (_loc,\n                               (`Record\n                                  (_loc,\n                                    (`Sem\n                                       (_loc,\n                                         (`RecBind\n                                            (_loc, (`Lid (_loc, \"kind\")), pp)),\n                                         (`Any _loc))))), p)),\n                          (`Dot\n                             (_loc, (`Uid (_loc, \"Tokenf\")),\n                               (`Lid (_loc, \"ant\"))))))) : FAst.pat ) in\n            {\n              Gram_def.text = (`Stoken (_loc, pred, des, des_str));\n              styp = (`Tok _loc);\n              pattern\n            }))\n",
            (Gramf.mk_action
               (fun _  (__fan_4 : Tokenf.t)  _  (ps : 'or_words)  _ 
                  (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match (__fan_4, __fan_0) with
                  | (`Lid ({ loc = xloc; txt = s;_} : Tokenf.txt),`Key
                                                                    ({
                                                                    txt = v;_}
                                                                    :
                                                                    Tokenf.txt))
                      ->
                      (let i = hash_variant v in
                       let p = `Lid (xloc, s) in
                       (match ps with
                        | (vs,y) ->
                            vs |>
                              (List.map
                                 (fun (x,xloc)  ->
                                    let z = `Str (xloc, x) in
                                    let pred: FAst.exp =
                                      `Fun
                                        (_loc,
                                          (`Bar
                                             (_loc,
                                               (`Case
                                                  (_loc,
                                                    (`App
                                                       (_loc,
                                                         (`Vrn (_loc, v)),
                                                         (`Constraint
                                                            (_loc,
                                                              (`Record
                                                                 (_loc,
                                                                   (`Sem
                                                                    (_loc,
                                                                    (`RecBind
                                                                    (_loc,
                                                                    (`Lid
                                                                    (_loc,
                                                                    "kind")),
                                                                    z)),
                                                                    (`Any
                                                                    _loc))))),
                                                              (`Dot
                                                                 (_loc,
                                                                   (`Uid
                                                                    (_loc,
                                                                    "Tokenf")),
                                                                   (`Lid
                                                                    (_loc,
                                                                    "ant")))))))),
                                                    (`Lid (_loc, "true")))),
                                               (`Case
                                                  (_loc, (`Any _loc),
                                                    (`Lid (_loc, "false"))))))) in
                                    let des: FAst.exp =
                                      `Par
                                        (_loc,
                                          (`Com
                                             (_loc,
                                               (`Int
                                                  (_loc, (string_of_int i))),
                                               (`App
                                                  (_loc, (`Vrn (_loc, "A")),
                                                    z))))) in
                                    let des_str =
                                      Gram_pat.to_string
                                        (`App (_loc, (`Vrn (_loc, v)), p)) in
                                    let pp =
                                      match y with
                                      | None  -> (z : FAst.pat )
                                      | Some (xloc,u) ->
                                          (`Alias (xloc, z, (`Lid (xloc, u))) : 
                                          FAst.pat ) in
                                    let pattern =
                                      Some
                                        (`App
                                           (_loc, (`Vrn (_loc, v)),
                                             (`Constraint
                                                (_loc,
                                                  (`Alias
                                                     (_loc,
                                                       (`Record
                                                          (_loc,
                                                            (`Sem
                                                               (_loc,
                                                                 (`RecBind
                                                                    (_loc,
                                                                    (`Lid
                                                                    (_loc,
                                                                    "kind")),
                                                                    pp)),
                                                                 (`Any _loc))))),
                                                       p)),
                                                  (`Dot
                                                     (_loc,
                                                       (`Uid (_loc, "Tokenf")),
                                                       (`Lid (_loc, "ant"))))))) : 
                                        FAst.pat ) in
                                    {
                                      Gram_def.text =
                                        (`Stoken (_loc, pred, des, des_str));
                                      styp = (`Tok _loc);
                                      pattern
                                    }))) : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_4)
                           (Tokenf.to_string __fan_0))))));
        ([`Stoken
            (((function | `Str _ -> true | _ -> false)), (4153489, `Any),
              "`Str s")],
          ("[mk_symbol ~text:(`Skeyword (_loc, s)) ~styp:(`Tok _loc) ~pattern:None]\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Str ({ txt = s;_} : Tokenf.txt) ->
                      ([mk_symbol ~text:(`Skeyword (_loc, s))
                          ~styp:(`Tok _loc) ~pattern:None] : 'simple )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "(";
         `Snterm (Gramf.obj (or_strs : 'or_strs Gramf.t ));
         `Skeyword ")"],
          ("match v with\n| (vs,None ) ->\n    vs |>\n      (List.map\n         (fun x  ->\n            mk_symbol ~text:(`Skeyword (_loc, x)) ~styp:(`Tok _loc)\n              ~pattern:None))\n| (vs,Some b) ->\n    vs |>\n      (List.map\n         (fun x  ->\n            mk_symbol ~text:(`Skeyword (_loc, x)) ~styp:(`Tok _loc)\n              ~pattern:(Some\n                          (`App\n                             (_loc, (`Vrn (_loc, \"Key\")),\n                               (`Constraint\n                                  (_loc,\n                                    (`Record\n                                       (_loc,\n                                         (`Sem\n                                            (_loc,\n                                              (`RecBind\n                                                 (_loc, (`Lid (_loc, \"txt\")),\n                                                   (`Lid (_loc, b)))),\n                                              (`Any _loc))))),\n                                    (`Dot\n                                       (_loc, (`Uid (_loc, \"Tokenf\")),\n                                         (`Lid (_loc, \"txt\"))))))) : \n                          FAst.pat ))))\n",
            (Gramf.mk_action
               (fun _  (v : 'or_strs)  _  (_loc : Locf.t)  ->
                  (match v with
                   | (vs,None ) ->
                       vs |>
                         (List.map
                            (fun x  ->
                               mk_symbol ~text:(`Skeyword (_loc, x))
                                 ~styp:(`Tok _loc) ~pattern:None))
                   | (vs,Some b) ->
                       vs |>
                         (List.map
                            (fun x  ->
                               mk_symbol ~text:(`Skeyword (_loc, x))
                                 ~styp:(`Tok _loc)
                                 ~pattern:(Some
                                             (`App
                                                (_loc, (`Vrn (_loc, "Key")),
                                                  (`Constraint
                                                     (_loc,
                                                       (`Record
                                                          (_loc,
                                                            (`Sem
                                                               (_loc,
                                                                 (`RecBind
                                                                    (_loc,
                                                                    (`Lid
                                                                    (_loc,
                                                                    "txt")),
                                                                    (`Lid
                                                                    (_loc, b)))),
                                                                 (`Any _loc))))),
                                                       (`Dot
                                                          (_loc,
                                                            (`Uid
                                                               (_loc,
                                                                 "Tokenf")),
                                                            (`Lid
                                                               (_loc, "txt"))))))) : 
                                             FAst.pat )))) : 'simple )))));
        ([`Skeyword "S"],
          ("[mk_symbol ~text:(`Sself _loc) ~styp:(`Self _loc) ~pattern:None]\n",
            (Gramf.mk_action
               (fun _  (_loc : Locf.t)  ->
                  ([mk_symbol ~text:(`Sself _loc) ~styp:(`Self _loc)
                      ~pattern:None] : 'simple )))));
        ([`Snterm (Gramf.obj (name : 'name Gramf.t ));
         `Sopt (`Snterm (Gramf.obj (level_str : 'level_str Gramf.t )))],
          ("[mk_symbol ~text:(`Snterm (_loc, n, lev))\n   ~styp:(`Quote (_loc, (`Normal _loc), (`Lid (_loc, (n.tvar)))))\n   ~pattern:None]\n",
            (Gramf.mk_action
               (fun (lev : 'level_str option)  (n : 'name)  (_loc : Locf.t) 
                  ->
                  ([mk_symbol ~text:(`Snterm (_loc, n, lev))
                      ~styp:(`Quote
                               (_loc, (`Normal _loc),
                                 (`Lid (_loc, (n.tvar))))) ~pattern:None] : 
                  'simple )))))]));
  Gramf.extend_single (or_strs : 'or_strs Gramf.t )
    (None,
      (None, None,
        [([`Slist1sep
             ((`Snterm (Gramf.obj (str0 : 'str0 Gramf.t ))), (`Skeyword "|"))],
           ("(xs, None)\n",
             (Gramf.mk_action
                (fun (xs : 'str0 list)  (_loc : Locf.t)  ->
                   ((xs, None) : 'or_strs )))));
        ([`Slist1sep
            ((`Snterm (Gramf.obj (str0 : 'str0 Gramf.t ))), (`Skeyword "|"));
         `Skeyword "as";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid s")],
          ("(xs, (Some s))\n",
            (Gramf.mk_action
               (fun (__fan_2 : Tokenf.t)  _  (xs : 'str0 list) 
                  (_loc : Locf.t)  ->
                  match __fan_2 with
                  | `Lid ({ txt = s;_} : Tokenf.txt) ->
                      ((xs, (Some s)) : 'or_strs )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_2))))))]));
  Gramf.extend_single (str0 : 'str0 Gramf.t )
    (None,
      (None, None,
        [([`Stoken
             (((function | `Str _ -> true | _ -> false)), (4153489, `Any),
               "`Str s")],
           ("s\n",
             (Gramf.mk_action
                (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                   match __fan_0 with
                   | `Str ({ txt = s;_} : Tokenf.txt) -> (s : 'str0 )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))))]));
  Gramf.extend_single (level_str : 'level_str Gramf.t )
    (None,
      (None, None,
        [([`Skeyword "Level";
          `Stoken
            (((function | `Str _ -> true | _ -> false)), (4153489, `Any),
              "`Str s")],
           ("s\n",
             (Gramf.mk_action
                (fun (__fan_1 : Tokenf.t)  _  (_loc : Locf.t)  ->
                   match __fan_1 with
                   | `Str ({ txt = s;_} : Tokenf.txt) -> (s : 'level_str )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_1))))))]));
  Gramf.extend_single (sep_symbol : 'sep_symbol Gramf.t )
    (None,
      (None, None,
        [([`Skeyword "SEP"; `Snterm (Gramf.obj (simple : 'simple Gramf.t ))],
           ("let t::[] = t in t\n",
             (Gramf.mk_action
                (fun (t : 'simple)  _  (_loc : Locf.t)  ->
                   (let t::[] = t in t : 'sep_symbol )))))]));
  Gramf.extend_single (symbol : 'symbol Gramf.t )
    (None,
      (None, None,
        [([`Skeyword "L0";
          `Snterm (Gramf.obj (simple : 'simple Gramf.t ));
          `Sopt (`Snterm (Gramf.obj (sep_symbol : 'sep_symbol Gramf.t )))],
           ("let s::[] = s in\nlet styp = `App (_loc, (`Lid (_loc, \"list\")), (s.styp)) in\nlet text = mk_slist _loc (if l = \"L0\" then false else true) sep s in\n[mk_symbol ~text ~styp ~pattern:None]\n",
             (Gramf.mk_action
                (fun (sep : 'sep_symbol option)  (s : 'simple) 
                   (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                   match __fan_0 with
                   | `Key ({ txt = l;_} : Tokenf.txt) ->
                       (let s::[] = s in
                        let styp =
                          `App (_loc, (`Lid (_loc, "list")), (s.styp)) in
                        let text =
                          mk_slist _loc (if l = "L0" then false else true)
                            sep s in
                        [mk_symbol ~text ~styp ~pattern:None] : 'symbol )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "L1";
         `Snterm (Gramf.obj (simple : 'simple Gramf.t ));
         `Sopt (`Snterm (Gramf.obj (sep_symbol : 'sep_symbol Gramf.t )))],
          ("let s::[] = s in\nlet styp = `App (_loc, (`Lid (_loc, \"list\")), (s.styp)) in\nlet text = mk_slist _loc (if l = \"L0\" then false else true) sep s in\n[mk_symbol ~text ~styp ~pattern:None]\n",
            (Gramf.mk_action
               (fun (sep : 'sep_symbol option)  (s : 'simple) 
                  (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Key ({ txt = l;_} : Tokenf.txt) ->
                      (let s::[] = s in
                       let styp =
                         `App (_loc, (`Lid (_loc, "list")), (s.styp)) in
                       let text =
                         mk_slist _loc (if l = "L0" then false else true) sep
                           s in
                       [mk_symbol ~text ~styp ~pattern:None] : 'symbol )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "OPT"; `Snterm (Gramf.obj (simple : 'simple Gramf.t ))],
          ("let s::[] = s in\nlet styp = `App (_loc, (`Lid (_loc, \"option\")), (s.styp)) in\nlet text = `Sopt (_loc, (s.text)) in [mk_symbol ~text ~styp ~pattern:None]\n",
            (Gramf.mk_action
               (fun (s : 'simple)  _  (_loc : Locf.t)  ->
                  (let s::[] = s in
                   let styp = `App (_loc, (`Lid (_loc, "option")), (s.styp)) in
                   let text = `Sopt (_loc, (s.text)) in
                   [mk_symbol ~text ~styp ~pattern:None] : 'symbol )))));
        ([`Skeyword "TRY"; `Snterm (Gramf.obj (simple : 'simple Gramf.t ))],
          ("let s::[] = s in\nlet v = (_loc, (s.text)) in\nlet text = if p = \"TRY\" then `Stry v else `Speek v in\n[mk_symbol ~text ~styp:(s.styp) ~pattern:None]\n",
            (Gramf.mk_action
               (fun (s : 'simple)  (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Key ({ txt = p;_} : Tokenf.txt) ->
                      (let s::[] = s in
                       let v = (_loc, (s.text)) in
                       let text = if p = "TRY" then `Stry v else `Speek v in
                       [mk_symbol ~text ~styp:(s.styp) ~pattern:None] : 
                      'symbol )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "PEEK"; `Snterm (Gramf.obj (simple : 'simple Gramf.t ))],
          ("let s::[] = s in\nlet v = (_loc, (s.text)) in\nlet text = if p = \"TRY\" then `Stry v else `Speek v in\n[mk_symbol ~text ~styp:(s.styp) ~pattern:None]\n",
            (Gramf.mk_action
               (fun (s : 'simple)  (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Key ({ txt = p;_} : Tokenf.txt) ->
                      (let s::[] = s in
                       let v = (_loc, (s.text)) in
                       let text = if p = "TRY" then `Stry v else `Speek v in
                       [mk_symbol ~text ~styp:(s.styp) ~pattern:None] : 
                      'symbol )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Snterm (Gramf.obj (simple : 'simple Gramf.t ))],
          ("p\n",
            (Gramf.mk_action
               (fun (p : 'simple)  (_loc : Locf.t)  -> (p : 'symbol )))))]));
  Gramf.extend_single (brace_pattern : 'brace_pattern Gramf.t )
    (None,
      (None, None,
        [([`Skeyword "{";
          `Stoken
            (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
              "`Lid i");
          `Skeyword "}"],
           ("`Lid (loc, i)\n",
             (Gramf.mk_action
                (fun _  (__fan_1 : Tokenf.t)  _  (_loc : Locf.t)  ->
                   match __fan_1 with
                   | `Lid ({ loc; txt = i;_} : Tokenf.txt) ->
                       (`Lid (loc, i) : 'brace_pattern )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_1))))))]));
  Gramf.extend_single (psymbol : 'psymbol Gramf.t )
    (None,
      (None, None,
        [([`Snterm (Gramf.obj (symbol : 'symbol Gramf.t ));
          `Sopt
            (`Snterm (Gramf.obj (brace_pattern : 'brace_pattern Gramf.t )))],
           ("List.map\n  (fun (s : Gram_def.symbol)  ->\n     match p with\n     | Some _ -> { s with pattern = (p : pat option ) }\n     | None  -> s) ss\n",
             (Gramf.mk_action
                (fun (p : 'brace_pattern option)  (ss : 'symbol) 
                   (_loc : Locf.t)  ->
                   (List.map
                      (fun (s : Gram_def.symbol)  ->
                         match p with
                         | Some _ -> { s with pattern = (p : pat option ) }
                         | None  -> s) ss : 'psymbol )))))]))
let _ =
  let grammar_entry_create x = Gramf.mk_dynamic g x in
  let str: 'str Gramf.t = grammar_entry_create "str"
  and left_rule: 'left_rule Gramf.t = grammar_entry_create "left_rule"
  and opt_action: 'opt_action Gramf.t = grammar_entry_create "opt_action" in
  Gramf.extend_single (str : 'str Gramf.t )
    (None,
      (None, None,
        [([`Stoken
             (((function | `Str _ -> true | _ -> false)), (4153489, `Any),
               "`Str y")],
           ("y\n",
             (Gramf.mk_action
                (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                   match __fan_0 with
                   | `Str ({ txt = y;_} : Tokenf.txt) -> (y : 'str )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))))]));
  Gramf.extend_single (extend_header : 'extend_header Gramf.t )
    (None,
      (None, None,
        [([`Skeyword "(";
          `Snterm (Gramf.obj (qualid : 'qualid Gramf.t ));
          `Skeyword ":";
          `Snterm (Gramf.obj (t_qualid : 't_qualid Gramf.t ));
          `Skeyword ")"],
           ("let old = gm () in let () = module_name := t in ((Some i), old)\n",
             (Gramf.mk_action
                (fun _  (t : 't_qualid)  _  (i : 'qualid)  _  (_loc : Locf.t)
                    ->
                   (let old = gm () in
                    let () = module_name := t in ((Some i), old) : 'extend_header )))));
        ([`Snterm (Gramf.obj (qualuid : 'qualuid Gramf.t ))],
          ("let old = gm () in let () = module_name := t in (None, old)\n",
            (Gramf.mk_action
               (fun (t : 'qualuid)  (_loc : Locf.t)  ->
                  (let old = gm () in
                   let () = module_name := t in (None, old) : 'extend_header )))));
        ([],
          ("(None, (gm ()))\n",
            (Gramf.mk_action
               (fun (_loc : Locf.t)  -> ((None, (gm ())) : 'extend_header )))))]));
  Gramf.extend_single (extend_body : 'extend_body Gramf.t )
    (None,
      (None, None,
        [([`Snterm (Gramf.obj (extend_header : 'extend_header Gramf.t ));
          `Slist1 (`Snterm (Gramf.obj (entry : 'entry Gramf.t )))],
           ("let (gram,old) = rest in\nlet items = Listf.filter_map (fun x  -> x) el in\nlet res = make _loc { items; gram; safe = true } in\nlet () = module_name := old in res\n",
             (Gramf.mk_action
                (fun (el : 'entry list)  (rest : 'extend_header) 
                   (_loc : Locf.t)  ->
                   (let (gram,old) = rest in
                    let items = Listf.filter_map (fun x  -> x) el in
                    let res = make _loc { items; gram; safe = true } in
                    let () = module_name := old in res : 'extend_body )))))]));
  Gramf.extend_single (unsafe_extend_body : 'unsafe_extend_body Gramf.t )
    (None,
      (None, None,
        [([`Snterm (Gramf.obj (extend_header : 'extend_header Gramf.t ));
          `Slist1 (`Snterm (Gramf.obj (entry : 'entry Gramf.t )))],
           ("let (gram,old) = rest in\nlet items = Listf.filter_map (fun x  -> x) el in\nlet res = make _loc { items; gram; safe = false } in\nlet () = module_name := old in res\n",
             (Gramf.mk_action
                (fun (el : 'entry list)  (rest : 'extend_header) 
                   (_loc : Locf.t)  ->
                   (let (gram,old) = rest in
                    let items = Listf.filter_map (fun x  -> x) el in
                    let res = make _loc { items; gram; safe = false } in
                    let () = module_name := old in res : 'unsafe_extend_body )))))]));
  Gramf.extend_single (qualuid : 'qualuid Gramf.t )
    (None,
      (None, None,
        [([`Stoken
             (((function | `Uid _ -> true | _ -> false)), (4250480, `Any),
               "`Uid x");
          `Skeyword ".";
          `Sself],
           ("`Dot (_loc, (`Uid (_loc, x)), xs)\n",
             (Gramf.mk_action
                (fun (xs : 'qualuid)  _  (__fan_0 : Tokenf.t) 
                   (_loc : Locf.t)  ->
                   match __fan_0 with
                   | `Uid ({ txt = x;_} : Tokenf.txt) ->
                       (`Dot (_loc, (`Uid (_loc, x)), xs) : 'qualuid )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Stoken
            (((function | `Uid _ -> true | _ -> false)), (4250480, `Any),
              "`Uid x")],
          ("`Uid (_loc, x)\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Uid ({ txt = x;_} : Tokenf.txt) ->
                      (`Uid (_loc, x) : 'qualuid )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))))]));
  Gramf.extend_single (qualid : 'qualid Gramf.t )
    (None,
      (None, None,
        [([`Stoken
             (((function | `Uid _ -> true | _ -> false)), (4250480, `Any),
               "`Uid x");
          `Skeyword ".";
          `Sself],
           ("`Dot (_loc, (`Uid (_loc, x)), xs)\n",
             (Gramf.mk_action
                (fun (xs : 'qualid)  _  (__fan_0 : Tokenf.t)  (_loc : Locf.t)
                    ->
                   match __fan_0 with
                   | `Uid ({ txt = x;_} : Tokenf.txt) ->
                       (`Dot (_loc, (`Uid (_loc, x)), xs) : 'qualid )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Stoken
            (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
              "`Lid i")],
          ("`Lid (_loc, i)\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Lid ({ txt = i;_} : Tokenf.txt) ->
                      (`Lid (_loc, i) : 'qualid )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))))]));
  Gramf.extend_single (t_qualid : 't_qualid Gramf.t )
    (None,
      (None, None,
        [([`Stoken
             (((function | `Uid _ -> true | _ -> false)), (4250480, `Any),
               "`Uid x");
          `Skeyword ".";
          `Sself],
           ("`Dot (_loc, (`Uid (_loc, x)), xs)\n",
             (Gramf.mk_action
                (fun (xs : 't_qualid)  _  (__fan_0 : Tokenf.t) 
                   (_loc : Locf.t)  ->
                   match __fan_0 with
                   | `Uid ({ txt = x;_} : Tokenf.txt) ->
                       (`Dot (_loc, (`Uid (_loc, x)), xs) : 't_qualid )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Stoken
            (((function | `Uid _ -> true | _ -> false)), (4250480, `Any),
              "`Uid x");
         `Skeyword ".";
         `Stoken
           (((function
              | `Lid ({ txt = "t";_} : Tokenf.txt) -> true
              | _ -> false)), (3802919, (`A "t")), "`Lid \"t\"")],
          ("`Uid (_loc, x)\n",
            (Gramf.mk_action
               (fun (__fan_2 : Tokenf.t)  _  (__fan_0 : Tokenf.t) 
                  (_loc : Locf.t)  ->
                  match (__fan_2, __fan_0) with
                  | (`Lid ({ txt = "t";_} : Tokenf.txt),`Uid
                                                          ({ txt = x;_} :
                                                            Tokenf.txt))
                      -> (`Uid (_loc, x) : 't_qualid )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s %s" (Tokenf.to_string __fan_2)
                           (Tokenf.to_string __fan_0))))))]));
  Gramf.extend_single (name : 'name Gramf.t )
    (None,
      (None, None,
        [([`Snterm (Gramf.obj (qualid : 'qualid Gramf.t ))],
           ("mk_name _loc il\n",
             (Gramf.mk_action
                (fun (il : 'qualid)  (_loc : Locf.t)  ->
                   (mk_name _loc il : 'name )))))]));
  Gramf.extend_single (entry_name : 'entry_name Gramf.t )
    (None,
      (None, None,
        [([`Snterm (Gramf.obj (qualid : 'qualid Gramf.t ));
          `Sopt (`Snterm (Gramf.obj (str : 'str Gramf.t )))],
           ("let x =\n  match name with\n  | Some x ->\n      let old = Ast_quotation.default.contents in\n      (match Ast_quotation.resolve_name ((`Sub []), x) with\n       | None  -> Locf.failf _loc \"DDSL `%s' not resolved\" x\n       | Some x -> (Ast_quotation.default := (Some x); `name old))\n  | None  -> `non in\n(x, (mk_name _loc il))\n",
             (Gramf.mk_action
                (fun (name : 'str option)  (il : 'qualid)  (_loc : Locf.t) 
                   ->
                   (let x =
                      match name with
                      | Some x ->
                          let old = Ast_quotation.default.contents in
                          (match Ast_quotation.resolve_name ((`Sub []), x)
                           with
                           | None  ->
                               Locf.failf _loc "DDSL `%s' not resolved" x
                           | Some x ->
                               (Ast_quotation.default := (Some x); `name old))
                      | None  -> `non in
                    (x, (mk_name _loc il)) : 'entry_name )))))]));
  Gramf.extend_single (entry : 'entry Gramf.t )
    (None,
      (None, None,
        [([`Snterm (Gramf.obj (entry_name : 'entry_name Gramf.t ));
          `Skeyword ":";
          `Sopt (`Snterm (Gramf.obj (position : 'position Gramf.t )));
          `Snterm (Gramf.obj (level_list : 'level_list Gramf.t ))],
           ("let (n,p) = rest in\n(match n with | `name old -> Ast_quotation.default := old | _ -> ());\n(match (pos, levels) with\n | (Some (`App (_loc,`Vrn (_,\"Level\"),_) : FAst.exp),`Group _) ->\n     failwithf \"For Group levels the position can not be applied to Level\"\n | _ -> Some (mk_entry ~local:false ~name:p ~pos ~levels))\n",
             (Gramf.mk_action
                (fun (levels : 'level_list)  (pos : 'position option)  _ 
                   (rest : 'entry_name)  (_loc : Locf.t)  ->
                   (let (n,p) = rest in
                    (match n with
                     | `name old -> Ast_quotation.default := old
                     | _ -> ());
                    (match (pos, levels) with
                     | (Some
                        (`App (_loc,`Vrn (_,"Level"),_) : FAst.exp),`Group _)
                         ->
                         failwithf
                           "For Group levels the position can not be applied to Level"
                     | _ -> Some (mk_entry ~local:false ~name:p ~pos ~levels)) : 
                   'entry )))));
        ([`Skeyword "let";
         `Snterm (Gramf.obj (entry_name : 'entry_name Gramf.t ));
         `Skeyword ":";
         `Sopt (`Snterm (Gramf.obj (position : 'position Gramf.t )));
         `Snterm (Gramf.obj (level_list : 'level_list Gramf.t ))],
          ("let (n,p) = rest in\n(match n with | `name old -> Ast_quotation.default := old | _ -> ());\n(match (pos, levels) with\n | (Some (`App (_loc,`Vrn (_,\"Level\"),_) : FAst.exp),`Group _) ->\n     failwithf \"For Group levels the position can not be applied to Level\"\n | _ -> Some (mk_entry ~local:true ~name:p ~pos ~levels))\n",
            (Gramf.mk_action
               (fun (levels : 'level_list)  (pos : 'position option)  _ 
                  (rest : 'entry_name)  _  (_loc : Locf.t)  ->
                  (let (n,p) = rest in
                   (match n with
                    | `name old -> Ast_quotation.default := old
                    | _ -> ());
                   (match (pos, levels) with
                    | (Some
                       (`App (_loc,`Vrn (_,"Level"),_) : FAst.exp),`Group _)
                        ->
                        failwithf
                          "For Group levels the position can not be applied to Level"
                    | _ -> Some (mk_entry ~local:true ~name:p ~pos ~levels)) : 
                  'entry )))));
        ([`Skeyword "Inline";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x");
         `Skeyword ":";
         `Snterm (Gramf.obj (rule_list : 'rule_list Gramf.t ))],
          ("Hashtbl.add inline_rules x rules; None\n",
            (Gramf.mk_action
               (fun (rules : 'rule_list)  _  (__fan_1 : Tokenf.t)  _ 
                  (_loc : Locf.t)  ->
                  match __fan_1 with
                  | `Lid ({ txt = x;_} : Tokenf.txt) ->
                      ((Hashtbl.add inline_rules x rules; None) : 'entry )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_1))))))]));
  Gramf.extend_single (position : 'position Gramf.t )
    (None,
      (None, None,
        [([`Skeyword "First"],
           ("(`Vrn (_loc, x) : FAst.exp )\n",
             (Gramf.mk_action
                (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                   match __fan_0 with
                   | `Key ({ txt = x;_} : Tokenf.txt) ->
                       ((`Vrn (_loc, x) : FAst.exp ) : 'position )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Last"],
          ("(`Vrn (_loc, x) : FAst.exp )\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Key ({ txt = x;_} : Tokenf.txt) ->
                      ((`Vrn (_loc, x) : FAst.exp ) : 'position )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Before"],
          ("(`Vrn (_loc, x) : FAst.exp )\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Key ({ txt = x;_} : Tokenf.txt) ->
                      ((`Vrn (_loc, x) : FAst.exp ) : 'position )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "After"],
          ("(`Vrn (_loc, x) : FAst.exp )\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Key ({ txt = x;_} : Tokenf.txt) ->
                      ((`Vrn (_loc, x) : FAst.exp ) : 'position )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "Level"],
          ("(`Vrn (_loc, x) : FAst.exp )\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Key ({ txt = x;_} : Tokenf.txt) ->
                      ((`Vrn (_loc, x) : FAst.exp ) : 'position )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))))]));
  Gramf.extend_single (level_list : 'level_list Gramf.t )
    (None,
      (None, None,
        [([`Skeyword "{";
          `Slist1 (`Snterm (Gramf.obj (level : 'level Gramf.t )));
          `Skeyword "}"],
           ("`Group ll\n",
             (Gramf.mk_action
                (fun _  (ll : 'level list)  _  (_loc : Locf.t)  ->
                   (`Group ll : 'level_list )))));
        ([`Snterm (Gramf.obj (level : 'level Gramf.t ))],
          ("`Single l\n",
            (Gramf.mk_action
               (fun (l : 'level)  (_loc : Locf.t)  ->
                  (`Single l : 'level_list )))))]));
  Gramf.extend_single (level : 'level Gramf.t )
    (None,
      (None, None,
        [([`Sopt (`Snterm (Gramf.obj (str : 'str Gramf.t )));
          `Sopt (`Snterm (Gramf.obj (assoc : 'assoc Gramf.t )));
          `Snterm (Gramf.obj (rule_list : 'rule_list Gramf.t ))],
           ("mk_level ~label ~assoc ~rules\n",
             (Gramf.mk_action
                (fun (rules : 'rule_list)  (assoc : 'assoc option) 
                   (label : 'str option)  (_loc : Locf.t)  ->
                   (mk_level ~label ~assoc ~rules : 'level )))))]));
  Gramf.extend_single (assoc : 'assoc Gramf.t )
    (None,
      (None, None,
        [([`Skeyword "LA"],
           ("(`Vrn (_loc, x) : FAst.exp )\n",
             (Gramf.mk_action
                (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                   match __fan_0 with
                   | `Key ({ txt = x;_} : Tokenf.txt) ->
                       ((`Vrn (_loc, x) : FAst.exp ) : 'assoc )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "RA"],
          ("(`Vrn (_loc, x) : FAst.exp )\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Key ({ txt = x;_} : Tokenf.txt) ->
                      ((`Vrn (_loc, x) : FAst.exp ) : 'assoc )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Skeyword "NA"],
          ("(`Vrn (_loc, x) : FAst.exp )\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Key ({ txt = x;_} : Tokenf.txt) ->
                      ((`Vrn (_loc, x) : FAst.exp ) : 'assoc )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))))]));
  Gramf.extend_single (rule_list : 'rule_list Gramf.t )
    (None,
      (None, None,
        [([`Skeyword "["; `Skeyword "]"],
           ("[]\n",
             (Gramf.mk_action
                (fun _  _  (_loc : Locf.t)  -> ([] : 'rule_list )))));
        ([`Skeyword "[";
         `Slist1sep
           ((`Snterm (Gramf.obj (rule : 'rule Gramf.t ))), (`Skeyword "|"));
         `Skeyword "]"],
          ("Listf.concat ruless\n",
            (Gramf.mk_action
               (fun _  (ruless : 'rule list)  _  (_loc : Locf.t)  ->
                  (Listf.concat ruless : 'rule_list )))))]));
  Gramf.extend_single (rule : 'rule Gramf.t )
    (None,
      (None, None,
        [([`Snterm (Gramf.obj (left_rule : 'left_rule Gramf.t ));
          `Sopt (`Snterm (Gramf.obj (opt_action : 'opt_action Gramf.t )))],
           ("let prods = Listf.cross prod in\nList.map (fun prod  -> mk_rule ~prod ~action) prods\n",
             (Gramf.mk_action
                (fun (action : 'opt_action option)  (prod : 'left_rule) 
                   (_loc : Locf.t)  ->
                   (let prods = Listf.cross prod in
                    List.map (fun prod  -> mk_rule ~prod ~action) prods : 
                   'rule )))));
        ([`Skeyword "@";
         `Stoken
           (((function | `Lid _ -> true | _ -> false)), (3802919, `Any),
             "`Lid x")],
          ("match query_inline x with\n| Some x -> x\n| None  -> Locf.failf _loc \"inline rules %s not found\" x\n",
            (Gramf.mk_action
               (fun (__fan_1 : Tokenf.t)  _  (_loc : Locf.t)  ->
                  match __fan_1 with
                  | `Lid ({ txt = x;_} : Tokenf.txt) ->
                      ((match query_inline x with
                        | Some x -> x
                        | None  ->
                            Locf.failf _loc "inline rules %s not found" x) : 
                      'rule )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_1))))))]));
  Gramf.extend_single (left_rule : 'left_rule Gramf.t )
    (None,
      (None, None,
        [([`Snterm (Gramf.obj (psymbol : 'psymbol Gramf.t ))],
           ("[x]\n",
             (Gramf.mk_action
                (fun (x : 'psymbol)  (_loc : Locf.t)  -> ([x] : 'left_rule )))));
        ([`Snterm (Gramf.obj (psymbol : 'psymbol Gramf.t ));
         `Skeyword ";";
         `Sself],
          ("x :: xs\n",
            (Gramf.mk_action
               (fun (xs : 'left_rule)  _  (x : 'psymbol)  (_loc : Locf.t)  ->
                  (x :: xs : 'left_rule )))));
        ([],
          ("[]\n",
            (Gramf.mk_action (fun (_loc : Locf.t)  -> ([] : 'left_rule )))))]));
  Gramf.extend_single (opt_action : 'opt_action Gramf.t )
    (None,
      (None, None,
        [([`Stoken
             (((function | `Quot _ -> true | _ -> false)), (904098089, `Any),
               "`Quot _")],
           ("if x.name = Tokenf.empty_name\nthen\n  let expander loc _ s = Gramf.parse_string ~loc Syntaxf.exp s in\n  Tokenf.quot_expand expander x\nelse Ast_quotation.expand x Dyn_tag.exp\n",
             (Gramf.mk_action
                (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                   match __fan_0 with
                   | `Quot x ->
                       (if x.name = Tokenf.empty_name
                        then
                          let expander loc _ s =
                            Gramf.parse_string ~loc Syntaxf.exp s in
                          Tokenf.quot_expand expander x
                        else Ast_quotation.expand x Dyn_tag.exp : 'opt_action )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))))]));
  Gramf.extend_single (string : 'string Gramf.t )
    (None,
      (None, None,
        [([`Stoken
             (((function | `Str _ -> true | _ -> false)), (4153489, `Any),
               "`Str s")],
           ("(`Str (_loc, s) : FAst.exp )\n",
             (Gramf.mk_action
                (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                   match __fan_0 with
                   | `Str ({ txt = s;_} : Tokenf.txt) ->
                       ((`Str (_loc, s) : FAst.exp ) : 'string )
                   | _ ->
                       failwith
                         (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))));
        ([`Stoken
            (((function
               | `Ant ({ kind = "";_} : Tokenf.ant) -> true
               | _ -> false)), (3257031, (`A "")), "`Ant s")],
          ("Parsef.exp s.loc s.txt\n",
            (Gramf.mk_action
               (fun (__fan_0 : Tokenf.t)  (_loc : Locf.t)  ->
                  match __fan_0 with
                  | `Ant (({ kind = "";_} as s) : Tokenf.ant) ->
                      (Parsef.exp s.loc s.txt : 'string )
                  | _ ->
                      failwith
                        (Printf.sprintf "%s" (Tokenf.to_string __fan_0))))))]))
let _ =
  let d = Ns.lang in
  Ast_quotation.of_exp ~name:(d, "extend") ~entry:extend_body ();
  Ast_quotation.of_exp ~name:(d, "unsafe_extend") ~entry:unsafe_extend_body
    ()