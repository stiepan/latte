

module AbsLatte where

-- Haskell module generated by the BNF converter




newtype POpenBlock = POpenBlock ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PCloseBlock = PCloseBlock ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PIf = PIf ((Int,Int),String) deriving (Eq, Ord, Show, Read)
newtype PElse = PElse ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PWhile = PWhile ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PReturn = PReturn ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PTrue = PTrue ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PFalse = PFalse ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PEQU = PEQU ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PLE = PLE ((Int,Int),String) deriving (Eq, Ord, Show, Read)
newtype PGE = PGE ((Int,Int),String) deriving (Eq, Ord, Show, Read)
newtype PNE = PNE ((Int,Int),String) deriving (Eq, Ord, Show, Read)
newtype PAnd = PAnd ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype POr = POr ((Int,Int),String) deriving (Eq, Ord, Show, Read)
newtype PMinus = PMinus ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PNot = PNot ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PPlus = PPlus ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PTimes = PTimes ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PDiv = PDiv ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PMod = PMod ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PLTH = PLTH ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PGTH = PGTH ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
newtype PIdent = PIdent ((Int,Int),String)
  deriving (Eq, Ord, Show, Read)
data Program = Program [TopDef]
  deriving (Eq, Ord, Show, Read)

data TopDef = FnDef Type PIdent [Arg] Block
  deriving (Eq, Ord, Show, Read)

data Arg = Arg Type PIdent
  deriving (Eq, Ord, Show, Read)

data Block = Block POpenBlock [Stmt] PCloseBlock
  deriving (Eq, Ord, Show, Read)

data Stmt
    = Empty
    | BStmt Block
    | Decl Type [Item]
    | Ass PIdent Expr
    | Incr PIdent
    | Decr PIdent
    | Ret PReturn Expr
    | VRet PReturn
    | Cond PIf Expr Stmt
    | CondElse PIf Expr Stmt PElse Stmt
    | While PWhile Expr Stmt
    | SExp Expr
  deriving (Eq, Ord, Show, Read)

data Item = NoInit PIdent | Init PIdent Expr
  deriving (Eq, Ord, Show, Read)

data Type = Int | Str | Bool | Void | Fun Type [Type]
  deriving (Eq, Ord, Show, Read)

data Expr
    = EVar PIdent
    | ELitInt Integer
    | ELitTrue
    | ELitFalse
    | EApp PIdent [Expr]
    | EString String
    | Neg PMinus Expr
    | Not PNot Expr
    | EMul Expr MulOp Expr
    | EAdd Expr AddOp Expr
    | ERel Expr RelOp Expr
    | EAnd Expr PAnd Expr
    | EOr Expr POr Expr
  deriving (Eq, Ord, Show, Read)

data AddOp = Plus PPlus | Minus PMinus
  deriving (Eq, Ord, Show, Read)

data MulOp = Times PTimes | Div PDiv | Mod PMod
  deriving (Eq, Ord, Show, Read)

data RelOp
    = LTH PLTH | LE PLE | GTH PGTH | GE PGE | EQU PEQU | NE PNE
  deriving (Eq, Ord, Show, Read)

