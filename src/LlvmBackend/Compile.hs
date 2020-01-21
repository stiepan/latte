module LlvmBackend.Compile where

import Debug.Trace (trace)

import qualified Data.Map.Strict as Map
import qualified Data.Set as Set
import Control.Monad.Trans.Class
import Control.Monad.Trans.State
import Control.Monad.Trans.Writer
import Control.Monad.Trans.Except
import Data.Functor.Identity

import Common.DList
import Common.Ident
import Common.Show

import qualified AbsLatte as Latte
import qualified LlvmBackend.Predefined as Predefined
import LlvmBackend.Llvm
import LlvmBackend.Normalize (returnsCorrectly, essentialFunctionOpt, replaceRegisters)
import Frontend.Error


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
  getExprEnumeration :: Map.Map Label (Map.Map Expr Var),
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
  getCBlock :: CBlock,
  getRetType :: Latte.Type -- ret type of currently compiled function
}


type FCompilation = WriterT Blocks (StateT CompState Identity)


type TopDefCompilation = ExceptT SemanticError (WriterT Functions (StateT Env Identity))


getEnvM :: FCompilation Env
getEnvM = do
  state <- lift get
  return $ getEnv state


putEnvM :: Env -> FCompilation ()
putEnvM env = do
  state <- lift get
  lift $ put $ state {getEnv = env}


getCBlockM :: FCompilation CBlock
getCBlockM = do
  state <- lift get
  return $ getCBlock state


putCBlockM :: CBlock -> FCompilation ()
putCBlockM cBlock = do
  state <- lift get
  lift $ put $ state {getCBlock = cBlock}


getRetTypeM :: FCompilation Latte.Type
getRetTypeM = do
  state <- lift get
  return $ getRetType state


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
  rType <- getRetTypeM
  if rType == Latte.Void then
    emitS $ Return Nothing -- functions of void type in Latte don't have to
                           -- return explicitly, but they have to in llvm.
                           -- if block already returns something this will be removed
                           -- by *removeUnreachableCodeInBlock*
  else return ()
  cBlock <- getCBlockM
  let cLabel = var2Label (getLabel cBlock)
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


sealBlock :: Var -> FCompilation ()
sealBlock vLabel = do
  sealedBlocks <- envGetM getSealedBlocks
  let label = var2Label vLabel
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
  phiExpr <- getPhiExpr phi
  case phiExpr of
    Nothing -> fail $ "Unexpected replaced phi at " ++ show phi
    Just (PhiExpr pType bLabel users ops) -> do
      preds <- getBlockPreds bLabel
      vars <- mapM (\pred -> getVal pred loc) preds
      mapM_ (registerPhiUser phi) vars
      let nPhi = PhiExpr pType bLabel users ((zip vars preds) ++ ops)
      envPutM $ \env -> env {getPhis = Map.insert phi nPhi (getPhis env)}
      tryRemoveTrivialPhi phi


getPhiExpr :: Var -> FCompilation (Maybe PhiExpr)
getPhiExpr phi = do
  phis <- envGetM getPhis
  case Map.lookup phi phis of
    Nothing -> return Nothing
    Just (PhiExpr t l users ops) -> do
      rOps <- mapM resolveSubs ops
      let nPhiExpr = PhiExpr t l users rOps
      envPutM $ \env -> env {getPhis = Map.insert phi nPhiExpr (getPhis env)}
      return $ Just nPhiExpr
  where
    resolveSubs (var, label) = do
      rVar <- resolveSubstitution var
      return (rVar, label)


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


tryRemoveTrivialPhi :: Var -> FCompilation Var
tryRemoveTrivialPhi phi = do
  phiExpr <- getPhiExpr phi
  case phiExpr of
    Nothing -> resolveSubstitution phi
    Just (PhiExpr t l users ops) -> do
      let vOps = map fst ops
      let nonSelf = filter (phi /=) vOps
      if hasDifferentValues nonSelf then
        return phi
      else do
        let var = subsBy nonSelf
        replacePhiBy phi var
        mapM_ tryRemoveTrivialPhi users
        return var
  where
    hasDifferentValues [] = False
    hasDifferentValues (h:t) = foldr (\e acc -> acc || h /= e) False t
    subsBy [] = VLit Null
    subsBy (h:_) = h


replacePhiBy :: Var -> Var -> FCompilation ()
replacePhiBy phi var = do
  envPutM $ \env -> env {
    getSubs = Map.insert phi var (getSubs env),
    getPhis = Map.delete phi (getPhis env)
    }


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


