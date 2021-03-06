-- This Happy file was machine-generated by the BNF converter
{
{-# OPTIONS_GHC -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
module ParLatte where
import AbsLatte
import LexLatte
import ErrM

}

%name pProgram Program
-- no lexer declaration
%monad { Err } { thenM } { returnM }
%tokentype {Token}
%token
  '(' { PT _ (TS _ 1) }
  ')' { PT _ (TS _ 2) }
  '++' { PT _ (TS _ 3) }
  ',' { PT _ (TS _ 4) }
  '--' { PT _ (TS _ 5) }
  ';' { PT _ (TS _ 6) }
  '=' { PT _ (TS _ 7) }
  'boolean' { PT _ (TS _ 8) }
  'false' { PT _ (TS _ 9) }
  'int' { PT _ (TS _ 10) }
  'string' { PT _ (TS _ 11) }
  'true' { PT _ (TS _ 12) }
  'void' { PT _ (TS _ 13) }

L_integ  { PT _ (TI $$) }
L_quoted { PT _ (TL $$) }
L_POpenBlock { PT _ (T_POpenBlock _) }
L_PCloseBlock { PT _ (T_PCloseBlock _) }
L_PIf { PT _ (T_PIf _) }
L_PElse { PT _ (T_PElse _) }
L_PWhile { PT _ (T_PWhile _) }
L_PReturn { PT _ (T_PReturn _) }
L_PTrue { PT _ (T_PTrue _) }
L_PFalse { PT _ (T_PFalse _) }
L_PEQU { PT _ (T_PEQU _) }
L_PLE { PT _ (T_PLE _) }
L_PGE { PT _ (T_PGE _) }
L_PNE { PT _ (T_PNE _) }
L_PAnd { PT _ (T_PAnd _) }
L_POr { PT _ (T_POr _) }
L_PMinus { PT _ (T_PMinus _) }
L_PNot { PT _ (T_PNot _) }
L_PPlus { PT _ (T_PPlus _) }
L_PTimes { PT _ (T_PTimes _) }
L_PDiv { PT _ (T_PDiv _) }
L_PMod { PT _ (T_PMod _) }
L_PLTH { PT _ (T_PLTH _) }
L_PGTH { PT _ (T_PGTH _) }
L_PIdent { PT _ (T_PIdent _) }


%%

Integer :: { Integer } : L_integ  { (read ( $1)) :: Integer }
String  :: { String }  : L_quoted {  $1 }
POpenBlock    :: { POpenBlock} : L_POpenBlock { POpenBlock (mkPosToken $1)}
PCloseBlock    :: { PCloseBlock} : L_PCloseBlock { PCloseBlock (mkPosToken $1)}
PIf    :: { PIf} : L_PIf { PIf (mkPosToken $1)}
PElse    :: { PElse} : L_PElse { PElse (mkPosToken $1)}
PWhile    :: { PWhile} : L_PWhile { PWhile (mkPosToken $1)}
PReturn    :: { PReturn} : L_PReturn { PReturn (mkPosToken $1)}
PTrue    :: { PTrue} : L_PTrue { PTrue (mkPosToken $1)}
PFalse    :: { PFalse} : L_PFalse { PFalse (mkPosToken $1)}
PEQU    :: { PEQU} : L_PEQU { PEQU (mkPosToken $1)}
PLE    :: { PLE} : L_PLE { PLE (mkPosToken $1)}
PGE    :: { PGE} : L_PGE { PGE (mkPosToken $1)}
PNE    :: { PNE} : L_PNE { PNE (mkPosToken $1)}
PAnd    :: { PAnd} : L_PAnd { PAnd (mkPosToken $1)}
POr    :: { POr} : L_POr { POr (mkPosToken $1)}
PMinus    :: { PMinus} : L_PMinus { PMinus (mkPosToken $1)}
PNot    :: { PNot} : L_PNot { PNot (mkPosToken $1)}
PPlus    :: { PPlus} : L_PPlus { PPlus (mkPosToken $1)}
PTimes    :: { PTimes} : L_PTimes { PTimes (mkPosToken $1)}
PDiv    :: { PDiv} : L_PDiv { PDiv (mkPosToken $1)}
PMod    :: { PMod} : L_PMod { PMod (mkPosToken $1)}
PLTH    :: { PLTH} : L_PLTH { PLTH (mkPosToken $1)}
PGTH    :: { PGTH} : L_PGTH { PGTH (mkPosToken $1)}
PIdent    :: { PIdent} : L_PIdent { PIdent (mkPosToken $1)}

Program :: { Program }
Program : ListTopDef { AbsLatte.Program $1 }
TopDef :: { TopDef }
TopDef : Type PIdent '(' ListArg ')' Block { AbsLatte.FnDef $1 $2 $4 $6 }
ListTopDef :: { [TopDef] }
ListTopDef : TopDef { (:[]) $1 } | TopDef ListTopDef { (:) $1 $2 }
Arg :: { Arg }
Arg : Type PIdent { AbsLatte.Arg $1 $2 }
ListArg :: { [Arg] }
ListArg : {- empty -} { [] }
        | Arg { (:[]) $1 }
        | Arg ',' ListArg { (:) $1 $3 }
Block :: { Block }
Block : POpenBlock ListStmt PCloseBlock { AbsLatte.Block $1 (reverse $2) $3 }
ListStmt :: { [Stmt] }
ListStmt : {- empty -} { [] } | ListStmt Stmt { flip (:) $1 $2 }
Stmt :: { Stmt }
Stmt : ';' { AbsLatte.Empty }
     | Block { AbsLatte.BStmt $1 }
     | Type ListItem ';' { AbsLatte.Decl $1 $2 }
     | PIdent '=' Expr ';' { AbsLatte.Ass $1 $3 }
     | PIdent '++' ';' { AbsLatte.Incr $1 }
     | PIdent '--' ';' { AbsLatte.Decr $1 }
     | PReturn Expr ';' { AbsLatte.Ret $1 $2 }
     | PReturn ';' { AbsLatte.VRet $1 }
     | PIf '(' Expr ')' Stmt { AbsLatte.Cond $1 $3 $5 }
     | PIf '(' Expr ')' Stmt PElse Stmt { AbsLatte.CondElse $1 $3 $5 $6 $7 }
     | PWhile '(' Expr ')' Stmt { AbsLatte.While $1 $3 $5 }
     | Expr ';' { AbsLatte.SExp $1 }
Item :: { Item }
Item : PIdent { AbsLatte.NoInit $1 }
     | PIdent '=' Expr { AbsLatte.Init $1 $3 }
ListItem :: { [Item] }
ListItem : Item { (:[]) $1 } | Item ',' ListItem { (:) $1 $3 }
Type :: { Type }
Type : 'int' { AbsLatte.Int }
     | 'string' { AbsLatte.Str }
     | 'boolean' { AbsLatte.Bool }
     | 'void' { AbsLatte.Void }
ListType :: { [Type] }
ListType : {- empty -} { [] }
         | Type { (:[]) $1 }
         | Type ',' ListType { (:) $1 $3 }
Expr6 :: { Expr }
Expr6 : PIdent { AbsLatte.EVar $1 }
      | Integer { AbsLatte.ELitInt $1 }
      | 'true' { AbsLatte.ELitTrue }
      | 'false' { AbsLatte.ELitFalse }
      | PIdent '(' ListExpr ')' { AbsLatte.EApp $1 $3 }
      | String { AbsLatte.EString $1 }
      | '(' Expr ')' { $2 }
Expr5 :: { Expr }
Expr5 : PMinus Expr6 { AbsLatte.Neg $1 $2 }
      | PNot Expr6 { AbsLatte.Not $1 $2 }
      | Expr6 { $1 }
Expr4 :: { Expr }
Expr4 : Expr4 MulOp Expr5 { AbsLatte.EMul $1 $2 $3 } | Expr5 { $1 }
Expr3 :: { Expr }
Expr3 : Expr3 AddOp Expr4 { AbsLatte.EAdd $1 $2 $3 } | Expr4 { $1 }
Expr2 :: { Expr }
Expr2 : Expr2 RelOp Expr3 { AbsLatte.ERel $1 $2 $3 } | Expr3 { $1 }
Expr1 :: { Expr }
Expr1 : Expr2 PAnd Expr1 { AbsLatte.EAnd $1 $2 $3 } | Expr2 { $1 }
Expr :: { Expr }
Expr : Expr1 POr Expr { AbsLatte.EOr $1 $2 $3 } | Expr1 { $1 }
ListExpr :: { [Expr] }
ListExpr : {- empty -} { [] }
         | Expr { (:[]) $1 }
         | Expr ',' ListExpr { (:) $1 $3 }
AddOp :: { AddOp }
AddOp : PPlus { AbsLatte.Plus $1 } | PMinus { AbsLatte.Minus $1 }
MulOp :: { MulOp }
MulOp : PTimes { AbsLatte.Times $1 }
      | PDiv { AbsLatte.Div $1 }
      | PMod { AbsLatte.Mod $1 }
RelOp :: { RelOp }
RelOp : PLTH { AbsLatte.LTH $1 }
      | PLE { AbsLatte.LE $1 }
      | PGTH { AbsLatte.GTH $1 }
      | PGE { AbsLatte.GE $1 }
      | PEQU { AbsLatte.EQU $1 }
      | PNE { AbsLatte.NE $1 }
{

returnM :: a -> Err a
returnM = return

thenM :: Err a -> (a -> Err b) -> Err b
thenM = (>>=)

happyError :: [Token] -> Err a
happyError ts =
  Bad $ "syntax error at " ++ tokenPos ts ++ 
  case ts of
    [] -> []
    [Err _] -> " due to lexer error"
    _ -> " before " ++ unwords (map (id . prToken) (take 4 ts))

myLexer = tokens
}

