module Frontend.EvalOpt where

import AbsLatte

optimizeByEval :: Program -> Program
optimizeByEval = id


--simplifyExpr :: Expr -> Expr
--simplifyExpr var@(EVar _) = var
--
--simplifyExpr lit@(ELitInt _) = lit
--
--simplifyExpr lit@(ELitTrue _) = lit
--
--simplifyExpr lit@(ELitFalse _) = lit
--
--simplifyExpr lit@(EString _) = lit
--
--simplifyExpr app@(EApp _ _) = app
--
--simplifyExpr (Neg _ (ELitInt n)) = (ELitInt -n)
--
--simplifyExpr (Neg _ exp) = exp
--
--simplifyExpr ()
--             | Not PNot Expr
--             | EMul Expr MulOp Expr
--             | EAdd Expr AddOp Expr
--             | ERel Expr RelOp Expr
--             | EAnd Expr PAnd Expr
--             | EOr Expr POr Expr