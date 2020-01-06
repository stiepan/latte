module LlvmBackend.Compile where

import qualified Data.Map.Strict as Map
import Control.Monad.Trans.Class
import Control.Monad.Trans.State
import Control.Monad.Trans.Writer
import Data.Functor.Identity

import Common.DList
import Common.Ident
import Common.Show

import qualified AbsLatte as Latte
import qualified LlvmBackend.Predefined as Predefined
import LlvmBackend.Llvm
import LlvmBackend.Optimize (essentialOpt)


type Statements = DList Statement
type Blocks = DList Block
type Functions = DList Function

data Env = Env {
  -- maps variables names to allocated registers
  bindings :: Map.Map Ident Var,
  strLiterals :: Map.Map String Var,
  localsCount :: Int
}

data CBlock = CBlock {
  getLabel :: Var,
  getStmts :: Statements
}

data CompState = CompState {
  getEnv :: Env,
  getCBlock :: CBlock
}


type FCompilation = WriterT Blocks (StateT CompState Identity)


type TopDefCompilation = WriterT Functions (StateT Env Identity)


getEnvM :: FCompilation Env
getEnvM = do
  state <- lift get
  return $ getEnv state


putEnvM :: Env -> FCompilation ()
putEnvM env = do
  state <- lift get
  lift $ put $ CompState env (getCBlock state)


getCBlockM :: FCompilation CBlock
getCBlockM = do
  state <- lift get
  return $ getCBlock state


putCBlockM :: CBlock -> FCompilation ()
putCBlockM cBlock = do
  state <- lift get
  lift $ put $ CompState (getEnv state) cBlock


flushBlock :: FCompilation ()
flushBlock = do
  cBlock <- getCBlockM
  case toList (getStmts cBlock) of
    [] -> return ()
    _ -> closeAndFlushBlock


closeAndFlushBlock :: FCompilation ()
closeAndFlushBlock = do
  emitS $ Return Nothing -- functions of void type in Latte don't have to
                         -- return explicitly, but they have to in llvm.
                         -- if block already returns something this will be removed
                         -- by *removeUnreachableCodeInBlock*
  cBlock <- getCBlockM
  tell $ singleton $ Block (var2Label (getLabel cBlock)) (toList (getStmts cBlock))
  label <- freshLabel
  putCBlockM $ CBlock label mempty


emitS :: Statement -> FCompilation ()
emitS s = do
  cBlock <- getCBlockM
  putCBlockM $ CBlock (getLabel cBlock) (getStmts cBlock <> singleton s)


freshBlock :: Var -> FCompilation ()
freshBlock label = do
  cBlock <- getCBlockM
  tell $ singleton $ Block (var2Label (getLabel cBlock)) (toList (getStmts cBlock))
  putCBlockM $ CBlock label mempty


freshLocalVar :: Type -> String -> FCompilation Var
freshLocalVar t p = do
  env <- getEnvM
  let rCount = localsCount env
  putEnvM $ Env (bindings env) (strLiterals env) (rCount + 1)
  return $ VLocal (p ++ (show rCount)) t

freshLocal :: Type -> FCompilation Var
freshLocal t = freshLocalVar t "t"

freshLabel :: FCompilation Var
freshLabel = freshLocalVar TLabel "l"


bindVar :: Ident -> Type -> FCompilation Var
bindVar ident t = do
  var <- freshLocal t
  env <- getEnvM
  let nBindings = (Map.insert ident var (bindings env))
  let nEnv = Env nBindings (strLiterals env) (localsCount env)
  putEnvM nEnv
  return var


getVar :: Ident -> FCompilation Var
getVar ident = do
  env <- getEnvM
  return $ (bindings env) Map.! ident


getStrLiteral :: String -> FCompilation Var
getStrLiteral s = do
  env <- getEnvM
  let literals = strLiterals env
  case Map.lookup s literals of
    Just var -> return var
    Nothing -> do
      putEnvM $ Env (bindings env) nLiterals (localsCount env)
      return gVar
      where
        nLiterals = Map.insert s gVar literals
        strName = ".str." ++ (show $ length literals)
        strType = TPtr $ TArray (toInteger (length s + 1)) (TInt 8)
        gVar = VGlobal $ GlobalVar strType strName


capture :: FCompilation a -> FCompilation (a, Blocks)
capture comp = do
  state <- lift get
  let ((res, blocks), nState) = runState (runWriterT comp) state
  lift $ put $ CompState (getEnv nState) (getCBlock state)
  return (res, blocks)


