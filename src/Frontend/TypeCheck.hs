module Frontend.TypeCheck where

import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import Control.Monad.Trans.Class
import Control.Monad.Trans.State
import Control.Monad.Trans.Except
import Data.Functor.Identity
import AbsLatte
import Frontend.Error
import Common.Ident
import Frontend.Show


data Context = Context {
  -- maps variables names to their types in the current context
  bindings :: Map.Map Ident Type,
  blockVars :: Map.Map Ident Position,
  activeProc :: Maybe Type
}


type Verification = ExceptT SemanticError (StateT Context Identity)


check :: Program -> Either SemanticError Program
check program = evalState (runExceptT (checkP program)) emptyContext
  where
    emptyContext = Context predefined Map.empty Nothing
    predefined = Map.fromList [
        (Ident "printInt", Fun Void [Int]),
        (Ident "printString", Fun Void [Str]),
        (Ident "error", Fun Void []),
        (Ident "readInt", Fun Int []),
        (Ident "readString", Fun Str [])
      ]


checkP :: Program -> Verification Program
checkP (Program ts) = do
  collectTopDefinitions ts
  assertMainProcedure
  oTs <- mapM checkTD ts
  return $ Program oTs


checkTD :: TopDef -> Verification TopDef
checkTD (FnDef rType pIdent args (Block oBracket stmts cBracket)) = do
  context <- lift get
  let (ident, _) = pIdent2Ident pIdent
  startNewBlock $ Just $ (bindings context) Map.! ident
  mapM_ declareArgument args
  oStmts <- mapM checkS stmts
  lift $ put context
  return $ FnDef rType pIdent args (Block oBracket oStmts cBracket)


checkB :: Block -> Verification Block
checkB (Block oBracket stmts cBracket) = do
  context <- lift get
  startNewBlock (activeProc context)
  oStmts <- mapM checkS stmts
  lift $ put context
  return $ Block oBracket oStmts cBracket


checkS :: Stmt -> Verification Stmt
checkS empty@Empty = return empty

checkS (BStmt block) = do
  oBlock <- checkB block
  return $ BStmt block

checkS (Decl vType items) = do
  oItems <- mapM (declareVariable vType) items
  return $ Decl vType oItems

checkS (Ass pIdent exp) = do
  (vType, _) <- typeof $ EVar pIdent
  oExp <- assertTypeUnary vType (snd (pIdent2Ident pIdent)) exp
  return $ Ass pIdent oExp

checkS inc@(Incr pIdent) = do
  assertTypeUnary Int (snd (pIdent2Ident pIdent)) (EVar pIdent)
  return inc

checkS dec@(Decr pIdent) = do
  assertTypeUnary Int (snd (pIdent2Ident pIdent)) (EVar pIdent)
  return dec

checkS (Ret pRet@(PReturn (pos, _)) exp) = do
  (rType, oExp) <- typeof exp
  assertActiveProc (p2Pos pos) rType
  return $ Ret pRet oExp

checkS vRet@(VRet (PReturn (pos, _))) = do
  assertActiveProc (p2Pos pos) Void
  return vRet

checkS (Cond pIf@(PIf (pos, _)) exp stmt) = do
  oExp <- assertTypeUnary Bool (p2Pos pos) exp
  oStmt <- checkS stmt
  return $ Cond pIf oExp oStmt

checkS (CondElse pIf@(PIf (pos, _)) exp stmtIf pElse stmtElse) = do
  oExp <- assertTypeUnary Bool (p2Pos pos) exp
  oStmtIf <- checkS stmtIf
  oStmtElse <- checkS stmtElse
  return $ CondElse pIf oExp oStmtIf pElse oStmtElse

checkS (While pWhile@(PWhile (pos, _)) exp stmt) = do
  oExp <- assertTypeUnary Bool (p2Pos pos) exp
  oStmt <- checkS stmt
  return $ While pWhile oExp oStmt

checkS (SExp exp) = do
  (_, oExp) <- typeof exp
  return $ SExp oExp


collectTopDefinitions :: [TopDef] -> Verification ()
collectTopDefinitions = mapM_ declareProcedure


assertMainProcedure :: Verification ()
assertMainProcedure = do
  context <- lift get
  case (Ident "main") `Map.lookup` (bindings context) of
    Nothing -> throwE MainNotFound
    Just mType ->
      if mType /= Fun Int [] then
        throwE $ MainSignatureMismatch mType
      else
        return ()


