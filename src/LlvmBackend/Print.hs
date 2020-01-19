module LlvmBackend.Print where

import Control.Monad.Trans.Writer
import Data.Functor.Identity
import qualified Data.Map.Strict as Map

import Common.DList
import LlvmBackend.Llvm
import LlvmBackend.Optimize (blocksPredecessors)

type Printing = WriterT (DList Char) Identity


emit :: String -> Printing ()
emit = tell.toDList


emitSs :: [String] -> Printing ()
emitSs = mapM_ emit


emitSepSs :: String -> [String] -> Printing ()
emitSepSs sep ss = emitSs $ separated sep ss


separated :: a -> [a] -> [a]
separated sep [] = []
separated sep (s:[]) = [s]
separated sep (s:ss) = s:sep:(separated sep ss)


joinedM :: String -> [Printing ()] -> Printing ()
joinedM sep ps = sequence_ (separated (emit sep) ps)


showModule :: Module -> String
showModule m = toList $ execWriter $ printModule m


printModule :: Module -> Printing ()
printModule (Module gs fDs fs) = do
  emit "; globals\n"
  joinedM "\n\n" $ map printGlobalDef gs
  emit "\n\n; forward declarations\n"
  joinedM "\n\n" $ map printForwardDecl fDs
  emit "\n\n; function definitions\n"
  joinedM "\n\n" $ map printFunction fs


printGlobalDef :: GlobalVarDef -> Printing ()
printGlobalDef (GConstDef linkage (GlobalVar t name) sLit) = do
  emitSs ["@", name]
  joinedM " " [emit " =", printLinkage linkage, emit "unnamed_addr constant "]
  printStaticLit sLit


printStaticLit :: StaticLit -> Printing ()
printStaticLit (StaticStr s) = do
  printType $ TArray (toInteger $ length s + 1) (TInt 8)
  emit " c\""
  emit $ escape '"' "\\22" $ escape '\\' "\\5C" s
  emit "\\00\""


escape :: Char -> String -> String -> String
escape find rep s = foldr (++) [] (map (\c -> if c == find then rep else [c]) s)


printLinkage :: LinkageType -> Printing ()
printLinkage Internal = emit "internal"
printLinkage External = emit "external"
printLinkage Private = emit "private"


printForwardDecl :: Signature -> Printing ()
printForwardDecl sig = do
  emit "declare "
  printSignature sig


printSignature :: Signature -> Printing ()
printSignature sig@(Sig _ _ aTypes _) =
  printSig (joinedM ", " (map printType aTypes)) sig


printSig:: Printing () -> Signature -> Printing ()
printSig printArgs (Sig fName rType _ fLinkage) = do
  if fLinkage /= External then do
    printLinkage fLinkage
    emit " "
  else return ()
  printType rType
  emitSs [" @", fName, "("]
  printArgs
  emit ")"


printType :: Type -> Printing ()
printType TVoid = emit "void"
printType (TInt n) = emit $ 'i':(show n)
printType (TPtr t) = do
  printType t
  emit "*"
printType (TArray n t) = do
  emit "["
  emit $ show n
  emit " x "
  printType t
  emit "]"
printType TLabel = emit "label"
printType (TFunction sig) = printSignature sig


printNamedArg :: Type -> String -> Printing ()
printNamedArg t name = do
  printType t
  emit " %"
  emit name


printFunction :: Function -> Printing ()
printFunction (Func fSig aNames funcBody) = do
  emit "define "
  printSig (joinedM ", " $ map (uncurry printNamedArg) $ zip (argTypes fSig) aNames) fSig
  emit " {\n"
  let flowMap = blocksPredecessors funcBody
  mapM_ (printBlock flowMap) funcBody
  emit "}"


printBlock :: Map.Map Label [Label] -> Block -> Printing ()
printBlock preds (Block bId bStmts) = do
  printLabelWithPreds preds bId
  joinedM "\n" $ map (\stmt -> (emit "    ") >> (printStmt stmt)) bStmts
  emit "\n"


printLabelWithPreds :: Map.Map Label [Label] -> Label -> Printing ()
printLabelWithPreds preds label@(Label name) =
  if name == "0" then
    return ()
  else do
    emitSs [name, ":"]
    case Map.lookup label preds of
      Nothing -> return ()
      Just [] -> return ()
      Just labels -> do
        emit "                                    ; preds = "
        joinedM ", " (map printLabel labels)
    emit "\n"