compile :: Latte.Program -> Either SemanticError Module
compile (Latte.Program topDefs) =
  case res of
    Left error -> Left error
    _ -> Right $ Module globalStrLiterals forwardDeclarations (toList functions)
  where
    ((res, functions), env) = runState (runWriterT $ runExceptT $ mapM_ compileTD topDefs) initialEnv
    globalStrLiterals = map (uncurry toStrDefinition) $ Map.toList $ getStrLiterals env

    initialEnv = Env {
      getProcGlobals = Map.fromList (predefinedBindings ++ definedFunctions),
      getStrLiterals = Map.empty,
      getBindings = Map.empty,
      getValues = Map.empty,
      getSubs = Map.empty,
      getPhis = Map.empty,
      getIncompletePhis = Map.empty,
      getExprEnumeration = Map.empty,
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
  lift $ lift $ put $ (getEnv initialCompState) {getStrLiterals = getStrLiterals nEnv}
  let func = essentialFunctionOpt $ Func (topDef2Sig td) (map argName args) (placePhisAndSubs nEnv (toList cBlocks))
  if not $ returnsCorrectly func then
    throwE $ ProcWithoutReturn (fst $ pIdent2Ident pIdent)
--    fail $ "Function " ++ pIdent2Name pIdent ++ " of type " ++ show rType ++ " exits without returing anything"
  else lift $ tell $ singleton func
  where
    argName (Latte.Arg _ pIdent) = pIdent2Name pIdent
    pIdent2Name pIdent = let (Ident name, _) = pIdent2Ident pIdent in name
    getInitialCompState = do
      env <- lift $ lift get
      return $ CompState env (CBlock (VLocal "0" TLabel) mempty) rType


placePhisAndSubs :: Env -> [Block] -> [Block]
placePhisAndSubs env = map ((replaceRegisters (getSubs env)).(placePhiInBlock (getPhis env)))


placePhiInBlock :: Map.Map Var PhiExpr -> Block -> Block
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
  cBlock <- getCBlockM
  sealBlock (getLabel cBlock) -- it's not possible to jump to the beginning of the function
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
  rVar <- optimizeE $ compileE exp
  loc <- getVariableLocation $ fst $ pIdent2Ident pIdent
  setLocalValAt rVar loc

compileS (Latte.Incr pIdent) = compileIncBy pIdent (LInt 32 1)

compileS (Latte.Decr pIdent) = compileIncBy pIdent (LInt 32 (-1))

compileS (Latte.Ret _ exp) = do
  rVar <- optimizeE $ compileE exp
  emitS $ Return $ Just rVar

compileS (Latte.VRet _) = do
  emitS $ Return $ Nothing

compileS (Latte.SExp exp) = do
  rVar <- compileE exp
  return ()

compileS (Latte.Cond _ exp stmt) = do
  lTrue <- freshLabel
  lCont <- freshLabel
  cond <- compileBool exp lTrue lCont
  case cond of
    VLit (LInt _ n) ->
      case n of
        0 -> return ()
        _ -> compileS stmt
    _ -> do
      sealBlock lTrue
      freshBlock lTrue
      compileS stmt
      emitBranch lCont
      sealBlock lCont
      freshBlock lCont

compileS (Latte.CondElse _ exp tStmt _ fStmt) = do
  lTrue <- freshLabel
  lFalse <- freshLabel
  lCont <- freshLabel
  cond <- optimizeE $ compileBool exp lTrue lFalse
  case cond of
    VLit (LInt _ n) ->
      case n of
        0 -> compileS fStmt
        _ -> compileS tStmt
    _ -> do
      sealBlock lTrue
      freshBlock lTrue
      compileS tStmt
      emitBranch lCont
      sealBlock lFalse
      freshBlock lFalse
      compileS fStmt
      emitBranch lCont
      sealBlock lCont
      freshBlock lCont

compileS (Latte.While _ exp stmt) = do
  condLabel <- freshLabel
  bodyLabel <- freshLabel
  contLabel <- freshLabel
  cond <- optimizeE $ emitBranch condLabel >> freshBlock condLabel >> compileBool exp bodyLabel contLabel
  case cond of
    VLit (LInt _ 0) -> return ()
    VLit (LInt _ _) -> do
      emitBranch bodyLabel
      freshBlock bodyLabel
      compileS stmt
      emitBranch bodyLabel
      sealBlock bodyLabel
    _ -> do
      sealBlock bodyLabel
      freshBlock bodyLabel
      compileS stmt
      emitBranch condLabel
      sealBlock condLabel
      freshBlock contLabel
      sealBlock contLabel


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
  rVar <- optimizeE $ compileE exp
  location <- declareVar (latT2Llvm t) (fst $ pIdent2Ident pIdent)
  setLocalValAt rVar location
  return rVar


emitBranch :: Var -> FCompilation ()
emitBranch jumpTo = do
  cBlock <- getCBlockM
  addBlockPred (var2Label jumpTo) (var2Label $ getLabel cBlock)
  emitS $ Branch jumpTo


emitBranchIf :: Var -> Var -> Var -> FCompilation ()
emitBranchIf cond lTrue lFalse =
  case cond of
    (VLit (LInt _ val)) ->
      if val == 0 then emitBranch lFalse else emitBranch lTrue
    _ -> do
      cBlock <- getCBlockM
      let jumpFrom = var2Label $ getLabel cBlock
      addBlockPred (var2Label lTrue) jumpFrom
      addBlockPred (var2Label lFalse) jumpFrom
      emitS $ BranchIf cond lTrue lFalse


getRegWith :: Type -> Expr -> FCompilation Var
getRegWith t expr = do
  case expr of
    (Op _ _ _) -> getOrEmitReg t expr
    (Cmp _ _ _) -> getOrEmitReg t expr
    (GetElemPtr _ _ _) -> getOrEmitReg t expr
    (Phi _ _) -> getOrEmitReg t expr
    (Call True _ _) -> getOrEmitReg t expr
    _ -> emitReg t expr


getExistingReg :: Label -> Expr -> FCompilation (Maybe Var)
getExistingReg label expr = do
  enumeration <- envGetM getExprEnumeration
  return $ case Map.lookup label enumeration of
    Nothing -> Nothing
    Just exps -> Map.lookup expr exps


getExistingRegRec :: Label -> Expr -> FCompilation (Maybe Var)
getExistingRegRec label expr =
  traverseRec label expr []
  where
  traverseRec label expr visited = do
    if label `elem` visited then
      return Nothing
    else do
      var <- getExistingReg label expr
      case var of
        Just var -> return $ Just var
        Nothing -> do
          sealedBlocks <- envGetM getSealedBlocks
          if not $ Set.member label sealedBlocks then
            return Nothing
          else do
            preds <- getBlockPreds label
            predVals <- mapM (\pred -> traverseRec pred expr (label:visited)) preds
            if any (Nothing ==) predVals then
              return Nothing
            else
              case predVals of
                (Just var):_ -> do
                  var <- registerNewReg label expr var
                  return $ Just var
                _ -> return Nothing


getOrEmitReg :: Type -> Expr -> FCompilation Var
getOrEmitReg t expr = do
  cBlock <- getCBlockM
  let cLabel = var2Label $ getLabel cBlock
  existingVar <- getExistingRegRec cLabel expr
  case existingVar of
    Nothing -> emitAndRecNewReg cLabel t expr
    Just var -> return var


emitAndRecNewReg :: Label -> Type -> Expr -> FCompilation Var
emitAndRecNewReg label t expr = do
  var <- emitReg t expr
  registerNewReg label expr var


registerNewReg :: Label -> Expr -> Var -> FCompilation Var
registerNewReg label expr var = do
  enumeration <- envGetM getExprEnumeration
  let nExps = case Map.lookup label enumeration of
        Nothing -> Map.singleton expr var
        Just exps -> Map.insert expr var exps
  envPutM $ \env -> env {getExprEnumeration = Map.insert label nExps enumeration}
  return var


emitReg :: Type -> Expr -> FCompilation Var
emitReg t expr = do
  t0 <- freshLocal t
  emitS $ Assigment t0 expr
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
  getRegWith (Predefined.llvmString) $ GetElemPtr False rVal [VLit (LInt 32 0), VLit (LInt 32 0)]

compileE (Latte.EApp pIdent exps) =
  compileFunCall False (fst $ pIdent2Ident pIdent) exps

compileE (Latte.Neg _ exp) = do
  rVar <- optimizeE $ compileE exp
  peepholeOp MO_Sub (VLit $ LInt 32 0) rVar

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
  compileFunCall True (nameOfFunction Predefined.internalConcat) [lExp, rExp]

compileE (Latte.ERel lExp (Latte.LTH _) rExp) = compileCmpOp CMP_Slt lExp rExp

compileE (Latte.ERel lExp (Latte.LE _) rExp) = compileCmpOp CMP_Sle lExp rExp

compileE (Latte.ERel lExp (Latte.GTH _) rExp) = compileCmpOp CMP_Sgt lExp rExp

compileE (Latte.ERel lExp (Latte.GE _) rExp) = compileCmpOp CMP_Sge lExp rExp

compileE (Latte.ERel lExp (Latte.OverloadedEQU Latte.Int _) rExp) =
  compileCmpOp CMP_Eq lExp rExp

compileE (Latte.ERel lExp (Latte.OverloadedEQU Latte.Bool _) rExp) =
  compileCmpOp CMP_Eq lExp rExp

compileE (Latte.ERel lExp (Latte.OverloadedEQU Latte.Str _) rExp) = do
  lVar <- optimizeE $ compileE lExp
  rVar <- optimizeE $ compileE rExp
  if lVar == rVar then
    return $ boolLiteral True
  else
    compileFunCallWithRegs True (nameOfFunction Predefined.internalStringEq) [lVar, rVar]

compileE (Latte.ERel lExp (Latte.OverloadedNE Latte.Int _) rExp) =
  compileCmpOp CMP_Ne lExp rExp

compileE (Latte.ERel lExp (Latte.OverloadedNE Latte.Bool _) rExp) =
  compileCmpOp CMP_Ne lExp rExp

compileE (Latte.ERel lExp (Latte.OverloadedNE Latte.Str _) rExp) = do
  lVar <- optimizeE $ compileE lExp
  rVar <- optimizeE $ compileE rExp
  if lVar == rVar then
    return $ boolLiteral False
  else do
    var <- compileFunCallWithRegs True (nameOfFunction Predefined.internalStringEq) [lVar, rVar]
    getRegWith (Predefined.llvmBool) $ Op MO_Xor (VLit $ LInt 1 1) var

compileE bExp@(Latte.EAnd _ _ _) = compileBExp bExp

compileE bExp@(Latte.EOr _ _ _) = compileBExp bExp

compileE bExp@(Latte.Not _ _) = compileBExp bExp


-- todo merge lTrue and LFalse blocks into one with bigger phi
compileBExp :: Latte.Expr -> FCompilation Var
compileBExp exp = do
  lTrue <- freshLabel
  lFalse <- freshLabel
  cond <- optimizeE $ compileBool exp lTrue lFalse
  case cond of
    VLit _ -> return cond
    _ -> do
      lCont <- freshLabel
      sealBlock lTrue
      freshBlock lTrue
      emitBranch lCont
      sealBlock lFalse
      freshBlock lFalse
      emitBranch lCont
      sealBlock lCont
      freshBlock lCont
      let phi = Phi (Predefined.llvmBool) [(VLit (LInt 1 1), lTrue), (VLit (LInt 1 0), lFalse)]
      getRegWith Predefined.llvmBool phi


compileBool :: Latte.Expr -> Var -> Var -> FCompilation Var
compileBool expr lTrue lFalse = do
  sExpr <- foldBoolean expr
  case sExpr of
    Latte.ELitTrue -> return $ VLit (LInt 1 1)
    Latte.ELitFalse -> return $ VLit (LInt 1 0)
    _ -> compileFoldedBool sExpr lTrue lFalse


compileFoldedBool :: Latte.Expr -> Var -> Var -> FCompilation Var
compileFoldedBool (Latte.EAnd expL _ expR) lTrue lFalse = do
  lMid <- freshLabel
  compileFoldedBool expL lMid lFalse
  sealBlock lMid
  freshBlock lMid
  compileFoldedBool expR lTrue lFalse

compileFoldedBool (Latte.EOr expL _ expR) lTrue lFalse = do
  lMid <- freshLabel
  compileFoldedBool expL lTrue lMid
  sealBlock lMid
  freshBlock lMid
  compileFoldedBool expR lTrue lFalse

compileFoldedBool (Latte.Not _ exp) lTrue lFalse = compileFoldedBool exp lFalse lTrue

compileFoldedBool expr lTrue lFalse = do
  rVar <- optimizeE $ compileE expr
  emitBranchIf rVar lTrue lFalse
  return rVar


compileCmpOp :: CmpOp -> Latte.Expr -> Latte.Expr -> FCompilation Var
compileCmpOp cmpOp lExp rExp = do
  tl <- optimizeE $ compileE lExp
  tr <- optimizeE $ compileE rExp
  peepholeCmp cmpOp tl tr


compileAOp :: MachOp -> Latte.Expr -> Latte.Expr -> FCompilation Var
compileAOp moOp lExp rExp = do
  tl <- optimizeE $ compileE lExp
  tr <- optimizeE $ compileE rExp
  peepholeOp moOp tl tr


compileFunCall :: Bool -> Ident -> [Latte.Expr] -> FCompilation Var
compileFunCall enumerable ident exps = do
  rVars <- mapM (\exp -> optimizeE $ compileE exp) exps
  compileFunCallWithRegs enumerable ident rVars


compileFunCallWithRegs ::Bool -> Ident -> [Var] -> FCompilation Var
compileFunCallWithRegs enumerable ident rVars = do
  procGlobals <- envGetM getProcGlobals
  let functionVar = procGlobals Map.! ident
  if rTypeOfFunction functionVar == TVoid then do
    emitS $ SExp $ Call enumerable functionVar rVars
    return $ VLit Null
  else do
    getRegWith (rTypeOfFunction functionVar) $ Call enumerable functionVar rVars


peepholeOp :: MachOp -> Var -> Var -> FCompilation Var
peepholeOp MO_Add (VLit (LInt _ 0)) var = return var

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
  getRegWith Predefined.llvmInt $ Op op lVar rVar


peepholeCmp :: CmpOp -> Var -> Var -> FCompilation Var
peepholeCmp op (VLit (LInt _ n)) (VLit (LInt _ m)) =
  return $ boolLiteral $ evalCmpOp op n m

peepholeCmp op lVar rVar | lVar == rVar = return $ boolLiteral True

peepholeCmp op lVar rVar = do
  getRegWith (Predefined.llvmBool) $ Cmp op lVar rVar


boolLiteral :: Bool -> Var
boolLiteral True = VLit (LInt 1 1)
boolLiteral False = VLit (LInt 1 0)


evalCmpOp :: CmpOp -> Integer -> Integer -> Bool
evalCmpOp CMP_Eq = (==)
evalCmpOp CMP_Ne = (/=)
evalCmpOp CMP_Sgt = (>)
evalCmpOp CMP_Sge = (>=)
evalCmpOp CMP_Slt = (<)
evalCmpOp CMP_Sle = (<=)


optimizeE :: FCompilation Var -> FCompilation Var
optimizeE compilation = do
  state <- lift get
  let ((resVar, nBlocks), nState) = runState (runWriterT compilation) state
  case resVar of
    (VLit _) -> return resVar
    (VLocal _ _) -> do
      tell nBlocks
      lift $ put nState
      return resVar


foldBoolean :: Latte.Expr -> FCompilation (Latte.Expr)
foldBoolean expr = do
  state <- lift get
  let ((folded, _), _) = runState (runWriterT (booleanFolding expr)) state
  return folded


booleanFolding :: Latte.Expr -> FCompilation (Latte.Expr)
booleanFolding (Latte.EAnd expL pos expR) = do
  fL <- booleanFolding expL
  fR <- booleanFolding expR
  return $ case fL of
    Latte.ELitFalse -> Latte.ELitFalse
    Latte.ELitTrue -> fR
    _ -> case fR of
      Latte.ELitFalse -> Latte.ELitFalse
      Latte.ELitTrue -> fL
      _ -> (Latte.EAnd fL pos fR)

booleanFolding (Latte.Not pos exp) = do
  cond <- booleanFolding exp
  return $ case cond of
    Latte.ELitFalse -> Latte.ELitTrue
    Latte.ELitTrue -> Latte.ELitFalse
    _ -> Latte.Not pos cond

booleanFolding (Latte.EOr expL pos expR) = do
  fL <- booleanFolding expL
  fR <- booleanFolding expR
  return $ case fL of
    Latte.ELitTrue -> Latte.ELitTrue
    Latte.ELitFalse -> fR
    _ -> case fR of
      Latte.ELitTrue -> Latte.ELitTrue
      Latte.ELitFalse -> fL
      _ -> (Latte.EOr fL pos fR)

booleanFolding expr = do
  var <- compileE expr
  return $ case var of
    (VLit (LInt _ 0)) -> Latte.ELitFalse
    (VLit (LInt _ _)) -> Latte.ELitTrue
    _ -> expr


typeOfVar :: Var -> Type
typeOfVar (VLocal _ t) = t

typeOfVar (VLit lit) = typeOfLit lit

typeOfLit :: Lit -> Type
typeOfLit (LInt precision _) = TInt precision


rTypeOfFunction :: Var -> Type
rTypeOfFunction (VGlobal (GlobalVar (TFunction sig) _)) = retType sig

nameOfFunction :: Var -> Ident
nameOfFunction (VGlobal (GlobalVar (TFunction _) fName)) = Ident fName