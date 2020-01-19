module LlvmBackend.Compile where

import Debug.Trace (trace)

import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
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

data Location = Loc Type Integer deriving (Show, Eq, Ord)

data PhiExpr = PhiExpr Type Label [Var] [(Var, Label)] deriving (Show, Eq, Ord)
  -- block the phi belongs to, users list, phi operands list

data Env = Env {
  -- maps variables names to allocated registers
  getProcGlobals :: Map.Map Ident Var,
  getStrLiterals :: Map.Map String Var,
  getBindings :: Map.Map Ident Location,
  getValues :: Map.Map Location (Map.Map Label Var),
  getSubs :: Map.Map Var Var,
  getPhis :: Map.Map Var PhiExpr,
  getIncompletePhis :: Map.Map Label (Map.Map Location Var),
--  getExprEnumeration :: Map.Map Label (Map.Map Expr Var),
  getPreds :: Map.Map Label [Label],
  getSealedBlocks :: Set.Set Label,
  getRegistersCount :: Integer,
  getLocation :: Integer
} deriving Show

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


envGetM :: (Env -> a) -> FCompilation a
envGetM getter = do
  env <- getEnvM
  return $ getter env


envPutM :: (Env -> Env) -> FCompilation ()
envPutM updater = do
  env <- getEnvM
  putEnvM $ updater env


flushBlock :: FCompilation Var
flushBlock = do
  emitS $ Return Nothing -- functions of void type in Latte don't have to
                         -- return explicitly, but they have to in llvm.
                         -- if block already returns something this will be removed
                         -- by *removeUnreachableCodeInBlock*
  cBlock <- getCBlockM
  let cLabel = var2Label (getLabel cBlock)
  sealBlock cLabel
  tell $ singleton $ Block cLabel (toList (getStmts cBlock))
  label <- freshLabel
  putCBlockM $ CBlock label mempty
  return label


emitS :: Statement -> FCompilation ()
emitS s = do
  cBlock <- getCBlockM
  putCBlockM $ CBlock (getLabel cBlock) (getStmts cBlock <> singleton s)


freshBlock :: Var -> FCompilation ()
freshBlock label = do
  cBlock <- getCBlockM
  tell $ singleton $ Block (var2Label (getLabel cBlock)) (toList (getStmts cBlock))
  putCBlockM $ CBlock label mempty


sealAndStartFreshBlock :: Var -> FCompilation ()
sealAndStartFreshBlock nLabel = do
  cBlock <- getCBlockM
  let pLabel = var2Label $ getLabel cBlock
  freshBlock nLabel
  sealBlock pLabel


freshNamedLocal :: Type -> String -> FCompilation Var
freshNamedLocal t p = do
  rCount <- envGetM getRegistersCount
  envPutM $ \env -> env {getRegistersCount = rCount + 1}
  return $ VLocal (p ++ (show rCount)) t


freshLocal :: Type -> FCompilation Var
freshLocal t = freshNamedLocal t "t"


freshLabel :: FCompilation Var
freshLabel = freshNamedLocal TLabel "l"


getBlockPreds :: Label -> FCompilation [Label]
getBlockPreds bLabel = do
  preds <- envGetM getPreds
  return $ case Map.lookup bLabel preds of
    Nothing -> []
    Just labels -> labels


addBlockPred :: Label -> Label -> FCompilation ()
addBlockPred bLabel pred = do
  preds <- getBlockPreds bLabel
  envPutM $ \env -> env {getPreds = Map.insert bLabel (pred:preds) (getPreds env)}


sealBlock :: Label -> FCompilation ()
sealBlock label = do
  sealedBlocks <- envGetM getSealedBlocks
  case Set.member label sealedBlocks of
    True -> return ()
    False -> do
      incompletePhis <- envGetM getIncompletePhis
      case Map.lookup label incompletePhis of
        Nothing -> return ()
        Just phis -> mapM_ (uncurry addPhiOperands) (Map.toList phis)
      envPutM $ \env -> env {getSealedBlocks = Set.insert label (getSealedBlocks env)}


