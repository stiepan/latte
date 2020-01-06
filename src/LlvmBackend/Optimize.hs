module LlvmBackend.Optimize where

import qualified Data.Map.Strict as Map

import LlvmBackend.Llvm


essentialOpt :: Module -> Module
essentialOpt (Module gs fDs fs) =
  Module gs fDs (map essentialFunctionOpt fs)


essentialFunctionOpt :: Function -> Function
essentialFunctionOpt (Func fSig aNames funcBody) =
  Func fSig aNames nFuncBody
  where
    nFuncBody = removeUnreachableBlocks $ map (foldr (.) id optimizations) funcBody
    optimizations = [
      removeUnreachableCodeInBlock,
      replaceBranchIfWithBranch
      ]


removeUnreachableBlocks :: [Block] -> [Block]
removeUnreachableBlocks [] = []
removeUnreachableBlocks blocks@(eB:bs) =
  filter (\block -> not (Map.member (blockId block) unreachable)) blocks
  where
    unreachable = traverse [blockId eB] (Map.fromList [(blockId block, block) | block <- blocks])
    traverse [] blocksMap = blocksMap
    traverse (label:labels) blocksMap =
      case Map.lookup label blocksMap of
        Nothing -> traverse labels blocksMap
        Just block -> traverse ((neighbours (blockStmts block)) ++ labels) (Map.delete label blocksMap)

    neighbours :: [Statement] -> [Label]
    neighbours = foldr branchTargets []
      where
      branchTargets (BranchIf _ labelT labelF) [] = [var2Label labelT, var2Label labelF]
      branchTargets (Branch label) [] = [var2Label label]
      branchTargets _ acc = acc


replaceBranchIfWithBranch :: Block -> Block
replaceBranchIfWithBranch (Block bId bStmts) =
  (Block bId (map foldBranchIf bStmts))
  where
    foldBranchIf stmt@(BranchIf (VLit (LInt 1 n)) lT lF) = Branch (pickLabel n lT lF)
    foldBranchIf stmt = stmt
    pickLabel 0 _ lF = lF
    pickLabel _ lT _ = lT


removeUnreachableCodeInBlock :: Block -> Block
removeUnreachableCodeInBlock block =
  Block (blockId block) (foldr skipUnreachable [] $ blockStmts block)
  where
    skipUnreachable stmt@(Branch _) blockSuf = [stmt]
    skipUnreachable stmt@(BranchIf _ _ _) blockSuf = [stmt]
    skipUnreachable stmt@(Return _) blockSuf = [stmt]
    skipUnreachable stmt blockSuf = stmt:blockSuf


var2Label (VLocal name TLabel) = Label name