assertActiveProc :: Position -> Type -> Verification ()
assertActiveProc pos eType = do
  context <- lift get
  case activeProc context of
    Nothing -> throwE $ ReturnOutsideProcedure pos
    Just activeProc -> case activeProc of
      Fun rType _ ->
        if rType /= eType then
          throwE $ ReturnTypeMismatch rType eType pos
        else
          return ()
      _ -> throwE $ InternalError "Active proc type should be functional" pos


startNewBlock :: Maybe Type -> Verification ()
startNewBlock activeProc = do
  context <- lift get
  lift $ put $ Context (bindings context) (Map.empty) activeProc


declareVariable :: Type -> Item -> Verification Item
declareVariable vType item@(NoInit pIdent) = do
  declare vType pIdent
  return item

declareVariable vType (Init pIdent exp) = do
  oExp <- assertTypeUnary vType (snd (pIdent2Ident pIdent)) exp
  declare vType pIdent
  return $ Init pIdent oExp


declareArgument :: Arg -> Verification ()
declareArgument (Arg vType pIdent) = declare vType pIdent


declareProcedure :: TopDef -> Verification ()
declareProcedure (FnDef rType pIdent args _) = do
  declare fType pIdent
  where
    fType = Fun rType aTypes
    aTypes = map (\(Arg aType _) -> aType) args


declare :: Type -> PIdent -> Verification ()
declare vType pIdent = do
  assertTypeAllowed vType position
  context <- lift get
  let locals = blockVars context
  case ident `Map.lookup` locals of
      Just prevPos -> throwE $ NamesCollision ident position prevPos
      Nothing -> do
        let newLocals = Map.insert ident position locals
        let newBindings = Map.insert ident vType (bindings context)
        lift $ put $ Context newBindings newLocals $ activeProc context
  where
    (ident, position) = pIdent2Ident pIdent


assertTypeAllowed :: Type -> Position -> Verification ()
assertTypeAllowed Void pos = throwE $ InvalidTypeInThisContext Void pos
assertTypeAllowed _ _ = return ()


boundType :: PIdent -> Verification Type
boundType pIdent = do
  context <- lift get
  let (ident, position) = pIdent2Ident pIdent
  case ident `Map.lookup` (bindings context) of
    Nothing -> throwE $ UndefinedIdent ident position
    Just vType -> return vType


typeof :: Expr -> Verification (Type, Expr)
typeof var@(EVar pIdent) = do
  vType <- boundType pIdent
  return (vType, var)

typeof lit@(ELitInt _) = return (Int, lit)

typeof lit@ELitTrue = return (Bool, lit)

typeof lit@ELitFalse = return (Bool, lit)

typeof lit@(EString _) = return (Str, lit)

typeof (Neg pMinus@(PMinus (pos, _)) exp) = do
  oExp <- assertTypeUnary Int (p2Pos pos) exp
  return (Int, Neg pMinus oExp)

typeof (Not pNot@(PNot (pos, _)) exp) = do
  oExp <- assertTypeUnary Bool (p2Pos pos) exp
  return (Bool, Not pNot oExp)

typeof (EAnd lExp pAnd@(PAnd (pos, _)) rExp) = do
  oLExp <- assertTypeUnary Bool (p2Pos pos) lExp `catchE` repackageUT UnexpectedTypeLeftOperand
  oRExp <- assertTypeUnary Bool (p2Pos pos) rExp `catchE` repackageUT UnexpectedTypeRightOperand
  return (Bool, EAnd oLExp pAnd oRExp)

typeof (EOr lExp pOr@(POr (pos, _)) rExp) = do
  oLExp <- assertTypeUnary Bool (p2Pos pos) lExp `catchE` repackageUT UnexpectedTypeLeftOperand
  oRExp <- assertTypeUnary Bool (p2Pos pos) rExp `catchE` repackageUT UnexpectedTypeRightOperand
  return (Bool, EOr oLExp pOr oRExp)

typeof (EMul lExp mulOp rExp) = do
  let pos = mulOpPosition mulOp
  oLExp <- assertTypeUnary Int pos lExp `catchE` repackageUT UnexpectedTypeLeftOperand
  oRExp <- assertTypeUnary Int pos rExp `catchE` repackageUT UnexpectedTypeRightOperand
  return (Int, EMul oLExp mulOp oRExp)