declareVar :: Type -> Ident -> FCompilation Location
declareVar t ident = do
  lCount <- envGetM getLocation
  let location = Loc t lCount
  envPutM $ \env -> env {
    getBindings = Map.insert ident location (getBindings env),
    getLocation = lCount + 1
    }
  return location


setValAt :: Label -> Var -> Location -> FCompilation ()
setValAt label var loc = do
  values <- envGetM getValues
  let locValues = case Map.lookup loc values of
        Just locValues -> Map.insert label var locValues
        Nothing -> Map.singleton label var
  envPutM $ \env -> env {getValues = Map.insert loc locValues values}


setLocalValAt :: Var -> Location -> FCompilation ()
setLocalValAt var loc = do
  cBlock <- getCBlockM
  setValAt (var2Label $ getLabel cBlock) var loc


getLocalVal :: Location -> FCompilation Var
getLocalVal loc = do
  cBlock <- getCBlockM
  getVal (var2Label $ getLabel cBlock) loc


resolveSubstitution :: Var -> FCompilation Var
resolveSubstitution var@(VLocal _ _) = do
  substitution <- envGetM getSubs
  case Map.lookup var substitution of
    Nothing -> return var
    Just sVar -> do
      sSVar <- resolveSubstitution sVar
      if sSVar == sVar then
        return sVar
      else do
        envPutM $ \env -> env {getSubs = Map.insert var sSVar (getSubs env)}
        return sSVar

resolveSubstitution var = return var


getVal :: Label -> Location -> FCompilation Var
getVal label loc = do
  values <- envGetM getValues
  var <- case Map.lookup loc values of
    Nothing -> getValFromPreds label loc
    Just locValues ->
      case Map.lookup label locValues of
        Nothing -> getValFromPreds label loc
        Just val -> return val
  resolveSubstitution var


getValFromPreds :: Label -> Location -> FCompilation Var
getValFromPreds label loc = do
  sealedBlocks <- envGetM getSealedBlocks
  var <-
    if not $ Set.member label sealedBlocks then
      addIncompletePhi label loc
    else do
      preds <- getBlockPreds label
      case preds of
        [pred] -> getVal pred loc
        _ -> do
          let (Loc t _) = loc
          mockPhi <- getNewPhi t label
          setValAt label mockPhi loc
          addPhiOperands loc mockPhi
  setValAt label var loc
  return var


addPhiOperands :: Location -> Var -> FCompilation Var
addPhiOperands loc phi = do
  (PhiExpr pType bLabel users ops) <- getPhiExpr phi
  preds <- getBlockPreds bLabel
  vars <- mapM (\pred -> getVal pred loc) preds
  mapM_ (registerPhiUser phi) vars
  let nPhi = PhiExpr pType bLabel users ((zip vars preds) ++ ops)
  envPutM $ \env -> env {getPhis = Map.insert phi nPhi (getPhis env)}
  return phi


getPhiExpr :: Var -> FCompilation PhiExpr
getPhiExpr phi = do
  phis <- envGetM getPhis
  return $ phis Map.! phi


getNewPhi :: Type -> Label -> FCompilation Var
getNewPhi t label = do
  var <- freshLocal t
  let newPhi = PhiExpr t label [] []
  envPutM $ \env -> env {getPhis = Map.insert var newPhi (getPhis env)}
  return var


addIncompletePhi :: Label -> Location -> FCompilation Var
addIncompletePhi label loc = do
  let (Loc t _) = loc
  newPhi <- getNewPhi t label
  incPhis <- envGetM getIncompletePhis
  let blockIncPhis = case Map.lookup label incPhis of
        Nothing -> Map.singleton loc newPhi
        Just vars -> Map.insert loc newPhi vars
  envPutM $ \env -> env {
    getIncompletePhis = Map.insert label blockIncPhis (getIncompletePhis env)
    }
  return newPhi


