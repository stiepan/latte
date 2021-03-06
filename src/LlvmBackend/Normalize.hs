module LlvmBackend.Normalize where

import qualified Data.Map.Strict as Map
import qualified Data.Set as Set


import LlvmBackend.Llvm


returnsCorrectly :: Function -> Bool
returnsCorrectly (Func _ _ funcBody) = returnsCorrectlyBs funcBody


returnsCorrectlyBs :: [Block] -> Bool
returnsCorrectlyBs blocks =
  leadingToRet == Set.fromList lBlocks
  where
  lBlocks = map blockId blocks
  ps = blocksPredecessors blocks
  retBlocks = filter isRetBlock blocks
  isRetBlock :: Block -> Bool
  isRetBlock (Block bId stmts) = foldr (\e acc -> isRetStmt e || acc) False stmts
  isRetStmt (Return _) = True
  isRetStmt _ = False
  leadingToRet = foldr (traverseFrom ps) Set.empty (map blockId retBlocks)
  traverseFrom ps node visited = dfs ps [node] visited
  dfs _ [] visited = visited
  dfs ns (q:qs) visited =
    if Set.member q visited then
      dfs ns qs visited
    else
      let neighbours = case Map.lookup q ns of
            Nothing -> []
            Just l -> l
      in
      dfs ns (neighbours ++ qs) (Set.insert q visited)


essentialFunctionOpt :: Function -> Function
essentialFunctionOpt (Func fSig aNames funcBody) =
  Func fSig aNames nFuncBody
  where
    nFuncBody = removeUnreachableBlocks $ map (foldr (.) id optimizations) funcBody
    optimizations = [
      removeUnreachableCodeInBlock
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
        Just block -> traverse (blockSuccessors block ++ labels) (Map.delete label blocksMap)


removeUnreachableCodeInBlock :: Block -> Block
removeUnreachableCodeInBlock block =
  Block (blockId block) (foldr skipUnreachable [] $ blockStmts block)
  where
    skipUnreachable stmt@(Branch _) blockSuf = [stmt]
    skipUnreachable stmt@(BranchIf _ _ _) blockSuf = [stmt]
    skipUnreachable stmt@(Return _) blockSuf = [stmt]
    skipUnreachable stmt blockSuf = stmt:blockSuf


var2Label (VLocal name TLabel) = Label name


blockSuccessors :: Block -> [Label]
blockSuccessors block = foldr branchTargets [] (blockStmts block)
  where
  branchTargets (BranchIf _ labelT labelF) [] = [var2Label labelT, var2Label labelF]
  branchTargets (Branch label) [] = [var2Label label]
  branchTargets _ acc = acc


blocksPredecessors :: [Block] -> Map.Map Label [Label]
blocksPredecessors blocks =
  foldr insertPredecessors (Map.fromList [(blockId block, []) | block <- blocks]) blocks
  where
  insertPredecessors :: Block -> Map.Map Label [Label] -> Map.Map Label [Label]
  insertPredecessors block pMap = foldr addBlockToSuccessor pMap (blockSuccessors block)
    where
      bLabel = blockId block
      addBlockToSuccessor :: Label -> Map.Map Label [Label] -> Map.Map Label [Label]
      addBlockToSuccessor sLabel accMap =
        Map.insert sLabel (bLabel:(accMap Map.! sLabel)) accMap


replaceRegisters :: Map.Map Var Var -> Block -> Block
replaceRegisters subs (Block bId stmts) = Block bId (map rS stmts)
  where
    r var = Map.findWithDefault var var flatSubs
    rS (Assigment var expr) = Assigment (r var) (rE expr)
    rS (Branch var) = Branch (r var)
    rS (BranchIf cond lT lF) = BranchIf (r cond) (r lT) (r lF)
    rS (Store var at) = Store (r var) (r at)
    rS (Return (Just var)) = Return (Just (r var))
    rS (SExp expr) = SExp (rE expr)
    rS s = s

    rE (Op op lV rV) = Op op (r lV) (r rV)
    rE (Cmp op lV rV) = Cmp op (r lV) (r rV)
    rE (Load var) = Load (r var)
    rE (GetElemPtr inbound var vars) = GetElemPtr inbound (r var) (map r vars)
    rE (Call enumerable var vars) = Call enumerable (r var) (map r vars)
    rE (Phi t ops) = Phi t (map (\(v, l) -> (r v, l)) ops)
    rE e = e

    flatSubs = flattenSubs subs
    flattenSubs :: Map.Map Var Var -> Map.Map Var Var
    flattenSubs m = Map.fromList items
      where
        keys = map fst (Map.toList m)
        items = [(k, resolve k m) | k <- keys]
    resolve k m = case Map.lookup k m of
      Nothing -> k
      Just v -> resolve v m