compile :: Latte.Program -> Module
compile (Latte.Program topDefs) =
  essentialOpt $ Module globalStrLiterals forwardDeclarations (toList functions)
  where
    forwardDeclarations = map toForwardFunDeclaration Predefined.envFunctions
    globalStrLiterals = map (uncurry toStrDefinition) $ Map.toList $ strLiterals env
    ((_, functions), env) = runState (runWriterT $ mapM_ compileTD topDefs) initialEnv
    predefinedBindings = map funAsBinding Predefined.envFunctions
    definedFunctions = map (funAsBinding.topDef2Var) topDefs
    initialEnv = Env (Map.fromList (predefinedBindings ++ definedFunctions)) Map.empty 1

    toStrDefinition :: String -> Var -> GlobalVarDef
    toStrDefinition literal (VGlobal gVar) = GConstDef Internal gVar (StaticStr literal)

    toForwardFunDeclaration :: Var -> Signature
    toForwardFunDeclaration (VGlobal (GlobalVar (TFunction sig) _)) = sig

    funAsBinding :: Var -> (Ident, Var)
    funAsBinding var@(VGlobal (GlobalVar _ fName)) = (Ident fName, var)


topDef2Var :: Latte.TopDef -> Var
topDef2Var td =
  VGlobal (GlobalVar (TFunction $ topDef2Sig td) (topDef2fName td))


topDef2fName :: Latte.TopDef -> String
topDef2fName (Latte.FnDef _ pIdent _ _) =
  let (Ident fName, _) = pIdent2Ident pIdent in fName


topDef2Sig :: Latte.TopDef -> Signature
topDef2Sig td@(Latte.FnDef rType pIdent args _) =
  Sig (topDef2fName td) (latT2Llvm rType) (map latT2Llvm argTypes) External
  where
    argTypes = map (\(Latte.Arg t _) -> t) args


latT2Llvm :: Latte.Type -> Type
latT2Llvm Latte.Int = Predefined.llvmInt
latT2Llvm Latte.Str = Predefined.llvmString
latT2Llvm Latte.Bool = Predefined.llvmBool
latT2Llvm Latte.Void = TVoid


var2Label :: Var -> Label
var2Label (VLocal name TLabel) = Label name


compileTD :: Latte.TopDef -> TopDefCompilation ()
compileTD td@(Latte.FnDef rType pIdent args block) = do
  env <- lift get
  let compState = CompState env (CBlock (VLocal "0" TLabel) mempty)
  let ((_, cBlocks), nCompState) = runState (runWriterT $ compileTDBlock args block) compState
  let nEnv = getEnv nCompState
  lift $ put $ Env (bindings env) (strLiterals nEnv) (localsCount env)
  tell $ singleton $ Func (topDef2Sig td) (map argName args) (toList cBlocks)
  where
    argName (Latte.Arg _ pIdent) = let (Ident name, _) = pIdent2Ident pIdent in name


compileTDBlock :: [Latte.Arg] -> Latte.Block -> FCompilation ()
compileTDBlock args block = do
  if length args > 0 then mapM_ compileArg args else return ()
  compileB block
  flushBlock
  -- todo what about blocks that have ret and br in the next line
  -- todo (remove unreachable code from blocks)


compileArg :: Latte.Arg -> FCompilation Var
compileArg (Latte.Arg t pIdent) = do
  let (Ident name, _) = pIdent2Ident pIdent
  let argType = latT2Llvm t
  lVar <- bindVar (Ident name) (TPtr argType)
  emitS $ Assigment lVar $ Alloca 1 argType
  emitS $ Store (VLocal name argType) lVar
  return lVar


compileB :: Latte.Block -> FCompilation ()
compileB (Latte.Block _ stmts _) = do
  env <- getEnvM
  mapM_ compileS stmts
  nEnv <- getEnvM
  putEnvM $ Env (bindings env) (strLiterals nEnv) (localsCount nEnv)


compileS :: Latte.Stmt -> FCompilation ()
compileS Latte.Empty = return ()

compileS (Latte.BStmt block) = compileB block

compileS (Latte.Decl t items) = mapM_ (compileSDecl t) items

compileS (Latte.Ass pIdent exp) = do
  rVar <- compileE exp
  lVar <- getVar $ fst $ pIdent2Ident pIdent
  emitS $ Store rVar lVar

compileS (Latte.Incr pIdent) = compileIncBy pIdent (LInt 32 1)

compileS (Latte.Decr pIdent) = compileIncBy pIdent (LInt 32 (-1))

compileS (Latte.Ret _ exp) = do
  rVar <- compileE exp
  emitS $ Return $ Just rVar

compileS (Latte.VRet _) = do
  emitS $ Return $ Nothing

compileS (Latte.SExp exp) = do
  rVar <- compileE exp
  return ()

