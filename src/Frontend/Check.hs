module Frontend.Check where

import qualified AbsLatte
import qualified Frontend.TypeCheck as TypeCheck
import qualified Frontend.RequiredRetCheck as RequiredRetCheck
import qualified Frontend.EvalOpt as EvalOpt
import Frontend.Error
import Frontend.Common


check :: AbsLatte.Program -> Either SemanticError AbsLatte.Program
check program = do
  TypeCheck.check program
  optimizedProg <- EvalOpt.optimizeByEval $ program
  RequiredRetCheck.check optimizedProg
  return optimizedProg

