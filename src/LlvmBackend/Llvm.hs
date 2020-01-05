module LlvmBackend.Llvm where
-- subset of llvm's abstract grammar
-- based on https://www.stackage.org/haddock/lts-14.12/ghc-8.6.5/Llvm.html


data Module = Module {
  globals :: [GlobalVarDef],
  forwardDecls :: [Signature],
  functions :: [Function]
} deriving (Show, Eq)


data LinkageType = Internal | External | Private deriving (Show, Eq)


data GlobalVarDef = GConstDef LinkageType GlobalVar StaticLit deriving (Show, Eq)


data GlobalVar = GlobalVar Type String deriving (Show, Eq)


data StaticLit = StaticLit Lit | StaticStr String deriving (Show, Eq)


data Type = TVoid | TInt Integer | TPtr Type | TArray Integer Type |
  TLabel | TFunction Signature deriving (Show, Eq)


data Var = VGlobal GlobalVar | VLocal String Type | VLit Lit deriving (Show, Eq)


data Lit = LInt Integer Integer deriving (Show, Eq)


newtype Label = Label String deriving (Show, Eq)


data Block = Block {
  blockId :: Label,
  blockStmts :: [Statement]
} deriving (Show, Eq)


data Signature = Sig {
  funcName :: String,
  retType :: Type,
  argTypes :: [Type],
  funLinkage :: LinkageType -- external by default, todo omit external when printed
} deriving (Show, Eq)


data Function = Func {
  funcSig :: Signature,
  argNames :: [String],
  funcBody :: [Block]
} deriving (Show, Eq)


data MachOp = MO_Add | MO_Sub | MO_Mul | MO_SDiv |
  MO_SRem | MO_And | MO_Or | MO_Xor deriving (Show, Eq)


data CmpOp = CMP_Eq | CMP_Ne | CMP_Sgt | CMP_Sge |
  CMP_Slt | CMP_Sle deriving (Show, Eq)


data Expr = Alloca Integer Type | Op MachOp Var Var | Cmp CmpOp Var Var |
  Load Var | GetElemPtr Bool Var [Var] | BitCast Var Type | Call Var [Var] |
  Phi Type [(Var, Var)] deriving (Show, Eq)


data Statement = Assigment Var Expr | Branch Var | BranchIf Var Var Var |
  Store Var Var | Return (Maybe Var) | NOp deriving (Show, Eq)