typeof (EAdd lExp addOp rExp) =
  case addOp of
    Plus pPlus -> do
      (lType, oLExp) <- typeof lExp
      if not $ lType `elem` [Int, Str] then
        throwE $ InvalidTypeInThisContext lType pos
      else do
        oRExp <- assertTypeUnary lType pos rExp
        return (lType, EAdd oLExp (OverloadedPlus lType pPlus) oRExp)
    _ -> do
      oLExp <- assertTypeUnary Int pos lExp `catchE` repackageUT UnexpectedTypeLeftOperand
      oRExp <- assertTypeUnary Int pos rExp `catchE` repackageUT UnexpectedTypeRightOperand
      return (Int, EAdd oLExp addOp oRExp)
  where
    pos = addOpPosition addOp

typeof (ERel lExp relOp rExp) =
  case relOp of
    EQU pEqu -> overloadRelOp ((flip OverloadedEQU) pEqu) pos lExp rExp
    NE pNe -> overloadRelOp ((flip OverloadedNE) pNe) pos lExp rExp
    _ -> do
      oLExp <- assertTypeUnary Int pos lExp `catchE` repackageUT UnexpectedTypeLeftOperand
      oRExp <- assertTypeUnary Int pos rExp `catchE` repackageUT UnexpectedTypeRightOperand
      return (Bool, ERel oLExp relOp oRExp)
  where
    pos = relOpPosition relOp

typeof (EApp pIdent args) = do
  vType <- (boundType pIdent) `catchE` handleUnboundName
  case vType of
    Fun rType aTypes ->
      if length aTypes /= length args then
        throwE $ InvalidNumberOfArguments ident position
      else do
        oArgs <- mapM matchArgumentType (zip3 [1..] aTypes args)
        return (rType, EApp pIdent oArgs)
    _ -> throwE $ NotCallable ident position
  where
    handleUnboundName (UndefinedIdent ident pos) = throwE $ UndefinedProcIdent ident pos
    handleUnboundName e = throwE e

    (ident, position) = pIdent2Ident pIdent

    matchArgumentType :: (Int, Type, Expr) -> Verification Expr
    matchArgumentType (ith, vType, exp) = do
      (eType, oExp) <- typeof exp
      if eType /= vType then
        throwE $ ArgumentTypeMismatch ident position ith vType eType
      else
        return oExp


assertTypeUnary :: Type -> Position -> Expr -> Verification Expr
assertTypeUnary aType pos exp = do
  (eType, oExp) <- typeof exp
  if eType /= aType then
    throwE $ UnexpectedType aType eType pos
  else
    return oExp


overloadRelOp :: (Type -> RelOp) -> Position -> Expr -> Expr -> Verification (Type, Expr)
overloadRelOp relOpC pos lExp rExp = do
  (lType, oLExp) <- typeof lExp
  assertTypeAllowed lType pos
  (rType, oRExp) <- typeof rExp
  if lType == rType then
    return (Bool, ERel oLExp (relOpC lType) oRExp)
  else
    throwE $ UnexpectedType lType rType pos


repackageUT :: (Type -> Type -> Position -> SemanticError) -> SemanticError -> Verification a
repackageUT nConstr (UnexpectedType eT aT pos) = throwE $ nConstr eT aT pos
repackageUT _ e = throwE e


mulOpPosition :: MulOp -> Position
mulOpPosition (Times (PTimes (pos, _))) = p2Pos pos
mulOpPosition (Div (PDiv (pos, _))) = p2Pos pos
mulOpPosition (Mod (PMod (pos, _))) = p2Pos pos


addOpPosition :: AddOp -> Position
addOpPosition (Plus (PPlus (pos, _))) = p2Pos pos
addOpPosition (OverloadedPlus _ pPlus) = addOpPosition $ Plus pPlus
addOpPosition (Minus (PMinus (pos, _))) = p2Pos pos


relOpPosition :: RelOp -> Position
relOpPosition (LTH (PLTH (pos, _))) = p2Pos pos
relOpPosition (LE (PLE (pos, _))) = p2Pos pos
relOpPosition (GTH (PGTH (pos, _))) = p2Pos pos
relOpPosition (GE (PGE (pos, _))) = p2Pos pos
relOpPosition (EQU (PEQU (pos, _))) = p2Pos pos
relOpPosition (OverloadedEQU _ pEqu) = relOpPosition $ EQU pEqu
relOpPosition (NE (PNE (pos, _))) = p2Pos pos
relOpPosition (OverloadedNE _ pNe) = relOpPosition $ NE pNe