compileS (Latte.Cond _ exp stmt) = do
  lTrue <- freshLabel
  lCont <- freshLabel
  compileBool exp lTrue lCont
  freshBlock lTrue
  compileS stmt
  emitS $ Branch lCont
  freshBlock lCont

compileS (Latte.CondElse _ exp tStmt _ fStmt) = do
  lTrue <- freshLabel
  lFalse <- freshLabel
  lCont <- freshLabel
  compileBool exp lTrue lFalse
  freshBlock lTrue
  compileS tStmt
  emitS $ Branch lCont
  freshBlock lFalse
  compileS fStmt
  emitS $ Branch lCont
  freshBlock lCont

compileS (Latte.While _ exp stmt) = do
  condLabel <- freshLabel
  bodyLabel <- freshLabel
  contLabel <- freshLabel
  emitS $ Branch condLabel
  freshBlock bodyLabel
  compileS stmt
  emitS $ Branch condLabel
  freshBlock condLabel
  compileBool exp bodyLabel contLabel
  freshBlock contLabel


compileIncBy :: Latte.PIdent -> Lit -> FCompilation ()
compileIncBy pIdent lit = do
  lVar <- getVar (let (ident, _) = pIdent2Ident pIdent in ident)
  t0 <- freshLocal Predefined.llvmInt
  emitS $ Assigment t0 $ Load lVar
  t1 <- freshLocal Predefined.llvmInt
  emitS $ Assigment t1 $ Op MO_Add t0 (VLit lit)
  emitS $ Store t1 lVar


compileSDecl :: Latte.Type -> Latte.Item -> FCompilation Var
compileSDecl t (Latte.NoInit pIdent) = compileSDecl t (Latte.Init pIdent (defaultExp t))
  where
    defaultExp Latte.Int = Latte.ELitInt 0
    defaultExp Latte.Bool = Latte.ELitFalse
    defaultExp Latte.Str = Latte.EString ""

compileSDecl t (Latte.Init pIdent exp) = do
  rVar <- compileE exp
  let argType = latT2Llvm t
  lVar <- bindVar (fst $ pIdent2Ident pIdent) (TPtr argType)
  emitS $ Assigment lVar $ Alloca 1 argType
  emitS $ Store rVar lVar
  return lVar


-- todo assure optimal order of expression computation
compileE :: Latte.Expr -> FCompilation Var
compileE (Latte.EVar pIdent) = do
  lVar <- getVar (let (ident, _) = pIdent2Ident pIdent in ident)
  t0 <- freshLocal (typeOfLVar lVar)
  emitS $ Assigment t0 $ Load lVar
  return t0

compileE (Latte.ELitInt n) = do
  return $ VLit $ LInt 32 n

compileE Latte.ELitTrue = do
  return $ VLit $ LInt 1 1

compileE Latte.ELitFalse = do
  return $ VLit $ LInt 1 0

compileE (Latte.EString s) = do
  rVal <- getStrLiteral s
  t0 <- freshLocal Predefined.llvmString
  emitS $ Assigment t0 $ GetElemPtr False rVal [VLit (LInt 32 0), VLit (LInt 32 0)]
  return t0

compileE (Latte.EApp pIdent exps) =
  compileFunCall (fst $ pIdent2Ident pIdent) exps

compileE (Latte.Neg _ exp) = do
  rVar <- compileE exp
  t0 <- freshLocal (Predefined.llvmInt)
  emitS $ Assigment t0 $ Op MO_Sub (VLit $ LInt 32 0) rVar
  return t0

compileE (Latte.EMul lExp op rExp) = compileAOp (mulOp op) lExp rExp
  where
    mulOp :: Latte.MulOp -> MachOp
    mulOp (Latte.Times _) = MO_Mul
    mulOp (Latte.Div _) = MO_SDiv
    mulOp (Latte.Mod _) = MO_SRem

compileE (Latte.EAdd lExp (Latte.Minus _) rExp) = compileAOp MO_Sub lExp rExp

compileE (Latte.EAdd lExp (Latte.OverloadedPlus Latte.Int _) rExp) =
  compileAOp MO_Add lExp rExp

compileE (Latte.EAdd lExp (Latte.OverloadedPlus Latte.Str _) rExp) =
  compileFunCall (nameOfFunction Predefined.internalConcat) [lExp, rExp]

compileE (Latte.ERel lExp (Latte.LTH _) rExp) = compileCmpOp CMP_Slt lExp rExp

compileE (Latte.ERel lExp (Latte.LE _) rExp) = compileCmpOp CMP_Sle lExp rExp

compileE (Latte.ERel lExp (Latte.GTH _) rExp) = compileCmpOp CMP_Sgt lExp rExp

