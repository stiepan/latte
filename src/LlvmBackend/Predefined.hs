module LlvmBackend.Predefined where

import LlvmBackend.Llvm


llvmChar = TInt 8
llvmString = TPtr llvmChar
llvmBool = TInt 1
llvmInt = TInt 32


printInt :: Var
printInt = VGlobal (GlobalVar (TFunction funSig) fName)
  where
  funSig = Sig fName TVoid [llvmInt] External
  fName = "printInt"


printString :: Var
printString = VGlobal (GlobalVar (TFunction funSig) fName)
  where
  funSig = Sig fName TVoid [llvmString] External
  fName = "printString"


latteError :: Var
latteError = VGlobal (GlobalVar (TFunction funSig) fName)
  where
  funSig = Sig fName TVoid [] External
  fName = "error"


readInt :: Var
readInt = VGlobal (GlobalVar (TFunction funSig) fName)
  where
  funSig = Sig fName llvmInt [] External
  fName = "readInt"


readString :: Var
readString = VGlobal (GlobalVar (TFunction funSig) fName)
  where
  funSig = Sig fName llvmString [] External
  fName = "readString"


internalConcat :: Var
internalConcat = VGlobal (GlobalVar (TFunction funSig) fName)
  where
  funSig = Sig fName llvmString [llvmString, llvmString] External
  fName = "__concat"


internalStringEq :: Var
internalStringEq = VGlobal (GlobalVar (TFunction funSig) fName)
  where
  funSig = Sig fName llvmBool [llvmString, llvmString] External
  fName = "__strEq"


standardFunctions :: [Var]
standardFunctions = [
  printInt, printString, latteError,
  readInt, readString
  ]


envFunctions :: [Var]
envFunctions = standardFunctions ++ [internalConcat, internalStringEq]
