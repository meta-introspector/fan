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
      | 37 ->
          ((lexbuf.Lexing.lex_mem).(4) <- lexbuf.Lexing.lex_curr_pos;
           __ocaml_lex_state3 lexbuf)
      | 45 -> __ocaml_lex_state6 lexbuf
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
          -> __ocaml_lex_state13 lexbuf
      | 34 -> __ocaml_lex_state11 lexbuf
      | 49|50|51|52|53|54|55|56|57 -> __ocaml_lex_state9 lexbuf
      | 35|41|42|43|44|46|58|59|60|61|63|64|91|93|94|123|124|125 ->
          __ocaml_lex_state4 lexbuf
      | 10 -> __ocaml_lex_state15 lexbuf
      | 39 -> __ocaml_lex_state8 lexbuf
      | 40 -> __ocaml_lex_state5 lexbuf
      | 36 ->
          ((lexbuf.Lexing.lex_mem).(5) <- lexbuf.Lexing.lex_curr_pos;
           __ocaml_lex_state7 lexbuf)
      | 9|12|32 -> __ocaml_lex_state16 lexbuf
      | 48 -> __ocaml_lex_state10 lexbuf
      | 13 -> __ocaml_lex_state14 lexbuf
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
          -> __ocaml_lex_state12 lexbuf
      | 256 -> __ocaml_lex_state2 lexbuf
      | _ -> __ocaml_lex_state1 lexbuf
    and __ocaml_lex_state1 (lexbuf : Lexing.lexbuf) = 16
    and __ocaml_lex_state2 (lexbuf : Lexing.lexbuf) = 15
    and __ocaml_lex_state3 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 16;
      (match __ocaml_lex_next_char lexbuf with
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
           -> __ocaml_lex_state46 lexbuf
       | 64 ->
           ((lexbuf.Lexing.lex_mem).(11) <- lexbuf.Lexing.lex_curr_pos;
            __ocaml_lex_state44 lexbuf)
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
           ->
           ((lexbuf.Lexing.lex_mem).(12) <- lexbuf.Lexing.lex_curr_pos;
            __ocaml_lex_state45 lexbuf)
       | 46 -> __ocaml_lex_state47 lexbuf
       | 123 -> __ocaml_lex_state43 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state4 (lexbuf : Lexing.lexbuf) = 12
    and __ocaml_lex_state5 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 12;
      (match __ocaml_lex_next_char lexbuf with
       | 42 ->
           ((lexbuf.Lexing.lex_mem).(10) <- lexbuf.Lexing.lex_curr_pos;
            __ocaml_lex_state41 lexbuf)
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state6 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 12;
      (match __ocaml_lex_next_char lexbuf with
       | 62 -> __ocaml_lex_state4 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state7 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 16;
      (match __ocaml_lex_next_char lexbuf with
       | 123 -> __ocaml_lex_state36 lexbuf
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
           ->
           ((lexbuf.Lexing.lex_mem).(8) <- lexbuf.Lexing.lex_curr_pos;
            (lexbuf.Lexing.lex_mem).(7) <- lexbuf.Lexing.lex_curr_pos;
            (lexbuf.Lexing.lex_mem).(6) <- lexbuf.Lexing.lex_curr_pos;
            __ocaml_lex_state37 lexbuf)
       | 256 ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action)
       | _ -> __ocaml_lex_state35 lexbuf)
    and __ocaml_lex_state8 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 16;
      (match __ocaml_lex_next_char lexbuf with
       | 10 -> __ocaml_lex_state26 lexbuf
       | 92 -> __ocaml_lex_state23 lexbuf
       | 256 ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action)
       | 13 -> __ocaml_lex_state25 lexbuf
       | _ -> __ocaml_lex_state24 lexbuf)
    and __ocaml_lex_state9 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 5;
      (match __ocaml_lex_next_char lexbuf with
       | 48|49|50|51|52|53|54|55|56|57|95 -> __ocaml_lex_state9 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state10 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 5;
      (match __ocaml_lex_next_char lexbuf with
       | 48|49|50|51|52|53|54|55|56|57|95 -> __ocaml_lex_state9 lexbuf
       | 66|98 -> __ocaml_lex_state17 lexbuf
       | 79|111 -> __ocaml_lex_state18 lexbuf
       | 88|120 -> __ocaml_lex_state19 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state11 (lexbuf : Lexing.lexbuf) = 4
    and __ocaml_lex_state12 (lexbuf : Lexing.lexbuf) =
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
           -> __ocaml_lex_state12 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state13 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 2;
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
           -> __ocaml_lex_state13 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state14 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 1;
      (match __ocaml_lex_next_char lexbuf with
       | 10 -> __ocaml_lex_state15 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state15 (lexbuf : Lexing.lexbuf) = 1
    and __ocaml_lex_state16 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 0;
      (match __ocaml_lex_next_char lexbuf with
       | 9|12|32 -> __ocaml_lex_state16 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state17 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
      | 48|49 -> __ocaml_lex_state22 lexbuf
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state18 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
      | 48|49|50|51|52|53|54|55 -> __ocaml_lex_state21 lexbuf
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state19 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
      | 48|49|50|51|52|53|54|55|56|57|65|66|67|68|69|70|97|98|99|100|101|102
          -> __ocaml_lex_state20 lexbuf
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state20 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 5;
      (match __ocaml_lex_next_char lexbuf with
       | 48
         |49
          |50|51|52|53|54|55|56|57|65|66|67|68|69|70|95|97|98|99|100|101|102
           -> __ocaml_lex_state20 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state21 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 5;
      (match __ocaml_lex_next_char lexbuf with
       | 48|49|50|51|52|53|54|55|95 -> __ocaml_lex_state21 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state22 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 5;
      (match __ocaml_lex_next_char lexbuf with
       | 48|49|95 -> __ocaml_lex_state22 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state23 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
      | 32|34|39|92|98|110|114|116 -> __ocaml_lex_state32 lexbuf
      | 48|49|50|51|52|53|54|55|56|57 -> __ocaml_lex_state31 lexbuf
      | 256 ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
      | 120 -> __ocaml_lex_state30 lexbuf
      | _ -> __ocaml_lex_state29 lexbuf
    and __ocaml_lex_state24 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
      | 39 -> __ocaml_lex_state28 lexbuf
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state25 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
      | 10 -> __ocaml_lex_state26 lexbuf
      | 39 -> __ocaml_lex_state27 lexbuf
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state26 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
      | 39 -> __ocaml_lex_state27 lexbuf
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state27 (lexbuf : Lexing.lexbuf) = 6
    and __ocaml_lex_state28 (lexbuf : Lexing.lexbuf) = 7
    and __ocaml_lex_state29 (lexbuf : Lexing.lexbuf) = 8
    and __ocaml_lex_state30 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 8;
      (match __ocaml_lex_next_char lexbuf with
       | 48|49|50|51|52|53|54|55|56|57|65|66|67|68|69|70|97|98|99|100|101|102
           -> __ocaml_lex_state34 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state31 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 8;
      (match __ocaml_lex_next_char lexbuf with
       | 48|49|50|51|52|53|54|55|56|57 -> __ocaml_lex_state33 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state32 (lexbuf : Lexing.lexbuf) =
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 8;
      (match __ocaml_lex_next_char lexbuf with
       | 39 -> __ocaml_lex_state28 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state33 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
      | 48|49|50|51|52|53|54|55|56|57 -> __ocaml_lex_state24 lexbuf
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state34 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
      | 48|49|50|51|52|53|54|55|56|57|65|66|67|68|69|70|97|98|99|100|101|102
          -> __ocaml_lex_state24 lexbuf
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state35 (lexbuf : Lexing.lexbuf) = 11
    and __ocaml_lex_state36 (lexbuf : Lexing.lexbuf) =
      (lexbuf.Lexing.lex_mem).(1) <- (-1); 10
    and __ocaml_lex_state37 (lexbuf : Lexing.lexbuf) =
      (lexbuf.Lexing.lex_mem).(2) <- (-1);
      (lexbuf.Lexing.lex_mem).(0) <- (lexbuf.Lexing.lex_mem).(6);
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 9;
      (match __ocaml_lex_next_char lexbuf with
       | 123 -> __ocaml_lex_state38 lexbuf
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
           ->
           ((lexbuf.Lexing.lex_mem).(8) <- lexbuf.Lexing.lex_curr_pos;
            (lexbuf.Lexing.lex_mem).(6) <- lexbuf.Lexing.lex_curr_pos;
            (lexbuf.Lexing.lex_mem).(7) <- lexbuf.Lexing.lex_curr_pos;
            __ocaml_lex_state37 lexbuf)
       | 58 -> __ocaml_lex_state39 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state38 (lexbuf : Lexing.lexbuf) =
      (lexbuf.Lexing.lex_mem).(1) <- (lexbuf.Lexing.lex_mem).(5);
      (lexbuf.Lexing.lex_mem).(0) <- (lexbuf.Lexing.lex_mem).(8);
      10
    and __ocaml_lex_state39 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
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
                                                                   |119
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
          ->
          ((lexbuf.Lexing.lex_mem).(9) <- lexbuf.Lexing.lex_curr_pos;
           __ocaml_lex_state40 lexbuf)
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state40 (lexbuf : Lexing.lexbuf) =
      (lexbuf.Lexing.lex_mem).(0) <- (lexbuf.Lexing.lex_mem).(6);
      (lexbuf.Lexing.lex_mem).(2) <- (lexbuf.Lexing.lex_mem).(7);
      (lexbuf.Lexing.lex_mem).(1) <- (lexbuf.Lexing.lex_mem).(9);
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 9;
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
           ->
           ((lexbuf.Lexing.lex_mem).(9) <- lexbuf.Lexing.lex_curr_pos;
            __ocaml_lex_state40 lexbuf)
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state41 (lexbuf : Lexing.lexbuf) =
      (lexbuf.Lexing.lex_mem).(0) <- (-1);
      lexbuf.Lexing.lex_last_pos <- lexbuf.Lexing.lex_curr_pos;
      lexbuf.Lexing.lex_last_action <- 13;
      (match __ocaml_lex_next_char lexbuf with
       | 41 -> __ocaml_lex_state42 lexbuf
       | _ ->
           (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
            lexbuf.Lexing.lex_last_action))
    and __ocaml_lex_state42 (lexbuf : Lexing.lexbuf) =
      (lexbuf.Lexing.lex_mem).(0) <- (lexbuf.Lexing.lex_mem).(10); 13
    and __ocaml_lex_state43 (lexbuf : Lexing.lexbuf) =
      (lexbuf.Lexing.lex_mem).(3) <- (-1);
      (lexbuf.Lexing.lex_mem).(1) <- (-1);
      14
    and __ocaml_lex_state44 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
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
                                                        |119
                                                         |120
                                                          |121
                                                           |122
                                                            |192
                                                             |193
                                                              |194
                                                               |195
                                                                |196
                                                                 |197
                                                                  |198
                                                                   |199
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
          ->
          ((lexbuf.Lexing.lex_mem).(13) <- lexbuf.Lexing.lex_curr_pos;
           __ocaml_lex_state52 lexbuf)
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state45 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
      | 123 -> __ocaml_lex_state48 lexbuf
      | 39
        |45
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
          ->
          ((lexbuf.Lexing.lex_mem).(12) <- lexbuf.Lexing.lex_curr_pos;
           __ocaml_lex_state45 lexbuf)
      | 64 ->
          ((lexbuf.Lexing.lex_mem).(11) <- lexbuf.Lexing.lex_curr_pos;
           __ocaml_lex_state49 lexbuf)
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state46 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
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
                                                                   |119
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
          -> __ocaml_lex_state46 lexbuf
      | 46 -> __ocaml_lex_state47 lexbuf
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state47 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
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
          -> __ocaml_lex_state46 lexbuf
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
          ->
          ((lexbuf.Lexing.lex_mem).(12) <- lexbuf.Lexing.lex_curr_pos;
           __ocaml_lex_state45 lexbuf)
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state48 (lexbuf : Lexing.lexbuf) =
      (lexbuf.Lexing.lex_mem).(1) <- (-1);
      (lexbuf.Lexing.lex_mem).(3) <- (lexbuf.Lexing.lex_mem).(4);
      (lexbuf.Lexing.lex_mem).(2) <- (lexbuf.Lexing.lex_mem).(12);
      14
    and __ocaml_lex_state49 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
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
                                                        |119
                                                         |120
                                                          |121
                                                           |122
                                                            |192
                                                             |193
                                                              |194
                                                               |195
                                                                |196
                                                                 |197
                                                                  |198
                                                                   |199
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
          ->
          ((lexbuf.Lexing.lex_mem).(13) <- lexbuf.Lexing.lex_curr_pos;
           __ocaml_lex_state50 lexbuf)
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state50 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
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
                                                                   |119
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
          ->
          ((lexbuf.Lexing.lex_mem).(13) <- lexbuf.Lexing.lex_curr_pos;
           __ocaml_lex_state50 lexbuf)
      | 123 -> __ocaml_lex_state51 lexbuf
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state51 (lexbuf : Lexing.lexbuf) =
      (lexbuf.Lexing.lex_mem).(3) <- (lexbuf.Lexing.lex_mem).(4);
      (lexbuf.Lexing.lex_mem).(2) <- (lexbuf.Lexing.lex_mem).(12);
      (lexbuf.Lexing.lex_mem).(1) <- (lexbuf.Lexing.lex_mem).(11);
      (lexbuf.Lexing.lex_mem).(0) <- (lexbuf.Lexing.lex_mem).(13);
      14
    and __ocaml_lex_state52 (lexbuf : Lexing.lexbuf) =
      match __ocaml_lex_next_char lexbuf with
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
                                                                   |119
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
          ->
          ((lexbuf.Lexing.lex_mem).(13) <- lexbuf.Lexing.lex_curr_pos;
           __ocaml_lex_state52 lexbuf)
      | 123 -> __ocaml_lex_state53 lexbuf
      | _ ->
          (lexbuf.Lexing.lex_curr_pos <- lexbuf.Lexing.lex_last_pos;
           lexbuf.Lexing.lex_last_action)
    and __ocaml_lex_state53 (lexbuf : Lexing.lexbuf) =
      (lexbuf.Lexing.lex_mem).(3) <- (-1);
      (lexbuf.Lexing.lex_mem).(1) <- (lexbuf.Lexing.lex_mem).(11);
      (lexbuf.Lexing.lex_mem).(0) <- (lexbuf.Lexing.lex_mem).(13);
      14 in
    __ocaml_lex_init_lexbuf lexbuf 14;
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
          let txt =
            Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 0)
              (lexbuf.Lexing.lex_curr_pos + 0) in
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
      | 3 ->
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
      | 4 ->
          let c = Lexing_util.new_cxt () in
          let old = lexbuf.lex_start_p in
          (Lexing_util.push_loc_cont c lexbuf Lexing_util.lex_string;
           `Str
             {
               loc = (Location_util.( -- )  old lexbuf.lex_curr_p);
               txt = (Lexing_util.buff_contents c)
             })
      | 5 ->
          let txt =
            Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 0)
              (lexbuf.Lexing.lex_curr_pos + 0) in
          `Int { loc = (Lexing_util.from_lexbuf lexbuf); txt }
      | 6 ->
          let txt =
            Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 1)
              (lexbuf.Lexing.lex_curr_pos + (-1)) in
          ((let pos = lexbuf.lex_curr_p in
            lexbuf.lex_curr_p <-
              {
                pos with
                pos_lnum = (pos.pos_lnum + 1);
                pos_bol = (pos.pos_cnum - 1)
              });
           (`Chr
              {
                loc =
                  {
                    loc_start = (lexbuf.lex_start_p);
                    loc_end = (lexbuf.lex_curr_p);
                    loc_ghost = false
                  };
                txt
              } : Tokenf.t ))
      | 7 ->
          let txt =
            Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 1)
              (lexbuf.Lexing.lex_curr_pos + (-1)) in
          (`Chr
             {
               loc =
                 {
                   loc_start = (lexbuf.lex_start_p);
                   loc_end = (lexbuf.lex_curr_p);
                   loc_ghost = false
                 };
               txt
             } : Tokenf.t )
      | 8 ->
          let c =
            Lexing.sub_lexeme_char lexbuf (lexbuf.Lexing.lex_start_pos + 2) in
          Lexing_util.err (Illegal_escape (String.make 1 c))
            ({
               loc_start = (lexbuf.lex_start_p);
               loc_end = (lexbuf.lex_curr_p);
               loc_ghost = false
             } : Locf.t )
      | 9 ->
          let name =
            Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 1)
              (((lexbuf.Lexing.lex_mem).(0)) + 0)
          and follow =
            Lexing.sub_lexeme_opt lexbuf (((lexbuf.Lexing.lex_mem).(2)) + 0)
              (((lexbuf.Lexing.lex_mem).(1)) + 0)
          and txt =
            Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 0)
              (lexbuf.Lexing.lex_curr_pos + 0) in
          let (kind,shift) =
            match follow with
            | None  -> ("", 1)
            | Some _ -> (name, ((String.length name) + 2)) in
          (`Ant
             {
               loc = (Lexing_util.from_lexbuf lexbuf);
               kind;
               txt;
               shift;
               retract = 0;
               cxt = None
             } : Tokenf.t )
      | 10 ->
          let name =
            Lexing.sub_lexeme_opt lexbuf (((lexbuf.Lexing.lex_mem).(1)) + 0)
              (((lexbuf.Lexing.lex_mem).(0)) + 0)
          and txt =
            Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 0)
              (lexbuf.Lexing.lex_curr_pos + 0) in
          let old = lexbuf.lex_start_p in
          let c = Lexing_util.new_cxt () in
          (Lexing_util.store c lexbuf;
           Lexing_util.push_loc_cont c lexbuf Lexing_util.lex_quotation;
           `Ant
             {
               loc =
                 {
                   loc_start = old;
                   loc_end = (lexbuf.lex_curr_p);
                   loc_ghost = false
                 };
               kind = ((match name with | Some n -> n | None  -> ""));
               txt = (Lexing_util.buff_contents c);
               shift = (String.length txt);
               retract = 1;
               cxt = None
             })
      | 11 ->
          let c =
            Lexing.sub_lexeme_char lexbuf (lexbuf.Lexing.lex_start_pos + 1) in
          (Lexing_util.err (Illegal_character c)) @@
            (Lexing_util.from_lexbuf lexbuf)
      | 12 ->
          let txt =
            Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 0)
              (lexbuf.Lexing.lex_curr_pos + 0) in
          `Sym { loc = (Lexing_util.from_lexbuf lexbuf); txt }
      | 13 ->
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
      | 14 ->
          let name =
            Lexing.sub_lexeme_opt lexbuf (((lexbuf.Lexing.lex_mem).(3)) + 0)
              (((lexbuf.Lexing.lex_mem).(2)) + 0)
          and meta =
            Lexing.sub_lexeme_opt lexbuf (((lexbuf.Lexing.lex_mem).(1)) + 0)
              (((lexbuf.Lexing.lex_mem).(0)) + 0)
          and shift =
            Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 0)
              (lexbuf.Lexing.lex_curr_pos + 0) in
          let c = Lexing_util.new_cxt () in
          let name =
            match name with
            | Some name -> Tokenf.name_of_string name
            | None  -> Tokenf.empty_name in
          let old = lexbuf.lex_start_p in
          let txt =
            Lexing_util.store c lexbuf;
            Lexing_util.push_loc_cont c lexbuf Lexing_util.lex_quotation;
            Lexing_util.buff_contents c in
          let loc = Location_util.( -- )  old lexbuf.lex_curr_p in
          let shift = String.length shift in
          let retract = 1 in
          `Quot { Tokenf.name = name; meta; shift; txt; loc; retract }
      | 15 ->
          let pos = lexbuf.lex_curr_p in
          (lexbuf.lex_curr_p <-
             {
               pos with
               pos_bol = (pos.pos_bol + 1);
               pos_cnum = (pos.pos_cnum + 1)
             };
           (let loc = Lexing_util.from_lexbuf lexbuf in
            (`EOI { loc; txt = "" } : Tokenf.t )))
      | 16 ->
          let c =
            Lexing.sub_lexeme_char lexbuf (lexbuf.Lexing.lex_start_pos + 0) in
          (Lexing_util.err (Illegal_character c)) @@
            (Lexing_util.from_lexbuf lexbuf)
      | _ -> failwith "lexing: empty token"))
let from_stream = Lexing_util.adapt_to_stream token
