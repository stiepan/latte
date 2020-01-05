module LlvmBackend.Optimize where

import LlvmBackend.Llvm


essentialOpt :: Module -> Module
essentialOpt (Module gs fDs fs) =
  Module gs fDs (map essentialFunctionOpt fs)


essentialFunctionOpt :: Function -> Function
essentialFunctionOpt (Func fSig aNames funcBody) =
  Func fSig aNames nFuncBody
  where
    nFuncBody = map removeUnreachableCodeInBlock funcBody


removeUnreachableCodeInBlock :: Block -> Block
removeUnreachableCodeInBlock block =
  Block (blockId block) (foldr skipUnreachable [] $ blockStmts block)
  where
    skipUnreachable stmt@(Branch _) blockSuf = [stmt]
    skipUnreachable stmt@(BranchIf _ _ _) blockSuf = [stmt]
    skipUnreachable stmt@(Return _) blockSuf = [stmt]
    skipUnreachable stmt blockSuf = stmt:blockSuf