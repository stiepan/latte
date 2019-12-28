module SkelLatte where

-- Haskell module generated by the BNF converter

import AbsLatte
import ErrM
type Result = Err String

failure :: Show a => a -> Result
failure x = Bad $ "Undefined case: " ++ show x

transPOpenBlock :: POpenBlock -> Result
transPOpenBlock x = case x of
  POpenBlock string -> failure x
transPCloseBlock :: PCloseBlock -> Result
transPCloseBlock x = case x of
  PCloseBlock string -> failure x
transPIf :: PIf -> Result
transPIf x = case x of
  PIf string -> failure x
transPElse :: PElse -> Result
transPElse x = case x of
  PElse string -> failure x
transPWhile :: PWhile -> Result
transPWhile x = case x of
  PWhile string -> failure x
transPReturn :: PReturn -> Result
transPReturn x = case x of
  PReturn string -> failure x
transPTrue :: PTrue -> Result
transPTrue x = case x of
  PTrue string -> failure x
transPFalse :: PFalse -> Result
transPFalse x = case x of
  PFalse string -> failure x
transPEQU :: PEQU -> Result
transPEQU x = case x of
  PEQU string -> failure x
transPLE :: PLE -> Result
transPLE x = case x of
  PLE string -> failure x
transPGE :: PGE -> Result
transPGE x = case x of
  PGE string -> failure x
transPNE :: PNE -> Result
transPNE x = case x of
  PNE string -> failure x
transPAnd :: PAnd -> Result
transPAnd x = case x of
  PAnd string -> failure x
transPOr :: POr -> Result
transPOr x = case x of
  POr string -> failure x
transPMinus :: PMinus -> Result
transPMinus x = case x of
  PMinus string -> failure x
transPNot :: PNot -> Result
transPNot x = case x of
  PNot string -> failure x
transPPlus :: PPlus -> Result
transPPlus x = case x of
  PPlus string -> failure x
transPTimes :: PTimes -> Result
transPTimes x = case x of
  PTimes string -> failure x
transPDiv :: PDiv -> Result
transPDiv x = case x of
  PDiv string -> failure x
transPMod :: PMod -> Result
transPMod x = case x of
  PMod string -> failure x
transPLTH :: PLTH -> Result
transPLTH x = case x of
  PLTH string -> failure x
transPGTH :: PGTH -> Result
transPGTH x = case x of
  PGTH string -> failure x
transPIdent :: PIdent -> Result
transPIdent x = case x of
  PIdent string -> failure x
transProgram :: Program -> Result
transProgram x = case x of
  Program topdefs -> failure x
transTopDef :: TopDef -> Result
transTopDef x = case x of
  FnDef type_ pident args block -> failure x
transArg :: Arg -> Result
transArg x = case x of
  Arg type_ pident -> failure x
transBlock :: Block -> Result
transBlock x = case x of
  Block popenblock stmts pcloseblock -> failure x
transStmt :: Stmt -> Result
transStmt x = case x of
  Empty -> failure x
  BStmt block -> failure x
  Decl type_ items -> failure x
  Ass pident expr -> failure x
  Incr pident -> failure x
  Decr pident -> failure x
  Ret preturn expr -> failure x
  VRet preturn -> failure x
  Cond pif expr stmt -> failure x
  CondElse pif expr stmt1 pelse stmt2 -> failure x
  While pwhile expr stmt -> failure x
  SExp expr -> failure x
transItem :: Item -> Result
transItem x = case x of
  NoInit pident -> failure x
  Init pident expr -> failure x
transType :: Type -> Result
transType x = case x of
  Int -> failure x
  Str -> failure x
  Bool -> failure x
  Void -> failure x
  Fun type_ types -> failure x
transExpr :: Expr -> Result
transExpr x = case x of
  EVar pident -> failure x
  ELitInt integer -> failure x
  ELitTrue -> failure x
  ELitFalse -> failure x
  EApp pident exprs -> failure x
  EString string -> failure x
  Neg pminus expr -> failure x
  Not pnot expr -> failure x
  EMul expr1 mulop expr2 -> failure x
  EAdd expr1 addop expr2 -> failure x
  ERel expr1 relop expr2 -> failure x
  EAnd expr1 pand expr2 -> failure x
  EOr expr1 por expr2 -> failure x
transAddOp :: AddOp -> Result
transAddOp x = case x of
  Plus pplus -> failure x
  Minus pminus -> failure x
transMulOp :: MulOp -> Result
transMulOp x = case x of
  Times ptimes -> failure x
  Div pdiv -> failure x
  Mod pmod -> failure x
transRelOp :: RelOp -> Result
transRelOp x = case x of
  LTH plth -> failure x
  LE ple -> failure x
  GTH pgth -> failure x
  GE pge -> failure x
  EQU pequ -> failure x
  NE pne -> failure x