-- keep track of phi's usage as some other phi operand
registerPhiUser :: Var -> Var -> FCompilation ()
registerPhiUser userPhi usedPhi = do
  phis <- envGetM getPhis
  case Map.lookup usedPhi phis of
    Nothing -> return ()
    Just (PhiExpr pType bLabel users ops) -> do
      let phi = PhiExpr pType bLabel (userPhi:users) ops
      envPutM $ \env -> env {getPhis = Map.insert usedPhi phi (getPhis env)}


removePhiUser :: Var -> Var -> FCompilation ()
removePhiUser userPhi usedPhi = do
  phis <- envGetM getPhis
  case Map.lookup usedPhi phis of
      Nothing -> return ()
      Just (PhiExpr pType bLabel users ops) -> do
        let phi = PhiExpr pType bLabel (filter (userPhi /=) users) ops
        envPutM $ \env -> env {getPhis = Map.insert usedPhi phi (getPhis env)}


replacePhiBy :: Var -> Var -> FCompilation ()
replacePhiBy phi var =
  envPutM $ \env -> env {getSubs = Map.insert phi var (getSubs env)}


getVar :: Ident -> FCompilation Var
getVar ident = do
  location <- getVariableLocation ident
  getLocalVal location


getVariableLocation :: Ident -> FCompilation Location
getVariableLocation ident = do
  bindings <- envGetM getBindings
  return $ bindings Map.! ident


getStrLiteral :: String -> FCompilation Var
getStrLiteral s = do
  literals <- envGetM getStrLiterals
  case Map.lookup s literals of
    Just var -> return var
    Nothing -> do
      envPutM $ \env -> env {getStrLiterals = nLiterals}
      return gVar
      where
        nLiterals = Map.insert s gVar literals
        gVar = VGlobal $ GlobalVar strType strName
        strName = ".str." ++ (show $ length literals)
        strType = TPtr $ TArray (toInteger (length s + 1)) (TInt 8)


compile :: Latte.Program -> Module
compile (Latte.Program topDefs) =
  essentialOpt $ Module globalStrLiterals forwardDeclarations (toList functions)
  where
    ((_, functions), env) = runState (runWriterT $ mapM_ compileTD topDefs) initialEnv
    globalStrLiterals = map (uncurry toStrDefinition) $ Map.toList $ getStrLiterals env

    initialEnv = Env {
      getProcGlobals = Map.fromList (predefinedBindings ++ definedFunctions),
      getStrLiterals = Map.empty,
      getBindings = Map.empty,
      getValues = Map.empty,
      getSubs = Map.empty,
      getPhis = Map.empty,
      getIncompletePhis = Map.empty,
      getPreds = Map.empty,
      getSealedBlocks = Set.empty,
      getRegistersCount = 1, -- 0 is for the label of the first block
      getLocation = 0
      }
    predefinedBindings = map funAsBinding Predefined.envFunctions
    definedFunctions = map (funAsBinding.topDef2Var) topDefs

    forwardDeclarations = map toForwardFunDeclaration Predefined.envFunctions

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
  initialCompState <- getInitialCompState
  let ((_, cBlocks), nCompState) = runState (runWriterT $ compileTDBlock args block) initialCompState
  let nEnv = getEnv nCompState
  lift $ put $ (getEnv initialCompState) {getStrLiterals = getStrLiterals nEnv}
  tell $ singleton $ Func (topDef2Sig td) (map argName args) (placePhis nEnv (toList cBlocks))
  where
    argName (Latte.Arg _ pIdent) = let (Ident name, _) = pIdent2Ident pIdent in name
    getInitialCompState = do
      env <- lift get
      return $ CompState env (CBlock (VLocal "0" TLabel) mempty)


placePhis :: Env -> [Block] -> [Block]
placePhis env = map $ placePhiInBlock $ getPhis env


placePhiInBlock :: (Map.Map Var PhiExpr) -> Block -> Block
placePhiInBlock phis (Block label stmts) =
  Block label (foldr appendPhiDefinition stmts blockPhis)
  where
    blockPhis = Map.toList $ Map.filter (\(PhiExpr _ phiLabel _ _) -> phiLabel == label) phis
    appendPhiDefinition :: (Var, PhiExpr) -> [Statement] -> [Statement]
    appendPhiDefinition (var, (PhiExpr pType _ _ operands)) =
      (Assigment var (Phi pType (phiOps operands)):)
    phiOps = map (\(var, (Label name)) -> (var, VLocal name TLabel))


