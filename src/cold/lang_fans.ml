let rec token: Lexing.lexbuf -> Tokenf.t =
  fun (lexbuf : Lexing.lexbuf)  ->
    let rec __ocaml_lex_init_lexbuf (lexbuf : Lexing.lexbuf) mem_size =
      let pos = lexbuf.Lexing.lex_curr_pos in
      lexbuf.lex_mem <- Array.create mem_size (-1);
      lexbuf.lex_start_pos <- pos;
      lexbuf.lex_last_pos <- pos;
      lexbuf.lex_last_action <- (-1)
    and __ocaml_lex_next_char (lexbuf : Lexing.lexbuf) =
      if lexbuf.lex_curr_pos >= lexbuf.lex_buffer_len
      then
        (if lexbuf.lex_eof_reached
         then 256
         else (lexbuf.refill_buff lexbuf; __ocaml_lex_next_char lexbuf))
      else
        (let i = lexbuf.lex_curr_pos in
         let c = (lexbuf.lex_buffer).[i] in
         lexbuf.lex_curr_pos <- i + 1; Char.code c)
    and __ocaml_lex_state0 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
      | 40 -> __ocaml_lex_state6 lexbuf
      | 41|44|59 -> __ocaml_lex_state3 lexbuf
      | 9|12|32 -> __ocaml_lex_state9 lexbuf
      | 65
        |66
         |67
          |68
           |69
            |70
             |71
              |72
               |73
                |74
                 |75
                  |76
                   |77
                    |78
                     |79
                      |80
                       |81
                        |82
                         |83
                          |84
                           |85
                            |86
                             |87
                              |88
                               |89
                                |90
                                 |192
                                  |193
                                   |194
                                    |195
                                     |196
                                      |197
                                       |198
                                        |199
                                         |200
                                          |201
                                           |202
                                            |203
                                             |204
                                              |205
                                               |206
                                                |207
                                                 |208
                                                  |209
                                                   |210
                                                    |211
                                                     |212
                                                      |213
                                                       |214
                                                        |216
                                                         |217
                                                          |218
                                                           |219|220|221|222
          -> __ocaml_lex_state4 lexbuf
      | 10 -> __ocaml_lex_state8 lexbuf
      | 95
        |97
         |98
          |99
           |100
            |101
             |102
              |103
               |104
                |105
                 |106
                  |107
                   |108
                    |109
                     |110
                      |111
                       |112
                        |113
                         |114
                          |115
                           |116
                            |117
                             |118
                              |119
                               |120
                                |121
                                 |122
                                  |223
                                   |224
                                    |225
                                     |226
                                      |227
                                       |228
                                        |229
                                         |230
                                          |231
                                           |232
                                            |233
                                             |234
                                              |235
                                               |236
                                                |237
                                                 |238
                                                  |239
                                                   |240
                                                    |241
                                                     |242
                                                      |243
                                                       |244
                                                        |245
                                                         |246
                                                          |248
                                                           |249
                                                            |250
                                                             |251
                                                              |252
                                                               |253|254|255
          -> __ocaml_lex_state5 lexbuf
      | 13 -> __ocaml_lex_state7 lexbuf
      | 256 -> __ocaml_lex_state2 lexbuf
      | _ -> __ocaml_lex_state1 lexbuf
    and __ocaml_lex_state1 (lexbuf : Lexing.lexbuf) = 7
    and __ocaml_lex_state2 (lexbuf : Lexing.lexbuf) = 6
    and __ocaml_lex_state3 (lexbuf : Lexing.lexbuf) = 5
    and __ocaml_lex_state4 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 4;
      (match __ocaml_lex_next_char lexbuf with
       | 39
         |48
          |49
           |50
            |51
             |52
              |53
               |54
                |55
                 |56
                  |57
                   |65
                    |66
                     |67
                      |68
                       |69
                        |70
                         |71
                          |72
                           |73
                            |74
                             |75
                              |76
                               |77
                                |78
                                 |79
                                  |80
                                   |81
                                    |82
                                     |83
                                      |84
                                       |85
                                        |86
                                         |87
                                          |88
                                           |89
                                            |90
                                             |95
                                              |97
                                               |98
                                                |99
                                                 |100
                                                  |101
                                                   |102
                                                    |103
                                                     |104
                                                      |105
                                                       |106
                                                        |107
                                                         |108
                                                          |109
                                                           |110
                                                            |111
                                                             |112
                                                              |113
                                                               |114
                                                                |115
                                                                 |116
                                                                  |117
                                                                   |118
                                                                    |
                                                                    119
                                                                    |
                                                                    120
                                                                    |
                                                                    121
                                                                    |
                                                                    122
                                                                    |
                                                                    192
                                                                    |
                                                                    193
                                                                    |
                                                                    194
                                                                    |
                                                                    195
                                                                    |
                                                                    196
                                                                    |
                                                                    197
                                                                    |
                                                                    198
                                                                    |
                                                                    199
                                                                    |
                                                                    200
                                                                    |
                                                                    201
                                                                    |
                                                                    202
                                                                    |
                                                                    203
                                                                    |
                                                                    204
                                                                    |
                                                                    205
                                                                    |
                                                                    206
                                                                    |
                                                                    207
                                                                    |
                                                                    208
                                                                    |
                                                                    209
                                                                    |
                                                                    210
                                                                    |
                                                                    211
                                                                    |
                                                                    212
                                                                    |
                                                                    213
                                                                    |
                                                                    214
                                                                    |
                                                                    216
                                                                    |
                                                                    217
                                                                    |
                                                                    218
                                                                    |
                                                                    219
                                                                    |
                                                                    220
                                                                    |
                                                                    221
                                                                    |
                                                                    222
                                                                    |
                                                                    223
                                                                    |
                                                                    224
                                                                    |
                                                                    225
                                                                    |
                                                                    226
                                                                    |
                                                                    227
                                                                    |
                                                                    228
                                                                    |
                                                                    229
                                                                    |
                                                                    230
                                                                    |
                                                                    231
                                                                    |
                                                                    232
                                                                    |
                                                                    233
                                                                    |
                                                                    234
                                                                    |
                                                                    235
                                                                    |
                                                                    236
                                                                    |
                                                                    237
                                                                    |
                                                                    238
                                                                    |
                                                                    239
                                                                    |
                                                                    240
                                                                    |
                                                                    241
                                                                    |
                                                                    242
                                                                    |
                                                                    243
                                                                    |
                                                                    244
                                                                    |
                                                                    245
                                                                    |
                                                                    246
                                                                    |
                                                                    248
                                                                    |
                                                                    249
                                                                    |
                                                                    250
                                                                    |
                                                                    251
                                                                    |
                                                                    252
                                                                    |
                                                                    253
                                                                    |
                                                                    254|255
           -> __ocaml_lex_state4 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state5 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 3;
      (match __ocaml_lex_next_char lexbuf with
       | 39
         |48
          |49
           |50
            |51
             |52
              |53
               |54
                |55
                 |56
                  |57
                   |65
                    |66
                     |67
                      |68
                       |69
                        |70
                         |71
                          |72
                           |73
                            |74
                             |75
                              |76
                               |77
                                |78
                                 |79
                                  |80
                                   |81
                                    |82
                                     |83
                                      |84
                                       |85
                                        |86
                                         |87
                                          |88
                                           |89
                                            |90
                                             |95
                                              |97
                                               |98
                                                |99
                                                 |100
                                                  |101
                                                   |102
                                                    |103
                                                     |104
                                                      |105
                                                       |106
                                                        |107
                                                         |108
                                                          |109
                                                           |110
                                                            |111
                                                             |112
                                                              |113
                                                               |114
                                                                |115
                                                                 |116
                                                                  |117
                                                                   |118
                                                                    |
                                                                    119
                                                                    |
                                                                    120
                                                                    |
                                                                    121
                                                                    |
                                                                    122
                                                                    |
                                                                    192
                                                                    |
                                                                    193
                                                                    |
                                                                    194
                                                                    |
                                                                    195
                                                                    |
                                                                    196
                                                                    |
                                                                    197
                                                                    |
                                                                    198
                                                                    |
                                                                    199
                                                                    |
                                                                    200
                                                                    |
                                                                    201
                                                                    |
                                                                    202
                                                                    |
                                                                    203
                                                                    |
                                                                    204
                                                                    |
                                                                    205
                                                                    |
                                                                    206
                                                                    |
                                                                    207
                                                                    |
                                                                    208
                                                                    |
                                                                    209
                                                                    |
                                                                    210
                                                                    |
                                                                    211
                                                                    |
                                                                    212
                                                                    |
                                                                    213
                                                                    |
                                                                    214
                                                                    |
                                                                    216
                                                                    |
                                                                    217
                                                                    |
                                                                    218
                                                                    |
                                                                    219
                                                                    |
                                                                    220
                                                                    |
                                                                    221
                                                                    |
                                                                    222
                                                                    |
                                                                    223
                                                                    |
                                                                    224
                                                                    |
                                                                    225
                                                                    |
                                                                    226
                                                                    |
                                                                    227
                                                                    |
                                                                    228
                                                                    |
                                                                    229
                                                                    |
                                                                    230
                                                                    |
                                                                    231
                                                                    |
                                                                    232
                                                                    |
                                                                    233
                                                                    |
                                                                    234
                                                                    |
                                                                    235
                                                                    |
                                                                    236
                                                                    |
                                                                    237
                                                                    |
                                                                    238
                                                                    |
                                                                    239
                                                                    |
                                                                    240
                                                                    |
                                                                    241
                                                                    |
                                                                    242
                                                                    |
                                                                    243
                                                                    |
                                                                    244
                                                                    |
                                                                    245
                                                                    |
                                                                    246
                                                                    |
                                                                    248
                                                                    |
                                                                    249
                                                                    |
                                                                    250
                                                                    |
                                                                    251
                                                                    |
                                                                    252
                                                                    |
                                                                    253
                                                                    |
                                                                    254|255
           -> __ocaml_lex_state5 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state6 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 5;
      (match __ocaml_lex_next_char lexbuf with
       | 42 ->
           ((lexbuf.Lexing.lex_mem).(1) <- lexbuf.Lexing.lex_curr_pos;
            __ocaml_lex_state10 lexbuf)
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state7 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 1;
      (match __ocaml_lex_next_char lexbuf with
       | 10 -> __ocaml_lex_state8 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state8 (lexbuf : Lexing.lexbuf) = 1
    and __ocaml_lex_state9 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 0;
      (match __ocaml_lex_next_char lexbuf with
       | 9|12|32 -> __ocaml_lex_state9 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state10 (lexbuf : Lexing.lexbuf) =
      (lexbuf.Lexing.lex_mem).(0) <- (-1);
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 2;
      (match __ocaml_lex_next_char lexbuf with
       | 41 -> __ocaml_lex_state11 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state11 (lexbuf : Lexing.lexbuf) =
      (lexbuf.Lexing.lex_mem).(0) <- (lexbuf.Lexing.lex_mem).(1); 2 in
    __ocaml_lex_init_lexbuf lexbuf 2;
    (let __ocaml_lex_result = __ocaml_lex_state0 lexbuf in
     lexbuf.lex_start_p <- lexbuf.lex_curr_p;
     lexbuf.lex_curr_p <-
       {
         (lexbuf.lex_curr_p) with
         pos_cnum = (lexbuf.lex_abs_pos + lexbuf.lex_curr_pos)
       };
     (match __ocaml_lex_result with
      | 0 -> ((); token lexbuf)
      | 1 -> (Lexing_util.update_loc lexbuf; token lexbuf)
      | 2 ->
          let x =
            Lexing.sub_lexeme_char_opt lexbuf
              (((lexbuf.Lexing.lex_mem).(0)) + 0) in
          ((let c = Lexing_util.new_cxt () in
            if x <> None
            then
              Lexing_util.warn Comment_start (Lexing_util.from_lexbuf lexbuf);
            Lexing_util.store c lexbuf;
            Lexing_util.push_loc_cont c lexbuf Lexing_util.lex_comment;
            ignore (Lexing_util.buff_contents c));
           token lexbuf)
      | 3 ->
          let txt =
            Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 0)
              (lexbuf.Lexing.lex_curr_pos + 0) in
          let v = Hashtbl.hash txt in
          if
            ((function
              | 669538498 -> txt = "derive"
              | 769889260 -> txt = "unload"
              | 112559905 -> txt = "clear"
              | 728165346 -> txt = "keep"
              | 788757552 -> txt = "on"
              | 189838782 -> txt = "off"
              | 535818803 -> txt = "show_code"
              | _ -> false)) v
          then
            `Key
              {
                loc =
                  {
                    loc_start = (lexbuf.lex_start_p);
                    loc_end = (lexbuf.lex_curr_p);
                    loc_ghost = false
                  };
                txt
              }
          else
            `Lid
              {
                loc =
                  {
                    loc_start = (lexbuf.lex_start_p);
                    loc_end = (lexbuf.lex_curr_p);
                    loc_ghost = false
                  };
                txt
              }
      | 4 ->
          let txt =
            Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 0)
              (lexbuf.Lexing.lex_curr_pos + 0) in
          `Uid
            {
              loc =
                {
                  loc_start = (lexbuf.lex_start_p);
                  loc_end = (lexbuf.lex_curr_p);
                  loc_ghost = false
                };
              txt
            }
      | 5 ->
          let txt =
            Lexing.sub_lexeme lexbuf lexbuf.lex_start_pos lexbuf.lex_curr_pos in
          (`Key
             {
               loc =
                 {
                   loc_start = (lexbuf.lex_start_p);
                   loc_end = (lexbuf.lex_curr_p);
                   loc_ghost = false
                 };
               txt
             } : Tokenf.t )
      | 6 ->
          let pos = lexbuf.lex_curr_p in
          (lexbuf.lex_curr_p <-
             {
               pos with
               pos_bol = (pos.pos_bol + 1);
               pos_cnum = (pos.pos_cnum + 1)
             };
           (let loc = Lexing_util.from_lexbuf lexbuf in
            (`EOI { loc; txt = "" } : Tokenf.t )))
      | 7 ->
          let c =
            Lexing.sub_lexeme_char lexbuf (lexbuf.Lexing.lex_start_pos + 0) in
          (Lexing_util.err (Illegal_character c)) @@
            (Lexing_util.from_lexbuf lexbuf)
      | _ -> failwith "lexing: empty token"))
let fan_quot = Gramf.mk "fan_quot"
let fan_quots = Gramf.mk "fan_quots"
let _ =
  let grammar_entry_create x = Gramf.mk x in
  let id: 'id Gramf.t = grammar_entry_create "id"
  and fan_quot_semi: 'fan_quot_semi Gramf.t =
    grammar_entry_create "fan_quot_semi" in
  Gramf.extend_single (fan_quot : 'fan_quot Gramf.t )
    ({
       label = None;
       lassoc = true;
       productions =
         [{
            symbols =
              [Token
                 ({
                    descr =
                      { tag = `Key; word = (A "derive"); tag_name = "Key" }
                  } : Tokenf.pattern );
              Token
                ({ descr = { tag = `Key; word = (A "("); tag_name = "Key" } } : 
                Tokenf.pattern );
              List1 (Nterm (Gramf.obj (id : 'id Gramf.t )));
              Token
                ({ descr = { tag = `Key; word = (A ")"); tag_name = "Key" } } : 
                Tokenf.pattern )];
            annot = "List.iter Typehook.plugin_add plugins\n";
            fn =
              (Gramf.mk_action
                 (fun _  (plugins : 'id list)  _  _  (_loc : Locf.t)  ->
                    (List.iter Typehook.plugin_add plugins : 'fan_quot ) : 
                 Tokenf.txt ->
                   'id list ->
                     Tokenf.txt -> Tokenf.txt -> Locf.t -> 'fan_quot ))
          };
         {
           symbols =
             [Token
                ({
                   descr =
                     { tag = `Key; word = (A "unload"); tag_name = "Key" }
                 } : Tokenf.pattern );
             List1sep
               ((Nterm (Gramf.obj (id : 'id Gramf.t ))),
                 (Token
                    ({
                       descr =
                         { tag = `Key; word = (A ","); tag_name = "Key" }
                     } : Tokenf.pattern )))];
           annot = "List.iter Typehook.plugin_remove plugins\n";
           fn =
             (Gramf.mk_action
                (fun (plugins : 'id list)  _  (_loc : Locf.t)  ->
                   (List.iter Typehook.plugin_remove plugins : 'fan_quot ) : 
                'id list -> Tokenf.txt -> Locf.t -> 'fan_quot ))
         };
         {
           symbols =
             [Token
                ({
                   descr =
                     { tag = `Key; word = (A "clear"); tag_name = "Key" }
                 } : Tokenf.pattern )];
           annot = "State.reset_current_filters ()\n";
           fn =
             (Gramf.mk_action
                (fun _  (_loc : Locf.t)  ->
                   (State.reset_current_filters () : 'fan_quot ) : Tokenf.txt
                                                                    ->
                                                                    Locf.t ->
                                                                    'fan_quot ))
         };
         {
           symbols =
             [Token
                ({
                   descr =
                     { tag = `Key; word = (A "keep"); tag_name = "Key" }
                 } : Tokenf.pattern );
             Token
               ({ descr = { tag = `Key; word = (A "on"); tag_name = "Key" } } : 
               Tokenf.pattern )];
           annot = "State.keep := true\n";
           fn =
             (Gramf.mk_action
                (fun _  _  (_loc : Locf.t)  ->
                   (State.keep := true : 'fan_quot ) : Tokenf.txt ->
                                                         Tokenf.txt ->
                                                           Locf.t ->
                                                             'fan_quot ))
         };
         {
           symbols =
             [Token
                ({
                   descr =
                     { tag = `Key; word = (A "keep"); tag_name = "Key" }
                 } : Tokenf.pattern );
             Token
               ({ descr = { tag = `Key; word = (A "off"); tag_name = "Key" }
                } : Tokenf.pattern )];
           annot = "State.keep := false\n";
           fn =
             (Gramf.mk_action
                (fun _  _  (_loc : Locf.t)  ->
                   (State.keep := false : 'fan_quot ) : Tokenf.txt ->
                                                          Tokenf.txt ->
                                                            Locf.t ->
                                                              'fan_quot ))
         };
         {
           symbols =
             [Token
                ({
                   descr =
                     { tag = `Key; word = (A "show_code"); tag_name = "Key" }
                 } : Tokenf.pattern );
             Token
               ({ descr = { tag = `Key; word = (A "on"); tag_name = "Key" } } : 
               Tokenf.pattern )];
           annot = "Typehook.show_code := true\n";
           fn =
             (Gramf.mk_action
                (fun _  _  (_loc : Locf.t)  ->
                   (Typehook.show_code := true : 'fan_quot ) : Tokenf.txt ->
                                                                 Tokenf.txt
                                                                   ->
                                                                   Locf.t ->
                                                                    'fan_quot ))
         };
         {
           symbols =
             [Token
                ({
                   descr =
                     { tag = `Key; word = (A "show_code"); tag_name = "Key" }
                 } : Tokenf.pattern );
             Token
               ({ descr = { tag = `Key; word = (A "off"); tag_name = "Key" }
                } : Tokenf.pattern )];
           annot = "Typehook.show_code := false\n";
           fn =
             (Gramf.mk_action
                (fun _  _  (_loc : Locf.t)  ->
                   (Typehook.show_code := false : 'fan_quot ) : Tokenf.txt ->
                                                                  Tokenf.txt
                                                                    ->
                                                                    Locf.t ->
                                                                    'fan_quot ))
         }]
     } : Gramf.olevel );
  Gramf.extend_single (id : 'id Gramf.t )
    ({
       label = None;
       lassoc = true;
       productions =
         [{
            symbols =
              [Token
                 ({ descr = { tag = `Lid; word = Any; tag_name = "Lid" } } : 
                 Tokenf.pattern )];
            annot = "x\n";
            fn =
              (Gramf.mk_action
                 (fun (__fan_0 : Tokenf.txt)  (_loc : Locf.t)  ->
                    let x = __fan_0.txt in (x : 'id ) : Tokenf.txt ->
                                                          Locf.t -> 'id ))
          };
         {
           symbols =
             [Token
                ({ descr = { tag = `Uid; word = Any; tag_name = "Uid" } } : 
                Tokenf.pattern )];
           annot = "x\n";
           fn =
             (Gramf.mk_action
                (fun (__fan_0 : Tokenf.txt)  (_loc : Locf.t)  ->
                   let x = __fan_0.txt in (x : 'id ) : Tokenf.txt ->
                                                         Locf.t -> 'id ))
         }]
     } : Gramf.olevel );
  Gramf.extend_single (fan_quot_semi : 'fan_quot_semi Gramf.t )
    ({
       label = None;
       lassoc = true;
       productions =
         [{
            symbols =
              [Nterm (Gramf.obj (fan_quot : 'fan_quot Gramf.t ));
              Token
                ({ descr = { tag = `Key; word = (A ";"); tag_name = "Key" } } : 
                Tokenf.pattern )];
            annot = "";
            fn =
              (Gramf.mk_action
                 (fun _  _  (_loc : Locf.t)  -> (() : 'fan_quot_semi ) : 
                 Tokenf.txt -> 'fan_quot -> Locf.t -> 'fan_quot_semi ))
          }]
     } : Gramf.olevel );
  Gramf.extend_single (fan_quots : 'fan_quots Gramf.t )
    ({
       label = None;
       lassoc = true;
       productions =
         [{
            symbols =
              [List1
                 (Nterm (Gramf.obj (fan_quot_semi : 'fan_quot_semi Gramf.t )))];
            annot = "(`Uid (_loc, \"()\") : FAst.exp )\n";
            fn =
              (Gramf.mk_action
                 (fun _  (_loc : Locf.t)  ->
                    ((`Uid (_loc, "()") : FAst.exp ) : 'fan_quots ) : 
                 'fan_quot_semi list -> Locf.t -> 'fan_quots ))
          }]
     } : Gramf.olevel )
let lexer = Lexing_util.adapt_to_stream token
let _ =
  Foptions.add
    ("-keep", (Arg.Set State.keep), "Keep the included type definitions");
  Foptions.add
    ("-loaded-plugins", (Arg.Unit Typehook.show_modules), "Show plugins");
  Ast_quotation.of_exp ~name:(Ns.lang, "fans") ~lexer ~entry:fan_quots ()
