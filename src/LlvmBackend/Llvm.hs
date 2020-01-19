module LlvmBackend.Llvm where
-- subset of llvm's abstract grammar
-- based on https://www.stackage.org/haddock/lts-14.12/ghc-8.6.5/Llvm.html


data Module = Module {
  globals :: [GlobalVarDef],
  forwardDecls :: [Signature],
  functions :: [Function]
} deriving (Show, Eq)


data LinkageType = Internal | External | Private deriving (Show, Eq, Ord)


data GlobalVarDef = GConstDef LinkageType GlobalVar StaticLit deriving (Show, Eq, Ord)


data GlobalVar = GlobalVar Type String deriving (Show, Eq, Ord)


data StaticLit = StaticLit Lit | StaticStr String deriving (Show, Eq, Ord)


data Type = TVoid | TInt Integer | TPtr Type | TArray Integer Type |
  TLabel | TFunction Signature deriving (Show, Eq, Ord)


data Var = VGlobal GlobalVar | VLocal String Type | VLit Lit deriving (Show, Eq, Ord)


data Lit = LInt Integer Integer | Null deriving (Show, Eq, Ord)


newtype Label = Label String deriving (Show, Eq, Ord)


data Block = Block {
  blockId :: Label,
  blockStmts :: [Statement]
} deriving (Show, Eq, Ord)


data Signature = Sig {
  funcName :: String,
  retType :: Type,
  argTypes :: [Type],
  funLinkage :: LinkageType
} deriving (Show, Eq, Ord)


data Function = Func {
  funcSig :: Signature,
  argNames :: [String],
  funcBody :: [Block]
} deriving (Show, Eq, Ord)


data MachOp = MO_Add | MO_Sub | MO_Mul | MO_SDiv |
  MO_SRem | MO_And | MO_Or | MO_Xor deriving (Show, Eq, Ord)


data CmpOp = CMP_Eq | CMP_Ne | CMP_Sgt | CMP_Sge |
  CMP_Slt | CMP_Sle deriving (Show, Eq, Ord)


data Expr = Alloca Integer Type | Op MachOp Var Var | Cmp CmpOp Var Var |
  Load Var | GetElemPtr Bool Var [Var] | Call Var [Var] |
  Phi Type [(Var, Var)] | Undefined deriving (Show, Eq, Ord)
  --BitCast Var Type


data Statement = Assigment Var Expr | Branch Var | BranchIf Var Var Var |
  Store Var Var | Return (Maybe Var) | NOp | SExp Expr deriving (Show, Eq, Ord)