compileTDBlock :: [Latte.Arg] -> Latte.Block -> FCompilation ()
compileTDBlock args block = do
  mapM_ compileArg args
  compileB block
  flushBlock
  return ()


compileArg :: Latte.Arg -> FCompilation ()
compileArg (Latte.Arg t pIdent) = do
  loc <- declareVar llvmType ident
  setLocalValAt (VLocal name llvmType) loc
  where
    ident@(Ident name) = fst $ pIdent2Ident pIdent
    llvmType = latT2Llvm t


compileB :: Latte.Block -> FCompilation ()
compileB (Latte.Block _ stmts _) = do
  env <- getEnvM
  mapM_ compileS stmts
  envPutM $ \nEnv -> nEnv {getBindings = getBindings env}


compileS :: Latte.Stmt -> FCompilation ()
compileS Latte.Empty = return ()

compileS (Latte.BStmt block) = compileB block

compileS (Latte.Decl t items) = mapM_ (compileSDecl t) items

compileS (Latte.Ass pIdent exp) = do
  rVar <- compileE exp
  loc <- getVariableLocation $ fst $ pIdent2Ident pIdent
  setLocalValAt rVar loc

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
  sealAndStartFreshBlock lTrue
  compileS stmt
  emitBranch lCont
  sealAndStartFreshBlock lCont

compileS (Latte.CondElse _ exp tStmt _ fStmt) = do
  lTrue <- freshLabel
  lFalse <- freshLabel
  lCont <- freshLabel
  compileBool exp lTrue lFalse
  sealAndStartFreshBlock lTrue
  compileS tStmt
  emitBranch lCont
  sealAndStartFreshBlock lFalse
  compileS fStmt
  emitBranch lCont
  sealAndStartFreshBlock lCont

compileS (Latte.While _ exp stmt) = do
  condLabel <- freshLabel
  bodyLabel <- freshLabel
  contLabel <- freshLabel
  emitBranch condLabel
  sealAndStartFreshBlock bodyLabel
  compileS stmt
  emitBranch condLabel
  freshBlock condLabel
  compileBool exp bodyLabel contLabel
  sealAndStartFreshBlock contLabel
  sealBlock $ var2Label bodyLabel


compileIncBy :: Latte.PIdent -> Lit -> FCompilation ()
compileIncBy pIdent lit = do
  let ident = fst $ pIdent2Ident pIdent
  var <- getVar ident
  t0 <- peepholeOp MO_Add var (VLit lit)
  loc <- getVariableLocation ident
  setLocalValAt t0 loc


compileSDecl :: Latte.Type -> Latte.Item -> FCompilation Var
compileSDecl t (Latte.NoInit pIdent) = compileSDecl t (Latte.Init pIdent (defaultExp t))
  where
    defaultExp Latte.Int = Latte.ELitInt 0
    defaultExp Latte.Bool = Latte.ELitFalse
    defaultExp Latte.Str = Latte.EString ""

compileSDecl t (Latte.Init pIdent exp) = do
  rVar <- compileE exp
  location <- declareVar (latT2Llvm t) (fst $ pIdent2Ident pIdent)
  setLocalValAt rVar location
  return rVar


emitBranch :: Var -> FCompilation ()
emitBranch jumpTo = do
  cBlock <- getCBlockM
  addBlockPred (var2Label jumpTo) (var2Label $ getLabel cBlock)
  emitS $ Branch jumpTo


emitBranchIf :: Var -> Var -> Var -> FCompilation ()
emitBranchIf cond lTrue lFalse = do
  cBlock <- getCBlockM
  let jumpFrom = var2Label $ getLabel cBlock
  addBlockPred (var2Label lTrue) jumpFrom
  addBlockPred (var2Label lFalse) jumpFrom
  emitS $ BranchIf cond lTrue lFalse


