module Frontend.Error where

import Common.Ident
import Common.Show
import AbsLatte

--todo check literals overflow
data SemanticError =
  NamesCollision Ident Position Position |
  ArgumentTypeMismatch Ident Position Int Type Type |
  UnexpectedType Type Type Position |
  InvalidTypeInThisContext Type Position |
  UnexpectedTypeLeftOperand Type Type Position |
  UnexpectedTypeRightOperand Type Type Position |
  UndefinedIdent Ident Position |
  UndefinedProcIdent Ident Position |
  InvalidNumberOfArguments Ident Position |
  NotCallable Ident Position |
  ReturnOutsideProcedure Position | -- actually grammar doesn't allow that
  ReturnTypeMismatch Type Type Position |
  DivisionByZero Position |
  ProcWithoutReturn Ident |
  MainNotFound |
  MainSignatureMismatch Type |
  InternalError String Position


instance Show SemanticError where
  show (NamesCollision ident currentPos prevPos) =
    spaceSep ["Declaration of", show ident, "at", show currentPos, "clashes with declaration at", show prevPos]
  show (ArgumentTypeMismatch fName appPosition argOrd expType actType) =
    spaceSep ["Argument type mismatch. Function", show fName, "called from",
      show appPosition, "expects", showType expType, "as", show argOrd, "argument.",
      "Got", showType actType, "instead."]
  show (UnexpectedType expType actType pos) =
    spaceSep ["Type mismatch at", show pos, "-", "expected",
      showType expType, "got", showType actType, "instead."]
  show (InvalidTypeInThisContext actType pos) =
    spaceSep ["Type", showType actType, "is not allowed in this context at", show pos]
  show (UnexpectedTypeLeftOperand expType actType pos) =
      spaceSep ["Type mismatch in left operand at", show pos, "-", "expected",
        showType expType, "got", showType actType, "instead."]
  show (UnexpectedTypeRightOperand expType actType pos) =
        spaceSep ["Type mismatch in left operand at", show pos, "-", "expected",
          showType expType, "got", showType actType, "instead."]
  show (UndefinedIdent ident pos) =
    spaceSep ["Usage of undefined variable", show ident, "at", show pos]
  show (UndefinedProcIdent ident pos) =
    spaceSep ["Usage of undefined procedure", show ident, "at", show pos]
  show (InvalidNumberOfArguments ident pos) =
    spaceSep ["Invalid number of arguments in the call of", show ident, "at", show pos]
  show (NotCallable ident pos) =
    spaceSep [show ident, "called from", show pos, "is not a function"]
  show (ReturnOutsideProcedure pos) =
    spaceSep ["Error at", show pos, "- return is not allowed outside the procedure"]
  show (ReturnTypeMismatch expType actType pos) =
      spaceSep ["Cannot return value of type", showType actType,
        "from the procedure. Expected", showType expType, "at", show pos]
  show (MainNotFound) = "Required procedure 'main' not found"
  show (MainSignatureMismatch actType) =
    spaceSep ["Procedure main declared with type", showType actType, "- expected int()"]
  show (InternalError str pos) =
    spaceSep ["Internal compiler error: ", str, "at", show pos]
  show (DivisionByZero pos) =
    spaceSep ["Division by zero at: ", show pos]
  show (ProcWithoutReturn pIdent) =
    spaceSep ["Procedure", show pIdent, "exits without returning anything or might never exit"]
