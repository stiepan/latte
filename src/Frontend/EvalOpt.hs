module Frontend.EvalOpt where

import Control.Monad.Trans.Except
import Data.Functor.Identity

import Frontend.Error
import Frontend.Common
import AbsLatte


type Simplification = ExceptT SemanticError Identity


optimizeByEval :: Program -> Either SemanticError Program
optimizeByEval p = runExcept (simplifyProgram p)


simplifyProgram :: Program -> Simplification Program
simplifyProgram (Program ts) = do
  sTD <- mapM simplifyTD ts
  return $ Program sTD


simplifyTD :: TopDef -> Simplification TopDef
simplifyTD (FnDef rType pIdent args block) = do
  sBlock <- simplifyB block
  return $ FnDef rType pIdent args sBlock


simplifyB :: Block -> Simplification Block
simplifyB (Block oBracket stmts cBracket) = do
  sStmts <- mapM simplifyS stmts
  let mSStmts = filter (Empty /=) sStmts
  return $ Block oBracket mSStmts cBracket


simplifyI :: Item -> Simplification Item
simplifyI (Init pIdent exp) = do
  sExp <- simplifyE exp
  return $ Init pIdent sExp

simplifyI item = return item


simplifyS :: Stmt -> Simplification Stmt

simplifyS (BStmt block) = do
  sBlock <- simplifyB block
  return $ BStmt sBlock

simplifyS (Decl vType items) = do
  sItems <- mapM simplifyI items
  return $ Decl vType sItems

simplifyS (Ass pIdent exp) = do
  sExp <- simplifyE exp
  return $ Ass pIdent sExp

simplifyS (Ret pReturn exp) = do
  sExp <- simplifyE exp
  return $ Ret pReturn sExp

simplifyS (Cond pIf exp stmt) = do
  sExp <- simplifyE exp
  sStmt <- simplifyS stmt
  return $ case sExp of
    ELitFalse -> Empty
    ELitTrue -> sStmt
    _ -> Cond pIf sExp sStmt

simplifyS (CondElse pIf exp ifStmt pElse elStmt) = do
  sExp <- simplifyE exp
  sIfStmt <- simplifyS ifStmt
  sElStmt <- simplifyS elStmt
  return $ case sExp of
    ELitFalse -> elStmt
    ELitTrue -> ifStmt
    _ -> CondElse pIf sExp sIfStmt pElse sElStmt

simplifyS (While pWhile exp stmt) = do
  sExp <- simplifyE exp
  sStmt <- simplifyS stmt
  return $ case sExp of
   ELitFalse -> Empty
   _ -> While pWhile sExp sStmt

simplifyS (SExp exp) = do
  sExp <- simplifyE exp
  return $ SExp sExp

simplifyS stmt = return stmt


simplifyE :: Expr -> Simplification Expr
simplifyE app@(EApp pIdent args) = do
  sArgs <- mapM simplifyE args
  return $ EApp pIdent sArgs

simplifyE (Not pos exp) = do
  sExp <- simplifyE exp
  return $ case sExp of
    ELitTrue -> ELitFalse
    ELitFalse -> ELitTrue
    exp -> Not pos exp

simplifyE (EAnd expL pAnd expR) = do
  sExpL <- simplifyE expL
  sExpR <- simplifyE expR
  return $ case (sExpL, sExpR) of
    (ELitFalse, _) -> ELitFalse
    (_, ELitFalse) -> ELitFalse
    (ELitTrue, _) -> sExpR
    (_, ELitTrue) -> sExpL
    (_, _) -> EAnd sExpL pAnd sExpR

simplifyE (EOr expL pOr expR) = do
  sExpL <- simplifyE expL
  sExpR <- simplifyE expR
  return $ case (sExpL, sExpR) of
    (ELitTrue, _) -> ELitTrue
    (_, ELitTrue) -> ELitTrue
    (ELitFalse, _) -> sExpR
    (_, ELitFalse) -> sExpL
    (_, _) -> EOr sExpL pOr sExpR

simplifyE (Neg pos exp) = do
  sExp <- simplifyE exp
  return $ case sExp of
    ELitInt n -> ELitInt (-n)
    exp -> Neg pos exp

simplifyE (EMul expL mulOp expR) = do
  sExpL <- simplifyE expL
  sExpR <- simplifyE expR
  case (sExpL, sExpR) of
    (ELitInt n, ELitInt m) -> iPerformMulOp mulOp n m
    (_, _) -> return (EMul sExpL mulOp sExpR)

simplifyE (EAdd expL addOp expR) = do
  sExpL <- simplifyE expL
  sExpR <- simplifyE expR
  case (sExpL, sExpR) of
    (ELitInt n, ELitInt m) -> iPerformAddOp addOp n m
    (EString ls, EString rs) -> return $ EString $ ls ++ rs
    (_, _) -> return $ EAdd sExpL addOp sExpR

simplifyE (ERel expL relOp expR) = do
  sExpL <- simplifyE expL
  sExpR <- simplifyE expR
  let innerSimplified = ERel sExpL relOp sExpR
  return $ case (sExpL, sExpR) of
    (ELitInt n, ELitInt m) -> if n == m then ELitTrue else ELitFalse
    (EString ls, EString rs) -> if ls == rs then ELitTrue else ELitFalse
    (ELitTrue, ELitTrue) -> ELitTrue
    (ELitFalse, ELitFalse) -> ELitTrue
    (ELitFalse, ELitTrue) -> ELitFalse
    (ELitTrue, ELitFalse) -> ELitFalse
    (EVar (PIdent (_, lName)), EVar (PIdent (_, rName))) ->
      if lName == rName then
        ELitTrue
      else
        innerSimplified
    (_, _) -> innerSimplified

simplifyE exp = return exp


iPerformMulOp :: MulOp -> Integer -> Integer -> Simplification Expr
iPerformMulOp (Times _) n m = return $ ELitInt $ n * m

iPerformMulOp (Div (PDiv (pos, _))) n m =
  if m == 0 then
    throwE $ DivisionByZero (p2Pos pos)
  else
    return $ ELitInt $ n `div` m

iPerformMulOp (Mod (PMod (pos, _))) n m =
  if m == 0 then
    throwE $ DivisionByZero (p2Pos pos)
  else
    return $ ELitInt $ n `mod` m


iPerformAddOp :: AddOp -> Integer -> Integer -> Simplification Expr
iPerformAddOp (Plus (PPlus (pos, _))) n m = return $ ELitInt $ n + m

iPerformAddOp (Minus (PMinus (pos, _))) n m = return $ ELitInt $ n - m