printLabel :: Label -> Printing ()
printLabel (Label name) =
    emitSs ["%", name]


printStmt :: Statement -> Printing ()
printStmt (Assigment (VLocal s _) expr) = do
  emitSs ["%", s, " = "]
  printExpr expr

printStmt (Branch var) = do
  emit "br "
  printRVar var

printStmt (BranchIf cond lTrue lFalse) = do
  emit "br "
  joinedM ", " (map printRVar [cond, lTrue, lFalse])

printStmt (NOp) = emit "\n"

printStmt (Store rVal lVal) = do
  emit "store "
  joinedM ", " (map printRVar [rVal, lVal])

printStmt (SExp expr) = printExpr expr

printStmt (Return Nothing) = emit "ret void"

printStmt (Return (Just var)) = do
  emit "ret "
  printRVar var

printStmt stmt = (emit.show) stmt


printRVar :: Var -> Printing ()
printRVar (VLocal name t) = do
  printType t
  emitSs [" %", name]

printRVar (VLit (LInt precision n)) = do
  let t = TInt precision
  printType t
  emitSs [" ", show n]

printRVar (VGlobal (GlobalVar t name)) = do
  printType t
  emitSs [" @", name]


printRVarVal :: Var -> Printing ()
printRVarVal (VLocal name t) = emitSs ["%", name]

printRVarVal (VLit (LInt precision n)) = emit $ show n

printRVarVal (VGlobal (GlobalVar t name)) = emitSs ["@", name]


typeOfVar :: Var -> Type
typeOfVar (VLocal _ t) = t

typeOfVar (VLit (LInt precision _)) = TInt precision

typeOfVar (VGlobal (GlobalVar t _)) = t


dereferenceType :: Type -> Type
dereferenceType (TPtr t) = t


printExpr :: Expr -> Printing ()

printExpr (Alloca 1 t) = do
  emit "alloca "
  printType t

printExpr (Alloca n t) = do
  printExpr (Alloca 1 t)
  emitSs [", i32 ", show n]

printExpr (Load var) = do
  let tPtr = typeOfVar var
  let t = dereferenceType tPtr
  emit "load "
  printType t
  emit ", "
  printRVar var

printExpr (Call (VGlobal (GlobalVar (TFunction sig) _)) args) = do
  emit "call "
  printSig (joinedM ", " (map printRVar args)) sig

printExpr (Phi t rules) = do
  emit "phi "
  printType t
  emit " "
  joinedM ", " (map printRule rules)
  where
    printRule (val, label) = do
      emit "[ "
      printRVarVal val
      emit ", "
      printRVarVal label
      emit " ]"

printExpr (Op mOp lV rV) = do
  joinedM " " [printMOp mOp, printType $ typeOfVar lV]
  emit " "
  joinedM ", " (map printRVarVal [lV, rV])

printExpr (Cmp cOp lV rV) = do
  joinedM " " [emit "icmp", printCOp cOp, printType $ typeOfVar lV]
  emit " "
  joinedM ", " (map printRVarVal [lV, rV])

printExpr (GetElemPtr isInbounds base deRefs) = do
  emit "getelementptr "
  if isInbounds then emit "inbounds " else return ()
  joinedM ", " ((printType $ dereferenceType $ typeOfVar base):(map printRVar (base:deRefs)))


printMOp :: MachOp -> Printing ()
printMOp MO_Add = emit "add"
printMOp MO_Sub = emit "sub"
printMOp MO_Mul = emit "mul"
printMOp MO_SDiv = emit "sdiv"
printMOp MO_SRem = emit "srem"
printMOp MO_And = emit "and"
printMOp MO_Or = emit "or"
printMOp MO_Xor = emit "xor"


printCOp :: CmpOp -> Printing ()
printCOp CMP_Eq = emit "eq"
printCOp CMP_Ne = emit "ne"
printCOp CMP_Sgt = emit "sgt"
printCOp CMP_Sge = emit "sge"
printCOp CMP_Slt = emit "slt"
printCOp CMP_Sle = emit "sle"