module type META_LOC =
  sig
    val meta_loc_patt : FanLoc.t -> FanLoc.t -> Ast.patt
    val meta_loc_expr : FanLoc.t -> FanLoc.t -> Ast.expr
  end
let _ = ()
open Ast
module Make(MetaLoc:META_LOC) =
  struct
  module Expr = struct
    open StdMeta.Expr let meta_loc = MetaLoc.meta_loc_expr
    let rec meta_meta_bool: 'loc -> meta_bool -> 'result =
      fun _loc  ->
        function
        | BTrue  -> ExId (_loc, (IdUid (_loc, "BTrue")))
        | BFalse  -> ExId (_loc, (IdUid (_loc, "BFalse")))
        | BAnt a0 -> Ast.ExAnt (_loc, a0)
    and meta_rec_flag: 'loc -> rec_flag -> 'result =
      fun _loc  ->
        function
        | ReRecursive  -> ExId (_loc, (IdUid (_loc, "ReRecursive")))
        | ReNil  -> ExId (_loc, (IdUid (_loc, "ReNil")))
        | ReAnt a0 -> Ast.ExAnt (_loc, a0)
    and meta_direction_flag: 'loc -> direction_flag -> 'result =
      fun _loc  ->
        function
        | DiTo  -> ExId (_loc, (IdUid (_loc, "DiTo")))
        | DiDownto  -> ExId (_loc, (IdUid (_loc, "DiDownto")))
        | DiAnt a0 -> Ast.ExAnt (_loc, a0)
    and meta_mutable_flag: 'loc -> mutable_flag -> 'result =
      fun _loc  ->
        function
        | MuMutable  -> ExId (_loc, (IdUid (_loc, "MuMutable")))
        | MuNil  -> ExId (_loc, (IdUid (_loc, "MuNil")))
        | MuAnt a0 -> Ast.ExAnt (_loc, a0)
    and meta_private_flag: 'loc -> private_flag -> 'result =
      fun _loc  ->
        function
        | PrPrivate  -> ExId (_loc, (IdUid (_loc, "PrPrivate")))
        | PrNil  -> ExId (_loc, (IdUid (_loc, "PrNil")))
        | PrAnt a0 -> Ast.ExAnt (_loc, a0)
    and meta_virtual_flag: 'loc -> virtual_flag -> 'result =
      fun _loc  ->
        function
        | ViVirtual  -> ExId (_loc, (IdUid (_loc, "ViVirtual")))
        | ViNil  -> ExId (_loc, (IdUid (_loc, "ViNil")))
        | ViAnt a0 -> Ast.ExAnt (_loc, a0)
    and meta_override_flag: 'loc -> override_flag -> 'result =
      fun _loc  ->
        function
        | OvOverride  -> ExId (_loc, (IdUid (_loc, "OvOverride")))
        | OvNil  -> ExId (_loc, (IdUid (_loc, "OvNil")))
        | OvAnt a0 -> Ast.ExAnt (_loc, a0)
    and meta_row_var_flag: 'loc -> row_var_flag -> 'result =
      fun _loc  ->
        function
        | RvRowVar  -> ExId (_loc, (IdUid (_loc, "RvRowVar")))
        | RvNil  -> ExId (_loc, (IdUid (_loc, "RvNil")))
        | RvAnt a0 -> Ast.ExAnt (_loc, a0)
    and meta_meta_option :
      'all_a0 .
        ('loc -> 'all_a0 -> 'result) ->
          'loc -> 'all_a0 meta_option -> 'result=
      fun mf_a  _loc  ->
        function
        | ONone  -> ExId (_loc, (IdUid (_loc, "ONone")))
        | OSome a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "OSome")))), (mf_a _loc a0))
        | OAnt a0 -> Ast.ExAnt (_loc, a0)
    and meta_meta_list :
      'all_a0 .
        ('loc -> 'all_a0 -> 'result) -> 'loc -> 'all_a0 meta_list -> 'result=
      fun mf_a  _loc  ->
        function
        | LNil  -> ExId (_loc, (IdUid (_loc, "LNil")))
        | LCons (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "LCons")))),
                     (mf_a _loc a0))), (meta_meta_list mf_a _loc a1))
        | LAnt a0 -> Ast.ExAnt (_loc, a0)
    and meta_ident: 'loc -> ident -> 'result =
      fun _loc  ->
        function
        | IdAcc (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "IdAcc")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_ident _loc a2))
        | IdApp (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "IdApp")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_ident _loc a2))
        | IdLid (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "IdLid")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | IdUid (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "IdUid")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | IdAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_ctyp: 'loc -> ctyp -> 'result =
      fun _loc  ->
        function
        | TyNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "TyNil")))),
                (meta_loc _loc a0))
        | TyAli (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyAli")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyAny a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "TyAny")))),
                (meta_loc _loc a0))
        | TyApp (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyApp")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyArr (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyArr")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyCls (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyCls")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | TyLab (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyLab")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_ctyp _loc a2))
        | TyId (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyId")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | TyMan (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyMan")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyDcl (a0,a1,a2,a3,a4) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc,
                               (ExApp
                                  (_loc,
                                    (ExId (_loc, (IdUid (_loc, "TyDcl")))),
                                    (meta_loc _loc a0))),
                               (meta_string _loc a1))),
                          (meta_list meta_ctyp _loc a2))),
                     (meta_ctyp _loc a3))),
                (meta_list
                   (fun _loc  (a0,a1)  ->
                      Ast.ExTup
                        (_loc,
                          (ExCom
                             (_loc, (meta_ctyp _loc a0), (meta_ctyp _loc a1)))))
                   _loc a4))
        | TyObj (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyObj")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_row_var_flag _loc a2))
        | TyOlb (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyOlb")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_ctyp _loc a2))
        | TyPol (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyPol")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyTypePol (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyTypePol")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyQuo (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyQuo")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | TyQuP (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyQuP")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | TyQuM (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyQuM")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | TyAnP a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "TyAnP")))),
                (meta_loc _loc a0))
        | TyAnM a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "TyAnM")))),
                (meta_loc _loc a0))
        | TyVrn (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyVrn")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | TyRec (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyRec")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyCol (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyCol")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TySem (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TySem")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyCom (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyCom")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TySum (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TySum")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyOf (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyOf")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyAnd (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyAnd")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyOr (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyOr")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyPrv (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyPrv")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyMut (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyMut")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyTup (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyTup")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TySta (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TySta")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyVrnEq (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyVrnEq")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyVrnSup (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyVrnSup")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyVrnInf (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyVrnInf")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyVrnInfSup (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyVrnInfSup")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyAmp (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyAmp")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyOfAmp (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "TyOfAmp")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyPkg (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "TyPkg")))),
                     (meta_loc _loc a0))), (meta_module_type _loc a1))
        | TyAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_patt: 'loc -> patt -> 'result =
      fun _loc  ->
        function
        | PaNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "PaNil")))),
                (meta_loc _loc a0))
        | PaId (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaId")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | PaAli (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "PaAli")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_patt _loc a2))
        | PaAnt (a0,a1) -> Ast.ExAnt (a0, a1)
        | PaAny a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "PaAny")))),
                (meta_loc _loc a0))
        | PaApp (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "PaApp")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_patt _loc a2))
        | PaArr (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaArr")))),
                     (meta_loc _loc a0))), (meta_patt _loc a1))
        | PaCom (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "PaCom")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_patt _loc a2))
        | PaSem (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "PaSem")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_patt _loc a2))
        | PaChr (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaChr")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaInt (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaInt")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaInt32 (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaInt32")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaInt64 (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaInt64")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaNativeInt (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaNativeInt")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaFlo (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaFlo")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaLab (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "PaLab")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_patt _loc a2))
        | PaOlb (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "PaOlb")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_patt _loc a2))
        | PaOlbi (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "PaOlbi")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_patt _loc a2))), (meta_expr _loc a3))
        | PaOrp (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "PaOrp")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_patt _loc a2))
        | PaRng (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "PaRng")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_patt _loc a2))
        | PaRec (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaRec")))),
                     (meta_loc _loc a0))), (meta_patt _loc a1))
        | PaEq (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "PaEq")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_patt _loc a2))
        | PaStr (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaStr")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaTup (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaTup")))),
                     (meta_loc _loc a0))), (meta_patt _loc a1))
        | PaTyc (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "PaTyc")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_ctyp _loc a2))
        | PaTyp (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaTyp")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | PaVrn (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaVrn")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaLaz (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaLaz")))),
                     (meta_loc _loc a0))), (meta_patt _loc a1))
        | PaMod (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "PaMod")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
    and meta_expr: 'loc -> expr -> 'result =
      fun _loc  ->
        function
        | ExNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "ExNil")))),
                (meta_loc _loc a0))
        | ExId (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExId")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | ExAcc (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExAcc")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExAnt (a0,a1) -> Ast.ExAnt (a0, a1)
        | ExApp (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExApp")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExAre (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExAre")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExArr (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExArr")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | ExSem (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExSem")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExAsf a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "ExAsf")))),
                (meta_loc _loc a0))
        | ExAsr (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExAsr")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | ExAss (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExAss")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExChr (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExChr")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExCoe (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "ExCoe")))),
                               (meta_loc _loc a0))), (meta_expr _loc a1))),
                     (meta_ctyp _loc a2))), (meta_ctyp _loc a3))
        | ExFlo (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExFlo")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExFor (a0,a1,a2,a3,a4,a5) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc,
                               (ExApp
                                  (_loc,
                                    (ExApp
                                       (_loc,
                                         (ExId
                                            (_loc, (IdUid (_loc, "ExFor")))),
                                         (meta_loc _loc a0))),
                                    (meta_string _loc a1))),
                               (meta_expr _loc a2))), (meta_expr _loc a3))),
                     (meta_direction_flag _loc a4))), (meta_expr _loc a5))
        | ExFun (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExFun")))),
                     (meta_loc _loc a0))), (meta_match_case _loc a1))
        | ExIfe (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "ExIfe")))),
                               (meta_loc _loc a0))), (meta_expr _loc a1))),
                     (meta_expr _loc a2))), (meta_expr _loc a3))
        | ExInt (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExInt")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExInt32 (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExInt32")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExInt64 (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExInt64")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExNativeInt (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExNativeInt")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExLab (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExLab")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_expr _loc a2))
        | ExLaz (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExLaz")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | ExLet (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "ExLet")))),
                               (meta_loc _loc a0))), (meta_rec_flag _loc a1))),
                     (meta_binding _loc a2))), (meta_expr _loc a3))
        | ExLmd (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "ExLmd")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_module_expr _loc a2))), (meta_expr _loc a3))
        | ExMat (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExMat")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_match_case _loc a2))
        | ExNew (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExNew")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | ExObj (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExObj")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_class_str_item _loc a2))
        | ExOlb (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExOlb")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_expr _loc a2))
        | ExOvr (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExOvr")))),
                     (meta_loc _loc a0))), (meta_rec_binding _loc a1))
        | ExRec (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExRec")))),
                          (meta_loc _loc a0))), (meta_rec_binding _loc a1))),
                (meta_expr _loc a2))
        | ExSeq (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExSeq")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | ExSnd (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExSnd")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_string _loc a2))
        | ExSte (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExSte")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExStr (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExStr")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExTry (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExTry")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_match_case _loc a2))
        | ExTup (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExTup")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | ExCom (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExCom")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExTyc (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExTyc")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_ctyp _loc a2))
        | ExVrn (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExVrn")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExWhi (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExWhi")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExOpI (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExOpI")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_expr _loc a2))
        | ExFUN (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "ExFUN")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_expr _loc a2))
        | ExPkg (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "ExPkg")))),
                     (meta_loc _loc a0))), (meta_module_expr _loc a1))
    and meta_module_type: 'loc -> module_type -> 'result =
      fun _loc  ->
        function
        | MtNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "MtNil")))),
                (meta_loc _loc a0))
        | MtId (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "MtId")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | MtFun (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "MtFun")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_module_type _loc a2))),
                (meta_module_type _loc a3))
        | MtQuo (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "MtQuo")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | MtSig (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "MtSig")))),
                     (meta_loc _loc a0))), (meta_sig_item _loc a1))
        | MtWit (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "MtWit")))),
                          (meta_loc _loc a0))), (meta_module_type _loc a1))),
                (meta_with_constr _loc a2))
        | MtOf (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "MtOf")))),
                     (meta_loc _loc a0))), (meta_module_expr _loc a1))
        | MtAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_sig_item: 'loc -> sig_item -> 'result =
      fun _loc  ->
        function
        | SgNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "SgNil")))),
                (meta_loc _loc a0))
        | SgCls (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "SgCls")))),
                     (meta_loc _loc a0))), (meta_class_type _loc a1))
        | SgClt (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "SgClt")))),
                     (meta_loc _loc a0))), (meta_class_type _loc a1))
        | SgSem (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "SgSem")))),
                          (meta_loc _loc a0))), (meta_sig_item _loc a1))),
                (meta_sig_item _loc a2))
        | SgDir (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "SgDir")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_expr _loc a2))
        | SgExc (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "SgExc")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | SgExt (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "SgExt")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_ctyp _loc a2))),
                (meta_meta_list meta_string _loc a3))
        | SgInc (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "SgInc")))),
                     (meta_loc _loc a0))), (meta_module_type _loc a1))
        | SgMod (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "SgMod")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_module_type _loc a2))
        | SgRecMod (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "SgRecMod")))),
                     (meta_loc _loc a0))), (meta_module_binding _loc a1))
        | SgMty (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "SgMty")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_module_type _loc a2))
        | SgOpn (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "SgOpn")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | SgTyp (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "SgTyp")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | SgVal (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "SgVal")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_ctyp _loc a2))
        | SgAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_with_constr: 'loc -> with_constr -> 'result =
      fun _loc  ->
        function
        | WcNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "WcNil")))),
                (meta_loc _loc a0))
        | WcTyp (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "WcTyp")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | WcMod (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "WcMod")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_ident _loc a2))
        | WcTyS (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "WcTyS")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | WcMoS (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "WcMoS")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_ident _loc a2))
        | WcAnd (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "WcAnd")))),
                          (meta_loc _loc a0))), (meta_with_constr _loc a1))),
                (meta_with_constr _loc a2))
        | WcAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_binding: 'loc -> binding -> 'result =
      fun _loc  ->
        function
        | BiNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "BiNil")))),
                (meta_loc _loc a0))
        | BiAnd (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "BiAnd")))),
                          (meta_loc _loc a0))), (meta_binding _loc a1))),
                (meta_binding _loc a2))
        | BiEq (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "BiEq")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_expr _loc a2))
        | BiAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_rec_binding: 'loc -> rec_binding -> 'result =
      fun _loc  ->
        function
        | RbNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "RbNil")))),
                (meta_loc _loc a0))
        | RbSem (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "RbSem")))),
                          (meta_loc _loc a0))), (meta_rec_binding _loc a1))),
                (meta_rec_binding _loc a2))
        | RbEq (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "RbEq")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_expr _loc a2))
        | RbAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_module_binding: 'loc -> module_binding -> 'result =
      fun _loc  ->
        function
        | MbNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "MbNil")))),
                (meta_loc _loc a0))
        | MbAnd (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "MbAnd")))),
                          (meta_loc _loc a0))),
                     (meta_module_binding _loc a1))),
                (meta_module_binding _loc a2))
        | MbColEq (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "MbColEq")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_module_type _loc a2))),
                (meta_module_expr _loc a3))
        | MbCol (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "MbCol")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_module_type _loc a2))
        | MbAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_match_case: 'loc -> match_case -> 'result =
      fun _loc  ->
        function
        | McNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "McNil")))),
                (meta_loc _loc a0))
        | McOr (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "McOr")))),
                          (meta_loc _loc a0))), (meta_match_case _loc a1))),
                (meta_match_case _loc a2))
        | McArr (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "McArr")))),
                               (meta_loc _loc a0))), (meta_patt _loc a1))),
                     (meta_expr _loc a2))), (meta_expr _loc a3))
        | McAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_module_expr: 'loc -> module_expr -> 'result =
      fun _loc  ->
        function
        | MeNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "MeNil")))),
                (meta_loc _loc a0))
        | MeId (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "MeId")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | MeApp (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "MeApp")))),
                          (meta_loc _loc a0))), (meta_module_expr _loc a1))),
                (meta_module_expr _loc a2))
        | MeFun (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "MeFun")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_module_type _loc a2))),
                (meta_module_expr _loc a3))
        | MeStr (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "MeStr")))),
                     (meta_loc _loc a0))), (meta_str_item _loc a1))
        | MeTyc (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "MeTyc")))),
                          (meta_loc _loc a0))), (meta_module_expr _loc a1))),
                (meta_module_type _loc a2))
        | MePkg (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "MePkg")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | MeAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_str_item: 'loc -> str_item -> 'result =
      fun _loc  ->
        function
        | StNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "StNil")))),
                (meta_loc _loc a0))
        | StCls (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "StCls")))),
                     (meta_loc _loc a0))), (meta_class_expr _loc a1))
        | StClt (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "StClt")))),
                     (meta_loc _loc a0))), (meta_class_type _loc a1))
        | StSem (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "StSem")))),
                          (meta_loc _loc a0))), (meta_str_item _loc a1))),
                (meta_str_item _loc a2))
        | StDir (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "StDir")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_expr _loc a2))
        | StExc (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "StExc")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_meta_option meta_ident _loc a2))
        | StExp (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "StExp")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | StExt (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "StExt")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_ctyp _loc a2))),
                (meta_meta_list meta_string _loc a3))
        | StInc (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "StInc")))),
                     (meta_loc _loc a0))), (meta_module_expr _loc a1))
        | StMod (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "StMod")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_module_expr _loc a2))
        | StRecMod (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "StRecMod")))),
                     (meta_loc _loc a0))), (meta_module_binding _loc a1))
        | StMty (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "StMty")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_module_type _loc a2))
        | StOpn (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "StOpn")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | StTyp (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "StTyp")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | StVal (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "StVal")))),
                          (meta_loc _loc a0))), (meta_rec_flag _loc a1))),
                (meta_binding _loc a2))
        | StAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_class_type: 'loc -> class_type -> 'result =
      fun _loc  ->
        function
        | CtNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "CtNil")))),
                (meta_loc _loc a0))
        | CtCon (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "CtCon")))),
                               (meta_loc _loc a0))),
                          (meta_virtual_flag _loc a1))),
                     (meta_ident _loc a2))), (meta_ctyp _loc a3))
        | CtFun (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CtFun")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_class_type _loc a2))
        | CtSig (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CtSig")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_class_sig_item _loc a2))
        | CtAnd (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CtAnd")))),
                          (meta_loc _loc a0))), (meta_class_type _loc a1))),
                (meta_class_type _loc a2))
        | CtCol (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CtCol")))),
                          (meta_loc _loc a0))), (meta_class_type _loc a1))),
                (meta_class_type _loc a2))
        | CtEq (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CtEq")))),
                          (meta_loc _loc a0))), (meta_class_type _loc a1))),
                (meta_class_type _loc a2))
        | CtAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_class_sig_item: 'loc -> class_sig_item -> 'result =
      fun _loc  ->
        function
        | CgNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "CgNil")))),
                (meta_loc _loc a0))
        | CgCtr (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CgCtr")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | CgSem (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CgSem")))),
                          (meta_loc _loc a0))),
                     (meta_class_sig_item _loc a1))),
                (meta_class_sig_item _loc a2))
        | CgInh (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "CgInh")))),
                     (meta_loc _loc a0))), (meta_class_type _loc a1))
        | CgMth (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "CgMth")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_private_flag _loc a2))), (meta_ctyp _loc a3))
        | CgVal (a0,a1,a2,a3,a4) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc,
                               (ExApp
                                  (_loc,
                                    (ExId (_loc, (IdUid (_loc, "CgVal")))),
                                    (meta_loc _loc a0))),
                               (meta_string _loc a1))),
                          (meta_mutable_flag _loc a2))),
                     (meta_virtual_flag _loc a3))), (meta_ctyp _loc a4))
        | CgVir (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "CgVir")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_private_flag _loc a2))), (meta_ctyp _loc a3))
        | CgAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_class_expr: 'loc -> class_expr -> 'result =
      fun _loc  ->
        function
        | CeNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "CeNil")))),
                (meta_loc _loc a0))
        | CeApp (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CeApp")))),
                          (meta_loc _loc a0))), (meta_class_expr _loc a1))),
                (meta_expr _loc a2))
        | CeCon (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "CeCon")))),
                               (meta_loc _loc a0))),
                          (meta_virtual_flag _loc a1))),
                     (meta_ident _loc a2))), (meta_ctyp _loc a3))
        | CeFun (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CeFun")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_class_expr _loc a2))
        | CeLet (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "CeLet")))),
                               (meta_loc _loc a0))), (meta_rec_flag _loc a1))),
                     (meta_binding _loc a2))), (meta_class_expr _loc a3))
        | CeStr (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CeStr")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_class_str_item _loc a2))
        | CeTyc (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CeTyc")))),
                          (meta_loc _loc a0))), (meta_class_expr _loc a1))),
                (meta_class_type _loc a2))
        | CeAnd (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CeAnd")))),
                          (meta_loc _loc a0))), (meta_class_expr _loc a1))),
                (meta_class_expr _loc a2))
        | CeEq (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CeEq")))),
                          (meta_loc _loc a0))), (meta_class_expr _loc a1))),
                (meta_class_expr _loc a2))
        | CeAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    and meta_class_str_item: 'loc -> class_str_item -> 'result =
      fun _loc  ->
        function
        | CrNil a0 ->
            ExApp
              (_loc, (ExId (_loc, (IdUid (_loc, "CrNil")))),
                (meta_loc _loc a0))
        | CrSem (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CrSem")))),
                          (meta_loc _loc a0))),
                     (meta_class_str_item _loc a1))),
                (meta_class_str_item _loc a2))
        | CrCtr (a0,a1,a2) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc, (ExId (_loc, (IdUid (_loc, "CrCtr")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | CrInh (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "CrInh")))),
                               (meta_loc _loc a0))),
                          (meta_override_flag _loc a1))),
                     (meta_class_expr _loc a2))), (meta_string _loc a3))
        | CrIni (a0,a1) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc, (ExId (_loc, (IdUid (_loc, "CrIni")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | CrMth (a0,a1,a2,a3,a4,a5) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc,
                               (ExApp
                                  (_loc,
                                    (ExApp
                                       (_loc,
                                         (ExId
                                            (_loc, (IdUid (_loc, "CrMth")))),
                                         (meta_loc _loc a0))),
                                    (meta_string _loc a1))),
                               (meta_override_flag _loc a2))),
                          (meta_private_flag _loc a3))), (meta_expr _loc a4))),
                (meta_ctyp _loc a5))
        | CrVal (a0,a1,a2,a3,a4) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc,
                               (ExApp
                                  (_loc,
                                    (ExId (_loc, (IdUid (_loc, "CrVal")))),
                                    (meta_loc _loc a0))),
                               (meta_string _loc a1))),
                          (meta_override_flag _loc a2))),
                     (meta_mutable_flag _loc a3))), (meta_expr _loc a4))
        | CrVir (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "CrVir")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_private_flag _loc a2))), (meta_ctyp _loc a3))
        | CrVvr (a0,a1,a2,a3) ->
            ExApp
              (_loc,
                (ExApp
                   (_loc,
                     (ExApp
                        (_loc,
                          (ExApp
                             (_loc, (ExId (_loc, (IdUid (_loc, "CrVvr")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_mutable_flag _loc a2))), (meta_ctyp _loc a3))
        | CrAnt (a0,a1) -> Ast.ExAnt (a0, a1)
    end
  module Patt = struct
    open StdMeta.Patt let meta_loc = MetaLoc.meta_loc_patt
    let rec meta_meta_bool: 'loc -> meta_bool -> 'result =
      fun _loc  ->
        function
        | BTrue  -> PaId (_loc, (IdUid (_loc, "BTrue")))
        | BFalse  -> PaId (_loc, (IdUid (_loc, "BFalse")))
        | BAnt a0 -> Ast.PaAnt (_loc, a0)
    and meta_rec_flag: 'loc -> rec_flag -> 'result =
      fun _loc  ->
        function
        | ReRecursive  -> PaId (_loc, (IdUid (_loc, "ReRecursive")))
        | ReNil  -> PaId (_loc, (IdUid (_loc, "ReNil")))
        | ReAnt a0 -> Ast.PaAnt (_loc, a0)
    and meta_direction_flag: 'loc -> direction_flag -> 'result =
      fun _loc  ->
        function
        | DiTo  -> PaId (_loc, (IdUid (_loc, "DiTo")))
        | DiDownto  -> PaId (_loc, (IdUid (_loc, "DiDownto")))
        | DiAnt a0 -> Ast.PaAnt (_loc, a0)
    and meta_mutable_flag: 'loc -> mutable_flag -> 'result =
      fun _loc  ->
        function
        | MuMutable  -> PaId (_loc, (IdUid (_loc, "MuMutable")))
        | MuNil  -> PaId (_loc, (IdUid (_loc, "MuNil")))
        | MuAnt a0 -> Ast.PaAnt (_loc, a0)
    and meta_private_flag: 'loc -> private_flag -> 'result =
      fun _loc  ->
        function
        | PrPrivate  -> PaId (_loc, (IdUid (_loc, "PrPrivate")))
        | PrNil  -> PaId (_loc, (IdUid (_loc, "PrNil")))
        | PrAnt a0 -> Ast.PaAnt (_loc, a0)
    and meta_virtual_flag: 'loc -> virtual_flag -> 'result =
      fun _loc  ->
        function
        | ViVirtual  -> PaId (_loc, (IdUid (_loc, "ViVirtual")))
        | ViNil  -> PaId (_loc, (IdUid (_loc, "ViNil")))
        | ViAnt a0 -> Ast.PaAnt (_loc, a0)
    and meta_override_flag: 'loc -> override_flag -> 'result =
      fun _loc  ->
        function
        | OvOverride  -> PaId (_loc, (IdUid (_loc, "OvOverride")))
        | OvNil  -> PaId (_loc, (IdUid (_loc, "OvNil")))
        | OvAnt a0 -> Ast.PaAnt (_loc, a0)
    and meta_row_var_flag: 'loc -> row_var_flag -> 'result =
      fun _loc  ->
        function
        | RvRowVar  -> PaId (_loc, (IdUid (_loc, "RvRowVar")))
        | RvNil  -> PaId (_loc, (IdUid (_loc, "RvNil")))
        | RvAnt a0 -> Ast.PaAnt (_loc, a0)
    and meta_meta_option :
      'all_a0 .
        ('loc -> 'all_a0 -> 'result) ->
          'loc -> 'all_a0 meta_option -> 'result=
      fun mf_a  _loc  ->
        function
        | ONone  -> PaId (_loc, (IdUid (_loc, "ONone")))
        | OSome a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "OSome")))), (mf_a _loc a0))
        | OAnt a0 -> Ast.PaAnt (_loc, a0)
    and meta_meta_list :
      'all_a0 .
        ('loc -> 'all_a0 -> 'result) -> 'loc -> 'all_a0 meta_list -> 'result=
      fun mf_a  _loc  ->
        function
        | LNil  -> PaId (_loc, (IdUid (_loc, "LNil")))
        | LCons (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "LCons")))),
                     (mf_a _loc a0))), (meta_meta_list mf_a _loc a1))
        | LAnt a0 -> Ast.PaAnt (_loc, a0)
    and meta_ident: 'loc -> ident -> 'result =
      fun _loc  ->
        function
        | IdAcc (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "IdAcc")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_ident _loc a2))
        | IdApp (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "IdApp")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_ident _loc a2))
        | IdLid (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "IdLid")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | IdUid (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "IdUid")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | IdAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_ctyp: 'loc -> ctyp -> 'result =
      fun _loc  ->
        function
        | TyNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "TyNil")))),
                (meta_loc _loc a0))
        | TyAli (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyAli")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyAny a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "TyAny")))),
                (meta_loc _loc a0))
        | TyApp (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyApp")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyArr (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyArr")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyCls (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyCls")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | TyLab (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyLab")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_ctyp _loc a2))
        | TyId (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyId")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | TyMan (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyMan")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyDcl (a0,a1,a2,a3,a4) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc,
                               (PaApp
                                  (_loc,
                                    (PaId (_loc, (IdUid (_loc, "TyDcl")))),
                                    (meta_loc _loc a0))),
                               (meta_string _loc a1))),
                          (meta_list meta_ctyp _loc a2))),
                     (meta_ctyp _loc a3))),
                (meta_list
                   (fun _loc  (a0,a1)  ->
                      PaTup
                        (_loc,
                          (PaCom
                             (_loc, (meta_ctyp _loc a0), (meta_ctyp _loc a1)))))
                   _loc a4))
        | TyObj (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyObj")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_row_var_flag _loc a2))
        | TyOlb (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyOlb")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_ctyp _loc a2))
        | TyPol (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyPol")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyTypePol (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyTypePol")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyQuo (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyQuo")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | TyQuP (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyQuP")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | TyQuM (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyQuM")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | TyAnP a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "TyAnP")))),
                (meta_loc _loc a0))
        | TyAnM a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "TyAnM")))),
                (meta_loc _loc a0))
        | TyVrn (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyVrn")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | TyRec (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyRec")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyCol (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyCol")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TySem (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TySem")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyCom (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyCom")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TySum (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TySum")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyOf (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyOf")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyAnd (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyAnd")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyOr (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyOr")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyPrv (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyPrv")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyMut (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyMut")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyTup (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyTup")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TySta (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TySta")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyVrnEq (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyVrnEq")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyVrnSup (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyVrnSup")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyVrnInf (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyVrnInf")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | TyVrnInfSup (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyVrnInfSup")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyAmp (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyAmp")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyOfAmp (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "TyOfAmp")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | TyPkg (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "TyPkg")))),
                     (meta_loc _loc a0))), (meta_module_type _loc a1))
        | TyAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_patt: 'loc -> patt -> 'result =
      fun _loc  ->
        function
        | PaNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "PaNil")))),
                (meta_loc _loc a0))
        | PaId (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaId")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | PaAli (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "PaAli")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_patt _loc a2))
        | PaAnt (a0,a1) -> Ast.PaAnt (a0, a1)
        | PaAny a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "PaAny")))),
                (meta_loc _loc a0))
        | PaApp (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "PaApp")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_patt _loc a2))
        | PaArr (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaArr")))),
                     (meta_loc _loc a0))), (meta_patt _loc a1))
        | PaCom (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "PaCom")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_patt _loc a2))
        | PaSem (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "PaSem")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_patt _loc a2))
        | PaChr (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaChr")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaInt (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaInt")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaInt32 (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaInt32")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaInt64 (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaInt64")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaNativeInt (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaNativeInt")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaFlo (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaFlo")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaLab (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "PaLab")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_patt _loc a2))
        | PaOlb (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "PaOlb")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_patt _loc a2))
        | PaOlbi (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "PaOlbi")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_patt _loc a2))), (meta_expr _loc a3))
        | PaOrp (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "PaOrp")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_patt _loc a2))
        | PaRng (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "PaRng")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_patt _loc a2))
        | PaRec (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaRec")))),
                     (meta_loc _loc a0))), (meta_patt _loc a1))
        | PaEq (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "PaEq")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_patt _loc a2))
        | PaStr (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaStr")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaTup (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaTup")))),
                     (meta_loc _loc a0))), (meta_patt _loc a1))
        | PaTyc (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "PaTyc")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_ctyp _loc a2))
        | PaTyp (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaTyp")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | PaVrn (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaVrn")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | PaLaz (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaLaz")))),
                     (meta_loc _loc a0))), (meta_patt _loc a1))
        | PaMod (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "PaMod")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
    and meta_expr: 'loc -> expr -> 'result =
      fun _loc  ->
        function
        | ExNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "ExNil")))),
                (meta_loc _loc a0))
        | ExId (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExId")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | ExAcc (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExAcc")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExAnt (a0,a1) -> Ast.PaAnt (a0, a1)
        | ExApp (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExApp")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExAre (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExAre")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExArr (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExArr")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | ExSem (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExSem")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExAsf a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "ExAsf")))),
                (meta_loc _loc a0))
        | ExAsr (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExAsr")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | ExAss (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExAss")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExChr (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExChr")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExCoe (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "ExCoe")))),
                               (meta_loc _loc a0))), (meta_expr _loc a1))),
                     (meta_ctyp _loc a2))), (meta_ctyp _loc a3))
        | ExFlo (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExFlo")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExFor (a0,a1,a2,a3,a4,a5) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc,
                               (PaApp
                                  (_loc,
                                    (PaApp
                                       (_loc,
                                         (PaId
                                            (_loc, (IdUid (_loc, "ExFor")))),
                                         (meta_loc _loc a0))),
                                    (meta_string _loc a1))),
                               (meta_expr _loc a2))), (meta_expr _loc a3))),
                     (meta_direction_flag _loc a4))), (meta_expr _loc a5))
        | ExFun (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExFun")))),
                     (meta_loc _loc a0))), (meta_match_case _loc a1))
        | ExIfe (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "ExIfe")))),
                               (meta_loc _loc a0))), (meta_expr _loc a1))),
                     (meta_expr _loc a2))), (meta_expr _loc a3))
        | ExInt (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExInt")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExInt32 (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExInt32")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExInt64 (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExInt64")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExNativeInt (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExNativeInt")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExLab (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExLab")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_expr _loc a2))
        | ExLaz (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExLaz")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | ExLet (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "ExLet")))),
                               (meta_loc _loc a0))), (meta_rec_flag _loc a1))),
                     (meta_binding _loc a2))), (meta_expr _loc a3))
        | ExLmd (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "ExLmd")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_module_expr _loc a2))), (meta_expr _loc a3))
        | ExMat (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExMat")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_match_case _loc a2))
        | ExNew (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExNew")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | ExObj (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExObj")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_class_str_item _loc a2))
        | ExOlb (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExOlb")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_expr _loc a2))
        | ExOvr (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExOvr")))),
                     (meta_loc _loc a0))), (meta_rec_binding _loc a1))
        | ExRec (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExRec")))),
                          (meta_loc _loc a0))), (meta_rec_binding _loc a1))),
                (meta_expr _loc a2))
        | ExSeq (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExSeq")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | ExSnd (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExSnd")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_string _loc a2))
        | ExSte (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExSte")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExStr (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExStr")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExTry (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExTry")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_match_case _loc a2))
        | ExTup (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExTup")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | ExCom (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExCom")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExTyc (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExTyc")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_ctyp _loc a2))
        | ExVrn (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExVrn")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | ExWhi (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExWhi")))),
                          (meta_loc _loc a0))), (meta_expr _loc a1))),
                (meta_expr _loc a2))
        | ExOpI (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExOpI")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_expr _loc a2))
        | ExFUN (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "ExFUN")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_expr _loc a2))
        | ExPkg (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "ExPkg")))),
                     (meta_loc _loc a0))), (meta_module_expr _loc a1))
    and meta_module_type: 'loc -> module_type -> 'result =
      fun _loc  ->
        function
        | MtNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "MtNil")))),
                (meta_loc _loc a0))
        | MtId (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "MtId")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | MtFun (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "MtFun")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_module_type _loc a2))),
                (meta_module_type _loc a3))
        | MtQuo (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "MtQuo")))),
                     (meta_loc _loc a0))), (meta_string _loc a1))
        | MtSig (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "MtSig")))),
                     (meta_loc _loc a0))), (meta_sig_item _loc a1))
        | MtWit (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "MtWit")))),
                          (meta_loc _loc a0))), (meta_module_type _loc a1))),
                (meta_with_constr _loc a2))
        | MtOf (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "MtOf")))),
                     (meta_loc _loc a0))), (meta_module_expr _loc a1))
        | MtAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_sig_item: 'loc -> sig_item -> 'result =
      fun _loc  ->
        function
        | SgNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "SgNil")))),
                (meta_loc _loc a0))
        | SgCls (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "SgCls")))),
                     (meta_loc _loc a0))), (meta_class_type _loc a1))
        | SgClt (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "SgClt")))),
                     (meta_loc _loc a0))), (meta_class_type _loc a1))
        | SgSem (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "SgSem")))),
                          (meta_loc _loc a0))), (meta_sig_item _loc a1))),
                (meta_sig_item _loc a2))
        | SgDir (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "SgDir")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_expr _loc a2))
        | SgExc (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "SgExc")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | SgExt (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "SgExt")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_ctyp _loc a2))),
                (meta_meta_list meta_string _loc a3))
        | SgInc (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "SgInc")))),
                     (meta_loc _loc a0))), (meta_module_type _loc a1))
        | SgMod (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "SgMod")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_module_type _loc a2))
        | SgRecMod (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "SgRecMod")))),
                     (meta_loc _loc a0))), (meta_module_binding _loc a1))
        | SgMty (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "SgMty")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_module_type _loc a2))
        | SgOpn (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "SgOpn")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | SgTyp (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "SgTyp")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | SgVal (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "SgVal")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_ctyp _loc a2))
        | SgAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_with_constr: 'loc -> with_constr -> 'result =
      fun _loc  ->
        function
        | WcNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "WcNil")))),
                (meta_loc _loc a0))
        | WcTyp (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "WcTyp")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | WcMod (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "WcMod")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_ident _loc a2))
        | WcTyS (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "WcTyS")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | WcMoS (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "WcMoS")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_ident _loc a2))
        | WcAnd (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "WcAnd")))),
                          (meta_loc _loc a0))), (meta_with_constr _loc a1))),
                (meta_with_constr _loc a2))
        | WcAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_binding: 'loc -> binding -> 'result =
      fun _loc  ->
        function
        | BiNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "BiNil")))),
                (meta_loc _loc a0))
        | BiAnd (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "BiAnd")))),
                          (meta_loc _loc a0))), (meta_binding _loc a1))),
                (meta_binding _loc a2))
        | BiEq (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "BiEq")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_expr _loc a2))
        | BiAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_rec_binding: 'loc -> rec_binding -> 'result =
      fun _loc  ->
        function
        | RbNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "RbNil")))),
                (meta_loc _loc a0))
        | RbSem (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "RbSem")))),
                          (meta_loc _loc a0))), (meta_rec_binding _loc a1))),
                (meta_rec_binding _loc a2))
        | RbEq (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "RbEq")))),
                          (meta_loc _loc a0))), (meta_ident _loc a1))),
                (meta_expr _loc a2))
        | RbAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_module_binding: 'loc -> module_binding -> 'result =
      fun _loc  ->
        function
        | MbNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "MbNil")))),
                (meta_loc _loc a0))
        | MbAnd (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "MbAnd")))),
                          (meta_loc _loc a0))),
                     (meta_module_binding _loc a1))),
                (meta_module_binding _loc a2))
        | MbColEq (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "MbColEq")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_module_type _loc a2))),
                (meta_module_expr _loc a3))
        | MbCol (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "MbCol")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_module_type _loc a2))
        | MbAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_match_case: 'loc -> match_case -> 'result =
      fun _loc  ->
        function
        | McNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "McNil")))),
                (meta_loc _loc a0))
        | McOr (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "McOr")))),
                          (meta_loc _loc a0))), (meta_match_case _loc a1))),
                (meta_match_case _loc a2))
        | McArr (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "McArr")))),
                               (meta_loc _loc a0))), (meta_patt _loc a1))),
                     (meta_expr _loc a2))), (meta_expr _loc a3))
        | McAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_module_expr: 'loc -> module_expr -> 'result =
      fun _loc  ->
        function
        | MeNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "MeNil")))),
                (meta_loc _loc a0))
        | MeId (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "MeId")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | MeApp (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "MeApp")))),
                          (meta_loc _loc a0))), (meta_module_expr _loc a1))),
                (meta_module_expr _loc a2))
        | MeFun (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "MeFun")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_module_type _loc a2))),
                (meta_module_expr _loc a3))
        | MeStr (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "MeStr")))),
                     (meta_loc _loc a0))), (meta_str_item _loc a1))
        | MeTyc (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "MeTyc")))),
                          (meta_loc _loc a0))), (meta_module_expr _loc a1))),
                (meta_module_type _loc a2))
        | MePkg (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "MePkg")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | MeAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_str_item: 'loc -> str_item -> 'result =
      fun _loc  ->
        function
        | StNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "StNil")))),
                (meta_loc _loc a0))
        | StCls (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "StCls")))),
                     (meta_loc _loc a0))), (meta_class_expr _loc a1))
        | StClt (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "StClt")))),
                     (meta_loc _loc a0))), (meta_class_type _loc a1))
        | StSem (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "StSem")))),
                          (meta_loc _loc a0))), (meta_str_item _loc a1))),
                (meta_str_item _loc a2))
        | StDir (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "StDir")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_expr _loc a2))
        | StExc (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "StExc")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_meta_option meta_ident _loc a2))
        | StExp (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "StExp")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | StExt (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "StExt")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_ctyp _loc a2))),
                (meta_meta_list meta_string _loc a3))
        | StInc (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "StInc")))),
                     (meta_loc _loc a0))), (meta_module_expr _loc a1))
        | StMod (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "StMod")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_module_expr _loc a2))
        | StRecMod (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "StRecMod")))),
                     (meta_loc _loc a0))), (meta_module_binding _loc a1))
        | StMty (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "StMty")))),
                          (meta_loc _loc a0))), (meta_string _loc a1))),
                (meta_module_type _loc a2))
        | StOpn (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "StOpn")))),
                     (meta_loc _loc a0))), (meta_ident _loc a1))
        | StTyp (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "StTyp")))),
                     (meta_loc _loc a0))), (meta_ctyp _loc a1))
        | StVal (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "StVal")))),
                          (meta_loc _loc a0))), (meta_rec_flag _loc a1))),
                (meta_binding _loc a2))
        | StAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_class_type: 'loc -> class_type -> 'result =
      fun _loc  ->
        function
        | CtNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "CtNil")))),
                (meta_loc _loc a0))
        | CtCon (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "CtCon")))),
                               (meta_loc _loc a0))),
                          (meta_virtual_flag _loc a1))),
                     (meta_ident _loc a2))), (meta_ctyp _loc a3))
        | CtFun (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CtFun")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_class_type _loc a2))
        | CtSig (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CtSig")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_class_sig_item _loc a2))
        | CtAnd (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CtAnd")))),
                          (meta_loc _loc a0))), (meta_class_type _loc a1))),
                (meta_class_type _loc a2))
        | CtCol (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CtCol")))),
                          (meta_loc _loc a0))), (meta_class_type _loc a1))),
                (meta_class_type _loc a2))
        | CtEq (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CtEq")))),
                          (meta_loc _loc a0))), (meta_class_type _loc a1))),
                (meta_class_type _loc a2))
        | CtAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_class_sig_item: 'loc -> class_sig_item -> 'result =
      fun _loc  ->
        function
        | CgNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "CgNil")))),
                (meta_loc _loc a0))
        | CgCtr (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CgCtr")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | CgSem (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CgSem")))),
                          (meta_loc _loc a0))),
                     (meta_class_sig_item _loc a1))),
                (meta_class_sig_item _loc a2))
        | CgInh (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "CgInh")))),
                     (meta_loc _loc a0))), (meta_class_type _loc a1))
        | CgMth (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "CgMth")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_private_flag _loc a2))), (meta_ctyp _loc a3))
        | CgVal (a0,a1,a2,a3,a4) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc,
                               (PaApp
                                  (_loc,
                                    (PaId (_loc, (IdUid (_loc, "CgVal")))),
                                    (meta_loc _loc a0))),
                               (meta_string _loc a1))),
                          (meta_mutable_flag _loc a2))),
                     (meta_virtual_flag _loc a3))), (meta_ctyp _loc a4))
        | CgVir (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "CgVir")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_private_flag _loc a2))), (meta_ctyp _loc a3))
        | CgAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_class_expr: 'loc -> class_expr -> 'result =
      fun _loc  ->
        function
        | CeNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "CeNil")))),
                (meta_loc _loc a0))
        | CeApp (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CeApp")))),
                          (meta_loc _loc a0))), (meta_class_expr _loc a1))),
                (meta_expr _loc a2))
        | CeCon (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "CeCon")))),
                               (meta_loc _loc a0))),
                          (meta_virtual_flag _loc a1))),
                     (meta_ident _loc a2))), (meta_ctyp _loc a3))
        | CeFun (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CeFun")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_class_expr _loc a2))
        | CeLet (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "CeLet")))),
                               (meta_loc _loc a0))), (meta_rec_flag _loc a1))),
                     (meta_binding _loc a2))), (meta_class_expr _loc a3))
        | CeStr (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CeStr")))),
                          (meta_loc _loc a0))), (meta_patt _loc a1))),
                (meta_class_str_item _loc a2))
        | CeTyc (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CeTyc")))),
                          (meta_loc _loc a0))), (meta_class_expr _loc a1))),
                (meta_class_type _loc a2))
        | CeAnd (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CeAnd")))),
                          (meta_loc _loc a0))), (meta_class_expr _loc a1))),
                (meta_class_expr _loc a2))
        | CeEq (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CeEq")))),
                          (meta_loc _loc a0))), (meta_class_expr _loc a1))),
                (meta_class_expr _loc a2))
        | CeAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    and meta_class_str_item: 'loc -> class_str_item -> 'result =
      fun _loc  ->
        function
        | CrNil a0 ->
            PaApp
              (_loc, (PaId (_loc, (IdUid (_loc, "CrNil")))),
                (meta_loc _loc a0))
        | CrSem (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CrSem")))),
                          (meta_loc _loc a0))),
                     (meta_class_str_item _loc a1))),
                (meta_class_str_item _loc a2))
        | CrCtr (a0,a1,a2) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc, (PaId (_loc, (IdUid (_loc, "CrCtr")))),
                          (meta_loc _loc a0))), (meta_ctyp _loc a1))),
                (meta_ctyp _loc a2))
        | CrInh (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "CrInh")))),
                               (meta_loc _loc a0))),
                          (meta_override_flag _loc a1))),
                     (meta_class_expr _loc a2))), (meta_string _loc a3))
        | CrIni (a0,a1) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc, (PaId (_loc, (IdUid (_loc, "CrIni")))),
                     (meta_loc _loc a0))), (meta_expr _loc a1))
        | CrMth (a0,a1,a2,a3,a4,a5) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc,
                               (PaApp
                                  (_loc,
                                    (PaApp
                                       (_loc,
                                         (PaId
                                            (_loc, (IdUid (_loc, "CrMth")))),
                                         (meta_loc _loc a0))),
                                    (meta_string _loc a1))),
                               (meta_override_flag _loc a2))),
                          (meta_private_flag _loc a3))), (meta_expr _loc a4))),
                (meta_ctyp _loc a5))
        | CrVal (a0,a1,a2,a3,a4) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc,
                               (PaApp
                                  (_loc,
                                    (PaId (_loc, (IdUid (_loc, "CrVal")))),
                                    (meta_loc _loc a0))),
                               (meta_string _loc a1))),
                          (meta_override_flag _loc a2))),
                     (meta_mutable_flag _loc a3))), (meta_expr _loc a4))
        | CrVir (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "CrVir")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_private_flag _loc a2))), (meta_ctyp _loc a3))
        | CrVvr (a0,a1,a2,a3) ->
            PaApp
              (_loc,
                (PaApp
                   (_loc,
                     (PaApp
                        (_loc,
                          (PaApp
                             (_loc, (PaId (_loc, (IdUid (_loc, "CrVvr")))),
                               (meta_loc _loc a0))), (meta_string _loc a1))),
                     (meta_mutable_flag _loc a2))), (meta_ctyp _loc a3))
        | CrAnt (a0,a1) -> Ast.PaAnt (a0, a1)
    end
  end