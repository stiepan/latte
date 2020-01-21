module Frontend.Check where

import qualified AbsLatte
import qualified Frontend.TypeCheck as TypeCheck
import qualified Frontend.RequiredRetCheck as RequiredRetCheck
import qualified Frontend.FoldExpr as FoldExpr
import Frontend.Error
import Common.Ident
import Common.Show


check :: AbsLatte.Program -> Either SemanticError AbsLatte.Program
check program = do
  overloadedProgram <- TypeCheck.check program
--  foldedProgram <- FoldExpr.optimizeByEval $ overloadedProgram
--  RequiredRetCheck.check foldedProgram
  return overloadedProgram
