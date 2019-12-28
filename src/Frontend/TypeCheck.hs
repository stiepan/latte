module Frontend.TypeCheck where

import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import Control.Monad.Trans.Class
import Control.Monad.Trans.State
import Control.Monad.Trans.Except
import Data.Functor.Identity
import AbsLatte
import Frontend.Error
import Frontend.Common


data Context = Context {
  -- maps variables names to their types in the current context
  bindings :: Map.Map Ident Type,
  blockVars :: Map.Map Ident Position,
  activeProc :: Maybe Type
}


type Verification = ExceptT SemanticError (StateT Context Identity)


check :: Program -> Either SemanticError ()
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


checkP :: Program -> Verification ()
checkP (Program ts) = do
  collectTopDefinitions ts
  assertMainProcedure
  mapM_ checkTD ts


checkTD :: TopDef -> Verification ()
checkTD (FnDef _ pIdent args (Block _ stmts _)) = do
  context <- lift get
  let (ident, _) = pIdent2Ident pIdent
  startNewBlock $ Just $ (bindings context) Map.! ident
  mapM_ declareArgument args
  mapM_ checkS stmts
  lift $ put context


checkB :: Block -> Verification ()
checkB (Block _ stmts _) = do
  context <- lift get
  startNewBlock (activeProc context)
  mapM_ checkS stmts
  lift $ put context


checkS :: Stmt -> Verification ()
checkS Empty = return ()

checkS (BStmt block) = checkB block

checkS (Decl vType items) = mapM_ (declareVariable vType) items

checkS (Ass pIdent exp) = do
  vType <- typeof (EVar pIdent)
  assertTypeUnary vType (snd (pIdent2Ident pIdent)) exp
  return ()

checkS (Incr pIdent) = do
  assertTypeUnary Int (snd (pIdent2Ident pIdent)) (EVar pIdent)
  return ()

checkS (Decr pIdent) = do
  assertTypeUnary Int (snd (pIdent2Ident pIdent)) (EVar pIdent)
  return ()

checkS (Ret (PReturn (pos, _)) exp) = do
  rType <- typeof exp
  assertActiveProc (p2Pos pos) rType

checkS (VRet (PReturn (pos, _))) = assertActiveProc (p2Pos pos) Void

checkS (Cond (PIf (pos, _)) exp stmt) = do
  assertTypeUnary Bool (p2Pos pos) exp
  checkS stmt

checkS (CondElse pIf exp stmtIf _ stmtElse) = do
  checkS (Cond pIf exp stmtIf)
  checkS stmtElse

checkS (While (PWhile (pos, _)) exp stmt) = do
  assertTypeUnary Bool (p2Pos pos) exp
  checkS stmt

checkS (SExp exp) = do
  typeof exp
  return ()


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


declareVariable :: Type -> Item -> Verification ()
declareVariable vType (NoInit pIdent) = declare vType pIdent

declareVariable vType (Init pIdent exp) = do
  assertTypeUnary vType (snd (pIdent2Ident pIdent)) exp
  declare vType pIdent


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


typeof :: Expr -> Verification Type
typeof (EVar pIdent) = boundType pIdent

typeof (ELitInt _) = return Int

typeof ELitTrue = return Bool

typeof ELitFalse = return Bool

typeof (EString _) = return Str

typeof (Neg (PMinus (pos, _)) exp) =
  assertTypeUnary Int (p2Pos pos) exp

typeof (Not (PNot (pos, _)) exp) =
  assertTypeUnary Bool (p2Pos pos) exp

typeof (EAnd lExp (PAnd (pos, _)) rExp) = do
  (assertTypeUnary Bool (p2Pos pos) lExp) `catchE` (repackageUT UnexpectedTypeLeftOperand)
  (assertTypeUnary Bool (p2Pos pos) rExp) `catchE` (repackageUT UnexpectedTypeRightOperand)

typeof (EOr lExp (POr (pos, _)) rExp) = do
  (assertTypeUnary Bool (p2Pos pos) lExp) `catchE` (repackageUT UnexpectedTypeLeftOperand)
  (assertTypeUnary Bool (p2Pos pos) rExp) `catchE` (repackageUT UnexpectedTypeRightOperand)