peepholeOp :: MachOp -> Var -> Var -> FCompilation Var
peepholeOp op (VLit (LInt _ 0)) var | op == MO_Add || op == MO_Sub = return var

peepholeOp op var (VLit (LInt _ 0)) | op == MO_Add || op == MO_Sub = return var

peepholeOp op var (VLit (LInt _ 1)) | op == MO_Mul || op == MO_SDiv = return var

peepholeOp MO_Mul (VLit (LInt _ 1)) var = return var

peepholeOp MO_Mul (VLit (LInt p 0)) _ = return $ (VLit (LInt p 0))

peepholeOp MO_Mul _ (VLit (LInt p 0)) = return $ (VLit (LInt p 0))

peepholeOp MO_SDiv _ (VLit (LInt _ 0)) = fail "Division by zero"

peepholeOp MO_Sub lVar rVar | lVar == rVar = return $ (VLit (LInt 32 0))

peepholeOp op (VLit (LInt p n)) (VLit (LInt _ m)) = return $ VLit $ LInt p (evalOp op n m)
  where
    evalOp MO_Add = (+)
    evalOp MO_Sub = (-)
    evalOp MO_Mul = (*)
    evalOp MO_SDiv = div
    evalOp MO_SRem = mod
    evalOp MO_And = (*)
    evalOp MO_Or = \n m -> evalOp MO_Xor (evalOp MO_Xor n m) (evalOp MO_And n m)
    evalOp MO_Xor = \n m -> mod (n + m) 2

peepholeOp op lVar rVar = do
  t0 <- freshLocal Predefined.llvmInt
  emitS $ Assigment t0 $ Op op lVar rVar
  return t0


-- todo assure optimal order of expression computation
compileE :: Latte.Expr -> FCompilation Var
compileE (Latte.EVar pIdent) = getVar $ fst $ pIdent2Ident pIdent

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
  sealAndStartFreshBlock lTrue
  emitBranch lCont
  sealAndStartFreshBlock lFalse
  emitBranch lCont
  sealAndStartFreshBlock lCont
  t0 <- freshLocal Predefined.llvmBool
  let phi = Phi (Predefined.llvmBool) [(VLit (LInt 1 1), lTrue), (VLit (LInt 1 0), lFalse)]
  emitS $ Assigment t0 $ phi
  return t0


compileBool :: Latte.Expr -> Var -> Var -> FCompilation ()
compileBool (Latte.EAnd expL _ expR) lTrue lFalse = do
  lMid <- freshLabel
  compileBool expL lMid lFalse
  sealAndStartFreshBlock lMid
  compileBool expR lTrue lFalse

compileBool (Latte.EOr expL _ expR) lTrue lFalse = do
  lMid <- freshLabel
  compileBool expL lTrue lMid
  sealAndStartFreshBlock lMid
  compileBool expR lTrue lFalse

compileBool (Latte.Not _ exp) lTrue lFalse = compileBool exp lFalse lTrue

compileBool expr lTrue lFalse = do
  rVar <- compileE expr
  emitBranchIf rVar lTrue lFalse


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
  procGlobals <- envGetM getProcGlobals
  rVars <- mapM compileE exps
  let functionVar = procGlobals Map.! ident
  if rTypeOfFunction functionVar == TVoid then do
    emitS $ SExp $ Call functionVar rVars
    return $ VLit Null
  else do
    t0 <- freshLocal (rTypeOfFunction functionVar)
    emitS $ Assigment t0 $ Call functionVar rVars
    return t0


typeOfVar :: Var -> Type
typeOfVar (VLocal _ t) = t

typeOfVar (VLit lit) = typeOfLit lit

typeOfLit :: Lit -> Type
typeOfLit (LInt precision _) = TInt precision


rTypeOfFunction :: Var -> Type
rTypeOfFunction (VGlobal (GlobalVar (TFunction sig) _)) = retType sig

nameOfFunction :: Var -> Ident
nameOfFunction (VGlobal (GlobalVar (TFunction _) fName)) = Ident fName