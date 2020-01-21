module Frontend.Check where

import qualified AbsLatte
import qualified Frontend.TypeCheck as TypeCheck
import Frontend.Error
import Common.Ident
import Common.Show


check :: AbsLatte.Program -> Either SemanticError AbsLatte.Program
check program = do
  overloadedProgram <- TypeCheck.check program
  return overloadedProgram
