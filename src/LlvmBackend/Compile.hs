module LlvmBackend.Compile where

import qualified AbsLatte as Latte

import LlvmBackend.Llvm


compile :: Latte.Program -> Module
compile _ = Module [] [] []