compileE (Latte.ERel lExp (Latte.GE _) rExp) = compileCmpOp CMP_Sge lExp rExp

compileE (Latte.ERel lExp (Latte.OverloadedEQU Latte.Int _) rExp) =
  compileCmpOp CMP_Eq lExp rExp

compileE (Latte.ERel lExp (Latte.OverloadedEQU Latte.Bool _) rExp) =
  compileCmpOp CMP_Eq lExp rExp

compileE (Latte.ERel lExp (Latte.OverloadedEQU Latte.Str _) rExp) =
  compileFunCall (nameOfFunction Predefined.internalStringEq) [lExp, rExp]

compileE (Latte.ERel lExp (Latte.OverloadedNE Latte.Int _) rExp) =
  compileCmpOp CMP_Ne lExp rExp

compileE (Latte.ERel lExp (Latte.OverloadedNE Latte.Bool _) rExp) =
  compileCmpOp CMP_Ne lExp rExp

compileE (Latte.ERel lExp (Latte.OverloadedNE Latte.Str _) rExp) = do
  rVar <- compileFunCall (nameOfFunction Predefined.internalStringEq) [lExp, rExp]
  t0 <- freshLocal (Predefined.llvmBool)
  emitS $ Assigment t0 $ Op MO_Xor (VLit $ LInt 1 1) rVar
  return t0

compileE bExp@(Latte.EAnd _ _ _) = compileBExp bExp

compileE bExp@(Latte.EOr _ _ _) = compileBExp bExp

compileE bExp@(Latte.Not _ _) = compileBExp bExp


-- todo use capture to merge lTrue and LFalse blocks into one with bigger phi
compileBExp :: Latte.Expr -> FCompilation Var
compileBExp exp = do
  lTrue <- freshLabel
  lFalse <- freshLabel
  lCont <- freshLabel
  compileBool exp lTrue lFalse
  freshBlock lTrue
  emitS $ Branch lCont
  freshBlock lFalse
  emitS $ Branch lCont
  freshBlock lCont
  t0 <- freshLocal Predefined.llvmBool
  let phi = Phi (Predefined.llvmBool) [(VLit (LInt 1 1), lTrue), (VLit (LInt 1 0), lFalse)]
  emitS $ Assigment t0 $ phi
  return t0


compileBool :: Latte.Expr -> Var -> Var -> FCompilation ()
compileBool (Latte.EAnd expL _ expR) lTrue lFalse = do
  lMid <- freshLabel
  compileBool expL lMid lFalse
  freshBlock lMid
  compileBool expR lTrue lFalse

compileBool (Latte.EOr expL _ expR) lTrue lFalse = do
  lMid <- freshLabel
  compileBool expL lTrue lMid
  freshBlock lMid
  compileBool expR lTrue lFalse

compileBool (Latte.Not _ exp) lTrue lFalse = compileBool exp lFalse lTrue

compileBool expr lTrue lFalse = do
  rVar <- compileE expr
  emitS $ BranchIf rVar lTrue lFalse


compileCmpOp :: CmpOp -> Latte.Expr -> Latte.Expr -> FCompilation Var
compileCmpOp cmpOp lExp rExp = do
  tl <- compileE lExp
  tr <- compileE rExp
  t0 <- freshLocal (Predefined.llvmBool)
  emitS $ Assigment t0 $ Cmp cmpOp tl tr
  return t0


compileAOp :: MachOp -> Latte.Expr -> Latte.Expr -> FCompilation Var
compileAOp moOp lExp rExp = do
  tl <- compileE lExp
  tr <- compileE rExp
  t0 <- freshLocal (Predefined.llvmInt)
  emitS $ Assigment t0 $ Op moOp tl tr
  return t0


compileFunCall :: Ident -> [Latte.Expr] -> FCompilation Var
compileFunCall ident exps = do
  env <- getEnvM
  rVars <- mapM compileE exps
  let functionVar = bindings env Map.! ident
  if rTypeOfFunction functionVar == TVoid then do
    emitS $ SExp $ Call functionVar rVars
    return $ VLit Null
  else do
    t0 <- freshLocal (rTypeOfFunction functionVar)
    emitS $ Assigment t0 $ Call functionVar rVars
    return t0


typeOfLVar :: Var -> Type
typeOfLVar (VLocal _ (TPtr t)) = t

rTypeOfFunction :: Var -> Type
rTypeOfFunction (VGlobal (GlobalVar (TFunction sig) _)) = retType sig

nameOfFunction :: Var -> Ident
nameOfFunction (VGlobal (GlobalVar (TFunction _) fName)) = Ident fName