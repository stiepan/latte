module Frontend.Check where

import qualified AbsLatte
import qualified Frontend.TypeCheck as TypeCheck
import qualified Frontend.TypeCheck as RequiredRetCheck
import qualified Frontend.EvalOpt as EvalOpt
import Frontend.Error
import Frontend.Common


check :: AbsLatte.Program -> Either SemanticError AbsLatte.Program
check program = do
  TypeCheck.check program
  let optimizedProg = EvalOpt.optimizeByEval $ program
  RequiredRetCheck.check optimizedProg
  return optimizedProg


--check program =
--  case TypeCheck.check program of
--    Left e -> Left e
--    Right _ -> Right $ EvalOpt.optimizeByEval $ program