typeof (EMul lExp mulOp rExp) = do
  let pos = mulOpPosition mulOp
  (assertTypeUnary Int pos lExp) `catchE` (repackageUT UnexpectedTypeLeftOperand)
  (assertTypeUnary Int pos rExp) `catchE` (repackageUT UnexpectedTypeRightOperand)

typeof (EAdd lExp addOp rExp) =
  case addOp of
    Plus _ -> do
      lType <- typeof lExp
      case lType of
        Int -> (assertTypeUnary Int pos rExp)
        Str -> (assertTypeUnary Str pos rExp)
        _ -> throwE $ InvalidTypeInThisContext lType pos
    _ -> do
      (assertTypeUnary Int pos lExp) `catchE` (repackageUT UnexpectedTypeLeftOperand)
      (assertTypeUnary Int pos rExp) `catchE` (repackageUT UnexpectedTypeRightOperand)
  where
    pos = addOpPosition addOp

typeof (ERel lExp relOp rExp) = do
  case relOp of
    EQU _ -> assertSameType pos lExp rExp
    NE _ -> assertSameType pos lExp rExp
    _ -> do
      (assertTypeUnary Int pos lExp) `catchE` (repackageUT UnexpectedTypeLeftOperand)
      (assertTypeUnary Int pos rExp) `catchE` (repackageUT UnexpectedTypeRightOperand)
  return Bool
  where
    pos = relOpPosition relOp

typeof (EApp pIdent args) = do
  context <- lift get
  vType <- (boundType pIdent) `catchE` handleUnboundName
  case vType of
    Fun rType aTypes ->
      if length aTypes /= length args then
        throwE $ InvalidNumberOfArguments ident position
      else do
        mapM_ matchArgumentType (zip3 [1..] aTypes args)
        return rType
    _ -> throwE $ NotCallable ident position
  where
    handleUnboundName (UndefinedIdent ident pos) = throwE $ UndefinedProcIdent ident pos
    handleUnboundName e = throwE e

    (ident, position) = pIdent2Ident pIdent

    matchArgumentType :: (Int, Type, Expr) -> Verification ()
    matchArgumentType (ith, vType, exp) = do
      eType <- typeof exp
      if eType /= vType then
        throwE $ ArgumentTypeMismatch ident position ith vType eType
      else
        return ()


assertTypeUnary :: Type -> Position -> Expr -> Verification Type
assertTypeUnary aType pos exp = do
  eType <- typeof exp
  if eType /= aType then
    throwE $ UnexpectedType aType eType pos
  else
    return aType


assertSameType :: Position -> Expr -> Expr -> Verification Type
assertSameType pos lExp rExp = do
  lType <- typeof lExp
  rType <- typeof rExp
  if lType == rType then
    return lType
  else
    throwE $ UnexpectedType lType rType pos


repackageUT :: (Type -> Type -> Position -> SemanticError) -> SemanticError -> Verification Type
repackageUT nConstr (UnexpectedType eT aT pos) = throwE $ nConstr eT aT pos
repackageUT _ e = throwE e


mulOpPosition :: MulOp -> Position
mulOpPosition (Times (PTimes (pos, _))) = p2Pos pos
mulOpPosition (Div (PDiv (pos, _))) = p2Pos pos
mulOpPosition (Mod (PMod (pos, _))) = p2Pos pos


addOpPosition :: AddOp -> Position
addOpPosition (Plus (PPlus (pos, _))) = p2Pos pos
addOpPosition (Minus (PMinus (pos, _))) = p2Pos pos


relOpPosition :: RelOp -> Position
relOpPosition (LTH (PLTH (pos, _))) = p2Pos pos
relOpPosition (LE (PLE (pos, _))) = p2Pos pos
relOpPosition (GTH (PGTH (pos, _))) = p2Pos pos
relOpPosition (GE (PGE (pos, _))) = p2Pos pos
relOpPosition (EQU (PEQU (pos, _))) = p2Pos pos
relOpPosition (NE (PNE (pos, _))) = p2Pos pos
