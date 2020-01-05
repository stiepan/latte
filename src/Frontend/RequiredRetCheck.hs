module Frontend.RequiredRetCheck where

import Frontend.Error
import Common.Ident
import Common.Show
import AbsLatte


check :: Program -> Either SemanticError ()
check (Program ts) = mapM_ checkTD ts


checkTD :: TopDef -> Either SemanticError ()
checkTD (FnDef rType pIdent _ block)
  | rType == Void || retStmt (BStmt block) = Right ()
  | otherwise =
    let (Block _ _ (PCloseBlock (pos, _))) = block
        (ident, _) = pIdent2Ident pIdent in
      Left $ ProcExitWithoutReturn ident (p2Pos pos)


retStmt :: Stmt -> Bool
retStmt (Ret _ _) = True

retStmt (VRet _) = True

retStmt (BStmt (Block _ stmts _)) = foldr (||) False (map retStmt stmts)

retStmt (CondElse _ _ ifStmt _ elStmt) = (retStmt ifStmt) && (retStmt elStmt)

retStmt (While _ exp stmt) = exp == ELitTrue && retStmt stmt

retStmt stmt = False
