{-# OPTIONS_GHC -w #-}
{-# OPTIONS -XMagicHash -XBangPatterns -XTypeSynonymInstances -XFlexibleInstances -cpp #-}
#if __GLASGOW_HASKELL__ >= 710
{-# OPTIONS_GHC -XPartialTypeSignatures #-}
#endif
{-# OPTIONS_GHC -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
module ParLatte where
import AbsLatte
import LexLatte
import ErrM
import qualified Data.Array as Happy_Data_Array
import qualified Data.Bits as Bits
import qualified GHC.Exts as Happy_GHC_Exts
import Control.Applicative(Applicative(..))
import Control.Monad (ap)

-- parser produced by Happy Version 1.19.8

newtype HappyAbsSyn  = HappyAbsSyn HappyAny
#if __GLASGOW_HASKELL__ >= 607
type HappyAny = Happy_GHC_Exts.Any
#else
type HappyAny = forall a . a
#endif
happyIn4 :: (POpenBlock) -> (HappyAbsSyn )
happyIn4 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn4 #-}
happyOut4 :: (HappyAbsSyn ) -> (POpenBlock)
happyOut4 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut4 #-}
happyIn5 :: (PCloseBlock) -> (HappyAbsSyn )
happyIn5 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn5 #-}
happyOut5 :: (HappyAbsSyn ) -> (PCloseBlock)
happyOut5 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut5 #-}
happyIn6 :: (PIf) -> (HappyAbsSyn )
happyIn6 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn6 #-}
happyOut6 :: (HappyAbsSyn ) -> (PIf)
happyOut6 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut6 #-}
happyIn7 :: (PElse) -> (HappyAbsSyn )
happyIn7 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn7 #-}
happyOut7 :: (HappyAbsSyn ) -> (PElse)
happyOut7 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut7 #-}
happyIn8 :: (PWhile) -> (HappyAbsSyn )
happyIn8 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn8 #-}
happyOut8 :: (HappyAbsSyn ) -> (PWhile)
happyOut8 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut8 #-}
happyIn9 :: (PReturn) -> (HappyAbsSyn )
happyIn9 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn9 #-}
happyOut9 :: (HappyAbsSyn ) -> (PReturn)
happyOut9 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut9 #-}
happyIn10 :: (PTrue) -> (HappyAbsSyn )
happyIn10 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn10 #-}
happyOut10 :: (HappyAbsSyn ) -> (PTrue)
happyOut10 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut10 #-}
happyIn11 :: (PFalse) -> (HappyAbsSyn )
happyIn11 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn11 #-}
happyOut11 :: (HappyAbsSyn ) -> (PFalse)
happyOut11 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut11 #-}
happyIn12 :: (PEQU) -> (HappyAbsSyn )
happyIn12 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn12 #-}
happyOut12 :: (HappyAbsSyn ) -> (PEQU)
happyOut12 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut12 #-}
happyIn13 :: (PLE) -> (HappyAbsSyn )
happyIn13 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn13 #-}
happyOut13 :: (HappyAbsSyn ) -> (PLE)
happyOut13 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut13 #-}
happyIn14 :: (PGE) -> (HappyAbsSyn )
happyIn14 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn14 #-}
happyOut14 :: (HappyAbsSyn ) -> (PGE)
happyOut14 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut14 #-}
happyIn15 :: (PNE) -> (HappyAbsSyn )
happyIn15 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn15 #-}
happyOut15 :: (HappyAbsSyn ) -> (PNE)
happyOut15 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut15 #-}
happyIn16 :: (PAnd) -> (HappyAbsSyn )
happyIn16 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn16 #-}
happyOut16 :: (HappyAbsSyn ) -> (PAnd)
happyOut16 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut16 #-}
happyIn17 :: (POr) -> (HappyAbsSyn )
happyIn17 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn17 #-}
happyOut17 :: (HappyAbsSyn ) -> (POr)
happyOut17 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut17 #-}
happyIn18 :: (PMinus) -> (HappyAbsSyn )
happyIn18 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn18 #-}
happyOut18 :: (HappyAbsSyn ) -> (PMinus)
happyOut18 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut18 #-}
happyIn19 :: (PNot) -> (HappyAbsSyn )
happyIn19 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn19 #-}
happyOut19 :: (HappyAbsSyn ) -> (PNot)
happyOut19 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut19 #-}
happyIn20 :: (PPlus) -> (HappyAbsSyn )
happyIn20 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn20 #-}
happyOut20 :: (HappyAbsSyn ) -> (PPlus)
happyOut20 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut20 #-}
happyIn21 :: (PTimes) -> (HappyAbsSyn )
happyIn21 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn21 #-}
happyOut21 :: (HappyAbsSyn ) -> (PTimes)
happyOut21 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut21 #-}
happyIn22 :: (PDiv) -> (HappyAbsSyn )
happyIn22 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn22 #-}
happyOut22 :: (HappyAbsSyn ) -> (PDiv)
happyOut22 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut22 #-}
happyIn23 :: (PMod) -> (HappyAbsSyn )
happyIn23 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn23 #-}
happyOut23 :: (HappyAbsSyn ) -> (PMod)
happyOut23 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut23 #-}
happyIn24 :: (PLTH) -> (HappyAbsSyn )
happyIn24 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn24 #-}
happyOut24 :: (HappyAbsSyn ) -> (PLTH)
happyOut24 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut24 #-}
happyIn25 :: (PGTH) -> (HappyAbsSyn )
happyIn25 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn25 #-}
happyOut25 :: (HappyAbsSyn ) -> (PGTH)
happyOut25 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut25 #-}
happyIn26 :: (PString) -> (HappyAbsSyn )
happyIn26 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn26 #-}
happyOut26 :: (HappyAbsSyn ) -> (PString)
happyOut26 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut26 #-}
happyIn27 :: (PInteger) -> (HappyAbsSyn )
happyIn27 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn27 #-}
happyOut27 :: (HappyAbsSyn ) -> (PInteger)
happyOut27 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut27 #-}
happyIn28 :: (PIdent) -> (HappyAbsSyn )
happyIn28 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn28 #-}
happyOut28 :: (HappyAbsSyn ) -> (PIdent)
happyOut28 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut28 #-}
happyIn29 :: (Program) -> (HappyAbsSyn )
happyIn29 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn29 #-}
happyOut29 :: (HappyAbsSyn ) -> (Program)
happyOut29 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut29 #-}
happyIn30 :: (TopDef) -> (HappyAbsSyn )
happyIn30 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn30 #-}
happyOut30 :: (HappyAbsSyn ) -> (TopDef)
happyOut30 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut30 #-}
happyIn31 :: ([TopDef]) -> (HappyAbsSyn )
happyIn31 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn31 #-}
happyOut31 :: (HappyAbsSyn ) -> ([TopDef])
happyOut31 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut31 #-}
happyIn32 :: (Arg) -> (HappyAbsSyn )
happyIn32 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn32 #-}
happyOut32 :: (HappyAbsSyn ) -> (Arg)
happyOut32 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut32 #-}
happyIn33 :: ([Arg]) -> (HappyAbsSyn )
happyIn33 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn33 #-}
happyOut33 :: (HappyAbsSyn ) -> ([Arg])
happyOut33 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut33 #-}
happyIn34 :: (Block) -> (HappyAbsSyn )
happyIn34 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn34 #-}
happyOut34 :: (HappyAbsSyn ) -> (Block)
happyOut34 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut34 #-}
happyIn35 :: ([Stmt]) -> (HappyAbsSyn )
happyIn35 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn35 #-}
happyOut35 :: (HappyAbsSyn ) -> ([Stmt])
happyOut35 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut35 #-}
happyIn36 :: (Stmt) -> (HappyAbsSyn )
happyIn36 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn36 #-}
happyOut36 :: (HappyAbsSyn ) -> (Stmt)
happyOut36 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut36 #-}
happyIn37 :: (Item) -> (HappyAbsSyn )
happyIn37 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn37 #-}
happyOut37 :: (HappyAbsSyn ) -> (Item)
happyOut37 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut37 #-}
happyIn38 :: ([Item]) -> (HappyAbsSyn )
happyIn38 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn38 #-}
happyOut38 :: (HappyAbsSyn ) -> ([Item])
happyOut38 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut38 #-}
happyIn39 :: (Type) -> (HappyAbsSyn )
happyIn39 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn39 #-}
happyOut39 :: (HappyAbsSyn ) -> (Type)
happyOut39 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut39 #-}
happyIn40 :: ([Type]) -> (HappyAbsSyn )
happyIn40 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn40 #-}
happyOut40 :: (HappyAbsSyn ) -> ([Type])
happyOut40 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut40 #-}
happyIn41 :: (Expr) -> (HappyAbsSyn )
happyIn41 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn41 #-}
happyOut41 :: (HappyAbsSyn ) -> (Expr)
happyOut41 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut41 #-}
happyIn42 :: (Expr) -> (HappyAbsSyn )
happyIn42 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn42 #-}
happyOut42 :: (HappyAbsSyn ) -> (Expr)
happyOut42 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut42 #-}
happyIn43 :: (Expr) -> (HappyAbsSyn )
happyIn43 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn43 #-}
happyOut43 :: (HappyAbsSyn ) -> (Expr)
happyOut43 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut43 #-}
happyIn44 :: (Expr) -> (HappyAbsSyn )
happyIn44 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn44 #-}
happyOut44 :: (HappyAbsSyn ) -> (Expr)
happyOut44 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut44 #-}
happyIn45 :: (Expr) -> (HappyAbsSyn )
happyIn45 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn45 #-}
happyOut45 :: (HappyAbsSyn ) -> (Expr)
happyOut45 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut45 #-}
happyIn46 :: (Expr) -> (HappyAbsSyn )
happyIn46 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn46 #-}
happyOut46 :: (HappyAbsSyn ) -> (Expr)
happyOut46 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut46 #-}
happyIn47 :: (Expr) -> (HappyAbsSyn )
happyIn47 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn47 #-}
happyOut47 :: (HappyAbsSyn ) -> (Expr)
happyOut47 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut47 #-}
happyIn48 :: ([Expr]) -> (HappyAbsSyn )
happyIn48 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn48 #-}
happyOut48 :: (HappyAbsSyn ) -> ([Expr])
happyOut48 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut48 #-}
happyIn49 :: (AddOp) -> (HappyAbsSyn )
happyIn49 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn49 #-}
happyOut49 :: (HappyAbsSyn ) -> (AddOp)
happyOut49 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut49 #-}
happyIn50 :: (MulOp) -> (HappyAbsSyn )
happyIn50 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn50 #-}
happyOut50 :: (HappyAbsSyn ) -> (MulOp)
happyOut50 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut50 #-}
happyIn51 :: (RelOp) -> (HappyAbsSyn )
happyIn51 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyIn51 #-}
happyOut51 :: (HappyAbsSyn ) -> (RelOp)
happyOut51 x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOut51 #-}
happyInTok :: (Token) -> (HappyAbsSyn )
happyInTok x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyInTok #-}
happyOutTok :: (HappyAbsSyn ) -> (Token)
happyOutTok x = Happy_GHC_Exts.unsafeCoerce# x
{-# INLINE happyOutTok #-}


happyExpList :: HappyAddr
happyExpList = HappyA# "\x00\x00\x00\x00\x00\x00\x00\x3c\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x3c\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x3c\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x3c\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\xfd\x3d\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x01\x30\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x30\x00\x70\x00\x00\x00\x00\x00\x00\x08\x00\x30\x00\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xa8\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x80\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x50\x00\x00\x00\x00\x00\x00\x00\x00\x00\xc0\x07\x0c\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x30\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x30\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x30\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x30\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x30\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x30\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x30\x30\x70\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x30\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x30\x30\x70\x00\x00\x00\x00\x00\x00\x08\x00\x30\x30\x70\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x00\x00\x00\x08\x00\x30\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x80\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x50\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x00\x30\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x7d\x3d\x30\x70\x00\x00\x00\x00\x00\x00\x08\x7d\x3d\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\x7d\x3d\x30\x70\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"#

{-# NOINLINE happyExpListPerState #-}
happyExpListPerState st =
    token_strs_expected
  where token_strs = ["error","%dummy","%start_pProgram","POpenBlock","PCloseBlock","PIf","PElse","PWhile","PReturn","PTrue","PFalse","PEQU","PLE","PGE","PNE","PAnd","POr","PMinus","PNot","PPlus","PTimes","PDiv","PMod","PLTH","PGTH","PString","PInteger","PIdent","Program","TopDef","ListTopDef","Arg","ListArg","Block","ListStmt","Stmt","Item","ListItem","Type","ListType","Expr6","Expr5","Expr4","Expr3","Expr2","Expr1","Expr","ListExpr","AddOp","MulOp","RelOp","'('","')'","'++'","','","'--'","';'","'='","'boolean'","'int'","'string'","'void'","L_POpenBlock","L_PCloseBlock","L_PIf","L_PElse","L_PWhile","L_PReturn","L_PTrue","L_PFalse","L_PEQU","L_PLE","L_PGE","L_PNE","L_PAnd","L_POr","L_PMinus","L_PNot","L_PPlus","L_PTimes","L_PDiv","L_PMod","L_PLTH","L_PGTH","L_PString","L_PInteger","L_PIdent","%eof"]
        bit_start = st * 88
        bit_end = (st + 1) * 88
        read_bit = readArrayBit happyExpList
        bits = map read_bit [bit_start..bit_end - 1]
        bits_indexed = zip bits [0..87]
        token_strs_expected = concatMap f bits_indexed
        f (False, _) = []
        f (True, nr) = [token_strs !! nr]

happyActOffsets :: HappyAddr
happyActOffsets = HappyA# "\xac\x00\x0f\x00\x00\x00\xfb\xff\xac\x00\x00\x00\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00\x34\x00\x00\x00\x00\x00\xac\x00\x36\x00\x3b\x00\x1d\x00\x00\x00\x40\x00\xac\x00\x00\x00\x00\x00\x00\x00\xa5\x01\x00\x00\x41\x00\x4d\x00\xd2\x01\x00\x00\x00\x00\x50\x00\x50\x00\x00\x00\x00\x00\x11\x02\x00\x00\x00\x00\x2b\x00\x00\x00\x00\x00\xec\xff\x14\x00\x79\x00\x48\x00\x54\x00\x24\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x63\x00\x6c\x00\x00\x00\x24\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x24\x00\x00\x00\x00\x00\x24\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x24\x00\x00\x00\x00\x00\x00\x00\x00\x00\x24\x00\x00\x00\x00\x00\x00\x00\x6f\x00\x74\x00\x75\x00\x24\x00\x77\x00\x82\x00\x24\x00\x00\x00\x00\x00\x8c\x00\x00\x00\x24\x00\x24\x00\x78\x00\x93\x00\x00\x00\x90\x00\x00\x00\x00\x00\x9d\x00\xa0\x00\x00\x00\x80\x00\x24\x00\x00\x00\xec\xff\x14\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x24\x00\x00\x00\xc4\x01\xc4\x01\x98\x00\x00\x00\x00\x00\xc4\x01\x00\x00\x00\x00\x00\x00"#

happyGotoOffsets :: HappyAddr
happyGotoOffsets = HappyA# "\xf3\xff\x00\x00\x00\x00\x00\x00\x52\x00\x00\x00\x91\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x7b\x00\x00\x00\x00\x00\x9b\x00\x00\x00\x04\x00\x83\x00\x00\x00\x99\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\xdd\x00\x00\x00\x00\x00\xc2\x00\xf3\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x28\x00\x00\x00\x00\x00\x58\x00\x0c\x00\x09\x00\xae\x00\x00\x00\xe8\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x0e\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x7b\x01\x00\x00\x00\x00\xd3\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xf6\x01\x00\x00\x00\x00\x00\x00\x00\x00\xf9\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xab\x00\x00\x00\x00\x00\x19\x01\x00\x00\x00\x00\x00\x00\x00\x00\x3f\x01\x4a\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x44\x00\x70\x01\x00\x00\x58\x00\x0c\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xb6\x00\x00\x00\x2d\x00\x59\x00\xbb\x00\x00\x00\x00\x00\x85\x00\x00\x00\x00\x00\x00\x00"#

happyAdjustOffset :: Happy_GHC_Exts.Int# -> Happy_GHC_Exts.Int#
happyAdjustOffset off = off

happyDefActions :: HappyAddr
happyDefActions = HappyA# "\x00\x00\x00\x00\xfe\xff\x00\x00\xe3\xff\xe5\xff\x00\x00\xc8\xff\xca\xff\xc9\xff\xc7\xff\x00\x00\xe6\xff\xe2\xff\xe0\xff\xdf\xff\x00\x00\x00\x00\xe1\xff\x00\x00\xe0\xff\xde\xff\xdc\xff\xe4\xff\x00\x00\xdd\xff\x00\x00\x00\x00\x00\x00\xc1\xff\xc0\xff\x00\x00\x00\x00\xbe\xff\xc2\xff\xc3\xff\xd9\xff\xdb\xff\x00\x00\xba\xff\xb8\xff\xb6\xff\xb4\xff\xb2\xff\xb0\xff\x00\x00\x00\x00\xda\xff\xfd\xff\xfc\xff\xfa\xff\xf9\xff\xf8\xff\xf7\xff\xf0\xff\xef\xff\xe8\xff\xe7\xff\xc3\xff\x00\x00\xcf\xff\x00\x00\xf1\xff\xa3\xff\xa6\xff\xa4\xff\xa2\xff\x00\x00\xa7\xff\xa5\xff\x00\x00\xf6\xff\xf5\xff\xf4\xff\xf3\xff\xf2\xff\xea\xff\xe9\xff\xab\xff\xac\xff\x00\x00\xee\xff\xaa\xff\xa9\xff\xa8\xff\x00\x00\xed\xff\xec\xff\xeb\xff\xce\xff\xcc\xff\x00\x00\xaf\xff\x00\x00\x00\x00\x00\x00\xbb\xff\xbc\xff\x00\x00\xd3\xff\x00\x00\x00\x00\x00\x00\x00\x00\xd4\xff\x00\x00\xd5\xff\xd6\xff\xae\xff\x00\x00\xd8\xff\x00\x00\x00\x00\xb9\xff\xb7\xff\xb5\xff\xb3\xff\xb1\xff\xbd\xff\xcd\xff\xcb\xff\xbf\xff\xaf\xff\xd7\xff\x00\x00\x00\x00\xd2\xff\xd0\xff\xad\xff\x00\x00\xfb\xff\xd1\xff"#

happyCheck :: HappyAddr
happyCheck = HappyA# "\xff\xff\x00\x00\x01\x00\x02\x00\x00\x00\x04\x00\x05\x00\x06\x00\x07\x00\x1d\x00\x1e\x00\x1f\x00\x19\x00\x1a\x00\x1b\x00\x0e\x00\x0f\x00\x08\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x23\x00\x16\x00\x17\x00\x18\x00\x0e\x00\x0c\x00\x10\x00\x14\x00\x15\x00\x1e\x00\x25\x00\x20\x00\x1e\x00\x24\x00\x23\x00\x01\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x00\x00\x1a\x00\x02\x00\x1c\x00\x04\x00\x05\x00\x06\x00\x07\x00\x01\x00\x12\x00\x13\x00\x2f\x00\x2d\x00\x04\x00\x0e\x00\x0f\x00\x02\x00\x1a\x00\x1b\x00\x18\x00\x24\x00\x01\x00\x16\x00\x17\x00\x18\x00\x22\x00\x23\x00\x24\x00\x21\x00\x22\x00\x1e\x00\x0c\x00\x20\x00\x01\x00\x24\x00\x23\x00\x01\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x00\x00\x06\x00\x02\x00\x18\x00\x04\x00\x05\x00\x06\x00\x07\x00\x19\x00\x12\x00\x13\x00\x01\x00\x21\x00\x22\x00\x0e\x00\x0f\x00\x11\x00\x12\x00\x13\x00\x1a\x00\x1b\x00\x02\x00\x16\x00\x17\x00\x18\x00\x22\x00\x23\x00\x24\x00\x23\x00\x07\x00\x1e\x00\x04\x00\x20\x00\x02\x00\x06\x00\x23\x00\x06\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x00\x00\x2e\x00\x02\x00\x06\x00\x04\x00\x05\x00\x06\x00\x07\x00\x14\x00\x15\x00\x16\x00\x17\x00\x18\x00\x06\x00\x0e\x00\x0f\x00\x02\x00\x06\x00\x1c\x00\x1d\x00\x20\x00\x21\x00\x16\x00\x17\x00\x18\x00\x23\x00\x1c\x00\x1d\x00\x04\x00\x02\x00\x1e\x00\x24\x00\x20\x00\x23\x00\x0f\x00\x23\x00\x18\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x06\x00\x07\x00\x18\x00\x08\x00\x09\x00\x0a\x00\x0b\x00\x1f\x00\x0e\x00\x0f\x00\x0d\x00\x06\x00\x07\x00\x03\x00\xff\xff\xff\xff\x16\x00\x17\x00\x18\x00\x0e\x00\x0f\x00\xff\xff\xff\xff\x06\x00\x07\x00\xff\xff\xff\xff\x16\x00\x17\x00\x18\x00\xff\xff\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x16\x00\x17\x00\x18\x00\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x06\x00\x07\x00\xff\xff\xff\xff\x25\x00\xff\xff\xff\xff\xff\xff\x0e\x00\x0f\x00\xff\xff\x06\x00\x07\x00\xff\xff\xff\xff\xff\xff\x16\x00\x17\x00\x18\x00\x0e\x00\x0f\x00\xff\xff\x06\x00\x07\x00\xff\xff\xff\xff\xff\xff\x16\x00\x17\x00\x18\x00\xff\xff\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x16\x00\x17\x00\x18\x00\xff\xff\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x06\x00\x07\x00\xff\xff\xff\xff\x25\x00\xff\xff\xff\xff\xff\xff\x0e\x00\x0f\x00\xff\xff\x06\x00\x07\x00\xff\xff\xff\xff\xff\xff\x16\x00\x17\x00\x18\x00\x0e\x00\x0f\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\x16\x00\x17\x00\x18\x00\xff\xff\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\xff\xff\xff\xff\xff\xff\xff\xff\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x06\x00\x07\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\x0e\x00\x0f\x00\xff\xff\x06\x00\x07\x00\xff\xff\xff\xff\xff\xff\x16\x00\x17\x00\x18\x00\x0e\x00\x0f\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\x16\x00\x17\x00\x18\x00\xff\xff\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\xff\xff\xff\xff\xff\xff\xff\xff\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x06\x00\x07\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\x0e\x00\x0f\x00\xff\xff\x06\x00\x07\x00\xff\xff\xff\xff\xff\xff\x16\x00\x17\x00\x18\x00\x0e\x00\x0f\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\x16\x00\x17\x00\x18\x00\xff\xff\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\xff\xff\xff\xff\xff\xff\xff\xff\x25\x00\x26\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x01\x00\xff\xff\xff\xff\xff\xff\xff\xff\x06\x00\xff\xff\x08\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\x0d\x00\x0e\x00\xff\xff\x10\x00\x11\x00\x12\x00\x13\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\x1a\x00\x1b\x00\xff\xff\xff\xff\xff\xff\xff\xff\x01\x00\xff\xff\x22\x00\x23\x00\x24\x00\x06\x00\xff\xff\x08\x00\x09\x00\x0a\x00\x0b\x00\x0c\x00\xff\xff\x0e\x00\x01\x00\x10\x00\x11\x00\x12\x00\x13\x00\x06\x00\x06\x00\x07\x00\xff\xff\xff\xff\xff\xff\x1a\x00\x1b\x00\xff\xff\x0e\x00\x0f\x00\xff\xff\x12\x00\x13\x00\x22\x00\x23\x00\x24\x00\x16\x00\x17\x00\x18\x00\x1a\x00\x1b\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\x22\x00\x23\x00\x24\x00\xff\xff\x25\x00\x26\x00\x27\x00\x28\x00\x06\x00\x07\x00\xff\xff\x06\x00\x07\x00\xff\xff\xff\xff\xff\xff\x0e\x00\x0f\x00\xff\xff\x0e\x00\x0f\x00\xff\xff\xff\xff\xff\xff\x16\x00\x17\x00\x18\x00\x16\x00\x17\x00\x18\x00\x01\x00\xff\xff\x03\x00\xff\xff\x05\x00\xff\xff\x07\x00\xff\xff\xff\xff\x25\x00\x26\x00\x27\x00\x25\x00\x26\x00\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff"#

happyTable :: HappyAddr
happyTable = HappyA# "\x00\x00\x16\x00\x19\x00\x1a\x00\x16\x00\x1b\x00\x1c\x00\x1d\x00\x1e\x00\x57\x00\x58\x00\x59\x00\x03\x00\x04\x00\x05\x00\x1f\x00\x20\x00\x3f\x00\x40\x00\x41\x00\x42\x00\x43\x00\x06\x00\x21\x00\x22\x00\x23\x00\x4e\x00\x03\x00\x4f\x00\x44\x00\x45\x00\x24\x00\xff\xff\x25\x00\x17\x00\x0d\x00\x26\x00\x2f\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x16\x00\x37\x00\x1a\x00\x52\x00\x1b\x00\x1c\x00\x1d\x00\x1e\x00\x0f\x00\x35\x00\x36\x00\x46\x00\x50\x00\x15\x00\x1f\x00\x20\x00\x14\x00\x37\x00\x38\x00\x59\x00\x0d\x00\x66\x00\x21\x00\x22\x00\x23\x00\x39\x00\x3a\x00\x0d\x00\x5a\x00\x5b\x00\x24\x00\x03\x00\x7f\x00\x65\x00\x0d\x00\x26\x00\x2f\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x16\x00\x3d\x00\x1a\x00\x59\x00\x1b\x00\x1c\x00\x1d\x00\x1e\x00\x3f\x00\x35\x00\x36\x00\x5d\x00\x5a\x00\x78\x00\x1f\x00\x20\x00\x52\x00\x53\x00\x54\x00\x04\x00\x0d\x00\x77\x00\x21\x00\x22\x00\x23\x00\x39\x00\x3a\x00\x0d\x00\x06\x00\x71\x00\x24\x00\x70\x00\x7e\x00\x7e\x00\x6f\x00\x26\x00\x6c\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x16\x00\x55\x00\x1a\x00\x6b\x00\x1b\x00\x1c\x00\x1d\x00\x1e\x00\x48\x00\x49\x00\x4a\x00\x4b\x00\x4c\x00\x69\x00\x1f\x00\x20\x00\x7d\x00\x7c\x00\x0f\x00\x10\x00\x4d\x00\x4e\x00\x21\x00\x22\x00\x23\x00\x11\x00\x0f\x00\x15\x00\x7b\x00\x7a\x00\x24\x00\x0d\x00\x83\x00\x11\x00\x83\x00\x26\x00\x0b\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x2d\x00\x1d\x00\x1e\x00\x12\x00\x08\x00\x09\x00\x0a\x00\x0b\x00\x18\x00\x1f\x00\x20\x00\x3d\x00\x1d\x00\x1e\x00\x81\x00\x00\x00\x00\x00\x21\x00\x22\x00\x3a\x00\x1f\x00\x20\x00\x00\x00\x00\x00\x1d\x00\x1e\x00\x00\x00\x00\x00\x21\x00\x22\x00\x3a\x00\x00\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x6c\x00\x6d\x00\x21\x00\x22\x00\x3a\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x6c\x00\x80\x00\x1d\x00\x1e\x00\x00\x00\x00\x00\x61\x00\x00\x00\x00\x00\x00\x00\x1f\x00\x20\x00\x00\x00\x1d\x00\x1e\x00\x00\x00\x00\x00\x00\x00\x21\x00\x22\x00\x3a\x00\x1f\x00\x20\x00\x00\x00\x1d\x00\x1e\x00\x00\x00\x00\x00\x00\x00\x21\x00\x22\x00\x3a\x00\x00\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x62\x00\x21\x00\x22\x00\x3a\x00\x00\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x3b\x00\x1d\x00\x1e\x00\x00\x00\x00\x00\x60\x00\x00\x00\x00\x00\x00\x00\x1f\x00\x20\x00\x00\x00\x1d\x00\x1e\x00\x00\x00\x00\x00\x00\x00\x21\x00\x22\x00\x3a\x00\x1f\x00\x20\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x21\x00\x22\x00\x3a\x00\x00\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x75\x00\x00\x00\x00\x00\x00\x00\x00\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x69\x00\x1d\x00\x1e\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1f\x00\x20\x00\x00\x00\x1d\x00\x1e\x00\x00\x00\x00\x00\x00\x00\x21\x00\x22\x00\x3a\x00\x1f\x00\x20\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x21\x00\x22\x00\x3a\x00\x00\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x67\x00\x00\x00\x00\x00\x00\x00\x00\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x66\x00\x1d\x00\x1e\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1f\x00\x20\x00\x00\x00\x1d\x00\x1e\x00\x00\x00\x00\x00\x00\x00\x21\x00\x22\x00\x3a\x00\x1f\x00\x20\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x21\x00\x22\x00\x3a\x00\x00\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x2c\x00\x77\x00\x00\x00\x00\x00\x00\x00\x00\x00\x27\x00\x28\x00\x29\x00\x2a\x00\x2b\x00\x74\x00\x2f\x00\x00\x00\x00\x00\x00\x00\x00\x00\x30\x00\x00\x00\x08\x00\x09\x00\x0a\x00\x0b\x00\x03\x00\x31\x00\x32\x00\x00\x00\x33\x00\x34\x00\x35\x00\x36\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x37\x00\x38\x00\x00\x00\x00\x00\x00\x00\x00\x00\x2f\x00\x00\x00\x39\x00\x3a\x00\x0d\x00\x30\x00\x00\x00\x08\x00\x09\x00\x0a\x00\x0b\x00\x03\x00\x00\x00\x32\x00\x2f\x00\x33\x00\x34\x00\x35\x00\x36\x00\x64\x00\x1d\x00\x1e\x00\x00\x00\x00\x00\x00\x00\x37\x00\x38\x00\x00\x00\x1f\x00\x20\x00\x00\x00\x35\x00\x36\x00\x39\x00\x3a\x00\x0d\x00\x21\x00\x22\x00\x3a\x00\x37\x00\x38\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x39\x00\x3a\x00\x0d\x00\x00\x00\x27\x00\x28\x00\x29\x00\x73\x00\x1d\x00\x1e\x00\x00\x00\x1d\x00\x1e\x00\x00\x00\x00\x00\x00\x00\x1f\x00\x20\x00\x00\x00\x1f\x00\x20\x00\x00\x00\x00\x00\x00\x00\x21\x00\x22\x00\x3a\x00\x21\x00\x22\x00\x3a\x00\x5d\x00\x00\x00\x5e\x00\x00\x00\x5f\x00\x00\x00\x60\x00\x00\x00\x00\x00\x27\x00\x28\x00\x72\x00\x27\x00\x71\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"#

happyReduceArr = Happy_Data_Array.array (1, 93) [
	(1 , happyReduce_1),
	(2 , happyReduce_2),
	(3 , happyReduce_3),
	(4 , happyReduce_4),
	(5 , happyReduce_5),
	(6 , happyReduce_6),
	(7 , happyReduce_7),
	(8 , happyReduce_8),
	(9 , happyReduce_9),
	(10 , happyReduce_10),
	(11 , happyReduce_11),
	(12 , happyReduce_12),
	(13 , happyReduce_13),
	(14 , happyReduce_14),
	(15 , happyReduce_15),
	(16 , happyReduce_16),
	(17 , happyReduce_17),
	(18 , happyReduce_18),
	(19 , happyReduce_19),
	(20 , happyReduce_20),
	(21 , happyReduce_21),
	(22 , happyReduce_22),
	(23 , happyReduce_23),
	(24 , happyReduce_24),
	(25 , happyReduce_25),
	(26 , happyReduce_26),
	(27 , happyReduce_27),
	(28 , happyReduce_28),
	(29 , happyReduce_29),
	(30 , happyReduce_30),
	(31 , happyReduce_31),
	(32 , happyReduce_32),
	(33 , happyReduce_33),
	(34 , happyReduce_34),
	(35 , happyReduce_35),
	(36 , happyReduce_36),
	(37 , happyReduce_37),
	(38 , happyReduce_38),
	(39 , happyReduce_39),
	(40 , happyReduce_40),
	(41 , happyReduce_41),
	(42 , happyReduce_42),
	(43 , happyReduce_43),
	(44 , happyReduce_44),
	(45 , happyReduce_45),
	(46 , happyReduce_46),
	(47 , happyReduce_47),
	(48 , happyReduce_48),
	(49 , happyReduce_49),
	(50 , happyReduce_50),
	(51 , happyReduce_51),
	(52 , happyReduce_52),
	(53 , happyReduce_53),
	(54 , happyReduce_54),
	(55 , happyReduce_55),
	(56 , happyReduce_56),
	(57 , happyReduce_57),
	(58 , happyReduce_58),
	(59 , happyReduce_59),
	(60 , happyReduce_60),
	(61 , happyReduce_61),
	(62 , happyReduce_62),
	(63 , happyReduce_63),
	(64 , happyReduce_64),
	(65 , happyReduce_65),
	(66 , happyReduce_66),
	(67 , happyReduce_67),
	(68 , happyReduce_68),
	(69 , happyReduce_69),
	(70 , happyReduce_70),
	(71 , happyReduce_71),
	(72 , happyReduce_72),
	(73 , happyReduce_73),
	(74 , happyReduce_74),
	(75 , happyReduce_75),
	(76 , happyReduce_76),
	(77 , happyReduce_77),
	(78 , happyReduce_78),
	(79 , happyReduce_79),
	(80 , happyReduce_80),
	(81 , happyReduce_81),
	(82 , happyReduce_82),
	(83 , happyReduce_83),
	(84 , happyReduce_84),
	(85 , happyReduce_85),
	(86 , happyReduce_86),
	(87 , happyReduce_87),
	(88 , happyReduce_88),
	(89 , happyReduce_89),
	(90 , happyReduce_90),
	(91 , happyReduce_91),
	(92 , happyReduce_92),
	(93 , happyReduce_93)
	]

happy_n_terms = 38 :: Int
happy_n_nonterms = 48 :: Int

happyReduce_1 = happySpecReduce_1  0# happyReduction_1
happyReduction_1 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn4
		 (POpenBlock (mkPosToken happy_var_1)
	)}

happyReduce_2 = happySpecReduce_1  1# happyReduction_2
happyReduction_2 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn5
		 (PCloseBlock (mkPosToken happy_var_1)
	)}

happyReduce_3 = happySpecReduce_1  2# happyReduction_3
happyReduction_3 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn6
		 (PIf (mkPosToken happy_var_1)
	)}

happyReduce_4 = happySpecReduce_1  3# happyReduction_4
happyReduction_4 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn7
		 (PElse (mkPosToken happy_var_1)
	)}

happyReduce_5 = happySpecReduce_1  4# happyReduction_5
happyReduction_5 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn8
		 (PWhile (mkPosToken happy_var_1)
	)}

happyReduce_6 = happySpecReduce_1  5# happyReduction_6
happyReduction_6 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn9
		 (PReturn (mkPosToken happy_var_1)
	)}

happyReduce_7 = happySpecReduce_1  6# happyReduction_7
happyReduction_7 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn10
		 (PTrue (mkPosToken happy_var_1)
	)}

happyReduce_8 = happySpecReduce_1  7# happyReduction_8
happyReduction_8 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn11
		 (PFalse (mkPosToken happy_var_1)
	)}

happyReduce_9 = happySpecReduce_1  8# happyReduction_9
happyReduction_9 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn12
		 (PEQU (mkPosToken happy_var_1)
	)}

happyReduce_10 = happySpecReduce_1  9# happyReduction_10
happyReduction_10 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn13
		 (PLE (mkPosToken happy_var_1)
	)}

happyReduce_11 = happySpecReduce_1  10# happyReduction_11
happyReduction_11 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn14
		 (PGE (mkPosToken happy_var_1)
	)}

happyReduce_12 = happySpecReduce_1  11# happyReduction_12
happyReduction_12 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn15
		 (PNE (mkPosToken happy_var_1)
	)}

happyReduce_13 = happySpecReduce_1  12# happyReduction_13
happyReduction_13 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn16
		 (PAnd (mkPosToken happy_var_1)
	)}

happyReduce_14 = happySpecReduce_1  13# happyReduction_14
happyReduction_14 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn17
		 (POr (mkPosToken happy_var_1)
	)}

happyReduce_15 = happySpecReduce_1  14# happyReduction_15
happyReduction_15 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn18
		 (PMinus (mkPosToken happy_var_1)
	)}

happyReduce_16 = happySpecReduce_1  15# happyReduction_16
happyReduction_16 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn19
		 (PNot (mkPosToken happy_var_1)
	)}

happyReduce_17 = happySpecReduce_1  16# happyReduction_17
happyReduction_17 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn20
		 (PPlus (mkPosToken happy_var_1)
	)}

happyReduce_18 = happySpecReduce_1  17# happyReduction_18
happyReduction_18 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn21
		 (PTimes (mkPosToken happy_var_1)
	)}

happyReduce_19 = happySpecReduce_1  18# happyReduction_19
happyReduction_19 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn22
		 (PDiv (mkPosToken happy_var_1)
	)}

happyReduce_20 = happySpecReduce_1  19# happyReduction_20
happyReduction_20 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn23
		 (PMod (mkPosToken happy_var_1)
	)}

happyReduce_21 = happySpecReduce_1  20# happyReduction_21
happyReduction_21 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn24
		 (PLTH (mkPosToken happy_var_1)
	)}

happyReduce_22 = happySpecReduce_1  21# happyReduction_22
happyReduction_22 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn25
		 (PGTH (mkPosToken happy_var_1)
	)}

happyReduce_23 = happySpecReduce_1  22# happyReduction_23
happyReduction_23 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn26
		 (PString (mkPosToken happy_var_1)
	)}

happyReduce_24 = happySpecReduce_1  23# happyReduction_24
happyReduction_24 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn27
		 (PInteger (mkPosToken happy_var_1)
	)}

happyReduce_25 = happySpecReduce_1  24# happyReduction_25
happyReduction_25 happy_x_1
	 =  case happyOutTok happy_x_1 of { happy_var_1 -> 
	happyIn28
		 (PIdent (mkPosToken happy_var_1)
	)}

happyReduce_26 = happySpecReduce_1  25# happyReduction_26
happyReduction_26 happy_x_1
	 =  case happyOut31 happy_x_1 of { happy_var_1 -> 
	happyIn29
		 (AbsLatte.Program happy_var_1
	)}

happyReduce_27 = happyReduce 6# 26# happyReduction_27
happyReduction_27 (happy_x_6 `HappyStk`
	happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut39 happy_x_1 of { happy_var_1 -> 
	case happyOut28 happy_x_2 of { happy_var_2 -> 
	case happyOut33 happy_x_4 of { happy_var_4 -> 
	case happyOut34 happy_x_6 of { happy_var_6 -> 
	happyIn30
		 (AbsLatte.FnDef happy_var_1 happy_var_2 happy_var_4 happy_var_6
	) `HappyStk` happyRest}}}}

happyReduce_28 = happySpecReduce_1  27# happyReduction_28
happyReduction_28 happy_x_1
	 =  case happyOut30 happy_x_1 of { happy_var_1 -> 
	happyIn31
		 ((:[]) happy_var_1
	)}

happyReduce_29 = happySpecReduce_2  27# happyReduction_29
happyReduction_29 happy_x_2
	happy_x_1
	 =  case happyOut30 happy_x_1 of { happy_var_1 -> 
	case happyOut31 happy_x_2 of { happy_var_2 -> 
	happyIn31
		 ((:) happy_var_1 happy_var_2
	)}}

happyReduce_30 = happySpecReduce_2  28# happyReduction_30
happyReduction_30 happy_x_2
	happy_x_1
	 =  case happyOut39 happy_x_1 of { happy_var_1 -> 
	case happyOut28 happy_x_2 of { happy_var_2 -> 
	happyIn32
		 (AbsLatte.Arg happy_var_1 happy_var_2
	)}}

happyReduce_31 = happySpecReduce_0  29# happyReduction_31
happyReduction_31  =  happyIn33
		 ([]
	)

happyReduce_32 = happySpecReduce_1  29# happyReduction_32
happyReduction_32 happy_x_1
	 =  case happyOut32 happy_x_1 of { happy_var_1 -> 
	happyIn33
		 ((:[]) happy_var_1
	)}

happyReduce_33 = happySpecReduce_3  29# happyReduction_33
happyReduction_33 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut32 happy_x_1 of { happy_var_1 -> 
	case happyOut33 happy_x_3 of { happy_var_3 -> 
	happyIn33
		 ((:) happy_var_1 happy_var_3
	)}}

happyReduce_34 = happySpecReduce_3  30# happyReduction_34
happyReduction_34 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut4 happy_x_1 of { happy_var_1 -> 
	case happyOut35 happy_x_2 of { happy_var_2 -> 
	case happyOut5 happy_x_3 of { happy_var_3 -> 
	happyIn34
		 (AbsLatte.Block happy_var_1 (reverse happy_var_2) happy_var_3
	)}}}

happyReduce_35 = happySpecReduce_0  31# happyReduction_35
happyReduction_35  =  happyIn35
		 ([]
	)

happyReduce_36 = happySpecReduce_2  31# happyReduction_36
happyReduction_36 happy_x_2
	happy_x_1
	 =  case happyOut35 happy_x_1 of { happy_var_1 -> 
	case happyOut36 happy_x_2 of { happy_var_2 -> 
	happyIn35
		 (flip (:) happy_var_1 happy_var_2
	)}}

happyReduce_37 = happySpecReduce_1  32# happyReduction_37
happyReduction_37 happy_x_1
	 =  happyIn36
		 (AbsLatte.Empty
	)

happyReduce_38 = happySpecReduce_1  32# happyReduction_38
happyReduction_38 happy_x_1
	 =  case happyOut34 happy_x_1 of { happy_var_1 -> 
	happyIn36
		 (AbsLatte.BStmt happy_var_1
	)}

happyReduce_39 = happySpecReduce_3  32# happyReduction_39
happyReduction_39 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut39 happy_x_1 of { happy_var_1 -> 
	case happyOut38 happy_x_2 of { happy_var_2 -> 
	happyIn36
		 (AbsLatte.Decl happy_var_1 happy_var_2
	)}}

happyReduce_40 = happyReduce 4# 32# happyReduction_40
happyReduction_40 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut28 happy_x_1 of { happy_var_1 -> 
	case happyOut47 happy_x_3 of { happy_var_3 -> 
	happyIn36
		 (AbsLatte.Ass happy_var_1 happy_var_3
	) `HappyStk` happyRest}}

happyReduce_41 = happySpecReduce_3  32# happyReduction_41
happyReduction_41 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut28 happy_x_1 of { happy_var_1 -> 
	happyIn36
		 (AbsLatte.Incr happy_var_1
	)}

happyReduce_42 = happySpecReduce_3  32# happyReduction_42
happyReduction_42 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut28 happy_x_1 of { happy_var_1 -> 
	happyIn36
		 (AbsLatte.Decr happy_var_1
	)}

happyReduce_43 = happySpecReduce_3  32# happyReduction_43
happyReduction_43 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut9 happy_x_1 of { happy_var_1 -> 
	case happyOut47 happy_x_2 of { happy_var_2 -> 
	happyIn36
		 (AbsLatte.Ret happy_var_1 happy_var_2
	)}}

happyReduce_44 = happySpecReduce_2  32# happyReduction_44
happyReduction_44 happy_x_2
	happy_x_1
	 =  case happyOut9 happy_x_1 of { happy_var_1 -> 
	happyIn36
		 (AbsLatte.VRet happy_var_1
	)}

happyReduce_45 = happyReduce 5# 32# happyReduction_45
happyReduction_45 (happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut6 happy_x_1 of { happy_var_1 -> 
	case happyOut47 happy_x_3 of { happy_var_3 -> 
	case happyOut36 happy_x_5 of { happy_var_5 -> 
	happyIn36
		 (AbsLatte.Cond happy_var_1 happy_var_3 happy_var_5
	) `HappyStk` happyRest}}}

happyReduce_46 = happyReduce 7# 32# happyReduction_46
happyReduction_46 (happy_x_7 `HappyStk`
	happy_x_6 `HappyStk`
	happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut6 happy_x_1 of { happy_var_1 -> 
	case happyOut47 happy_x_3 of { happy_var_3 -> 
	case happyOut36 happy_x_5 of { happy_var_5 -> 
	case happyOut7 happy_x_6 of { happy_var_6 -> 
	case happyOut36 happy_x_7 of { happy_var_7 -> 
	happyIn36
		 (AbsLatte.CondElse happy_var_1 happy_var_3 happy_var_5 happy_var_6 happy_var_7
	) `HappyStk` happyRest}}}}}

happyReduce_47 = happyReduce 5# 32# happyReduction_47
happyReduction_47 (happy_x_5 `HappyStk`
	happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut8 happy_x_1 of { happy_var_1 -> 
	case happyOut47 happy_x_3 of { happy_var_3 -> 
	case happyOut36 happy_x_5 of { happy_var_5 -> 
	happyIn36
		 (AbsLatte.While happy_var_1 happy_var_3 happy_var_5
	) `HappyStk` happyRest}}}

happyReduce_48 = happySpecReduce_2  32# happyReduction_48
happyReduction_48 happy_x_2
	happy_x_1
	 =  case happyOut47 happy_x_1 of { happy_var_1 -> 
	happyIn36
		 (AbsLatte.SExp happy_var_1
	)}

happyReduce_49 = happySpecReduce_1  33# happyReduction_49
happyReduction_49 happy_x_1
	 =  case happyOut28 happy_x_1 of { happy_var_1 -> 
	happyIn37
		 (AbsLatte.NoInit happy_var_1
	)}

happyReduce_50 = happySpecReduce_3  33# happyReduction_50
happyReduction_50 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut28 happy_x_1 of { happy_var_1 -> 
	case happyOut47 happy_x_3 of { happy_var_3 -> 
	happyIn37
		 (AbsLatte.Init happy_var_1 happy_var_3
	)}}

happyReduce_51 = happySpecReduce_1  34# happyReduction_51
happyReduction_51 happy_x_1
	 =  case happyOut37 happy_x_1 of { happy_var_1 -> 
	happyIn38
		 ((:[]) happy_var_1
	)}

happyReduce_52 = happySpecReduce_3  34# happyReduction_52
happyReduction_52 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut37 happy_x_1 of { happy_var_1 -> 
	case happyOut38 happy_x_3 of { happy_var_3 -> 
	happyIn38
		 ((:) happy_var_1 happy_var_3
	)}}

happyReduce_53 = happySpecReduce_1  35# happyReduction_53
happyReduction_53 happy_x_1
	 =  happyIn39
		 (AbsLatte.Int
	)

happyReduce_54 = happySpecReduce_1  35# happyReduction_54
happyReduction_54 happy_x_1
	 =  happyIn39
		 (AbsLatte.Str
	)

happyReduce_55 = happySpecReduce_1  35# happyReduction_55
happyReduction_55 happy_x_1
	 =  happyIn39
		 (AbsLatte.Bool
	)

happyReduce_56 = happySpecReduce_1  35# happyReduction_56
happyReduction_56 happy_x_1
	 =  happyIn39
		 (AbsLatte.Void
	)

happyReduce_57 = happySpecReduce_0  36# happyReduction_57
happyReduction_57  =  happyIn40
		 ([]
	)

happyReduce_58 = happySpecReduce_1  36# happyReduction_58
happyReduction_58 happy_x_1
	 =  case happyOut39 happy_x_1 of { happy_var_1 -> 
	happyIn40
		 ((:[]) happy_var_1
	)}

happyReduce_59 = happySpecReduce_3  36# happyReduction_59
happyReduction_59 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut39 happy_x_1 of { happy_var_1 -> 
	case happyOut40 happy_x_3 of { happy_var_3 -> 
	happyIn40
		 ((:) happy_var_1 happy_var_3
	)}}

happyReduce_60 = happySpecReduce_1  37# happyReduction_60
happyReduction_60 happy_x_1
	 =  case happyOut28 happy_x_1 of { happy_var_1 -> 
	happyIn41
		 (AbsLatte.EVar happy_var_1
	)}

happyReduce_61 = happySpecReduce_1  37# happyReduction_61
happyReduction_61 happy_x_1
	 =  case happyOut27 happy_x_1 of { happy_var_1 -> 
	happyIn41
		 (AbsLatte.ELitInt happy_var_1
	)}

happyReduce_62 = happySpecReduce_1  37# happyReduction_62
happyReduction_62 happy_x_1
	 =  case happyOut10 happy_x_1 of { happy_var_1 -> 
	happyIn41
		 (AbsLatte.ELitTrue happy_var_1
	)}

happyReduce_63 = happySpecReduce_1  37# happyReduction_63
happyReduction_63 happy_x_1
	 =  case happyOut11 happy_x_1 of { happy_var_1 -> 
	happyIn41
		 (AbsLatte.ELitFalse happy_var_1
	)}

happyReduce_64 = happyReduce 4# 37# happyReduction_64
happyReduction_64 (happy_x_4 `HappyStk`
	happy_x_3 `HappyStk`
	happy_x_2 `HappyStk`
	happy_x_1 `HappyStk`
	happyRest)
	 = case happyOut28 happy_x_1 of { happy_var_1 -> 
	case happyOut48 happy_x_3 of { happy_var_3 -> 
	happyIn41
		 (AbsLatte.EApp happy_var_1 happy_var_3
	) `HappyStk` happyRest}}

happyReduce_65 = happySpecReduce_1  37# happyReduction_65
happyReduction_65 happy_x_1
	 =  case happyOut26 happy_x_1 of { happy_var_1 -> 
	happyIn41
		 (AbsLatte.EString happy_var_1
	)}

happyReduce_66 = happySpecReduce_3  37# happyReduction_66
happyReduction_66 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut47 happy_x_2 of { happy_var_2 -> 
	happyIn41
		 (happy_var_2
	)}

happyReduce_67 = happySpecReduce_2  38# happyReduction_67
happyReduction_67 happy_x_2
	happy_x_1
	 =  case happyOut18 happy_x_1 of { happy_var_1 -> 
	case happyOut41 happy_x_2 of { happy_var_2 -> 
	happyIn42
		 (AbsLatte.Neg happy_var_1 happy_var_2
	)}}

happyReduce_68 = happySpecReduce_2  38# happyReduction_68
happyReduction_68 happy_x_2
	happy_x_1
	 =  case happyOut19 happy_x_1 of { happy_var_1 -> 
	case happyOut41 happy_x_2 of { happy_var_2 -> 
	happyIn42
		 (AbsLatte.Not happy_var_1 happy_var_2
	)}}

happyReduce_69 = happySpecReduce_1  38# happyReduction_69
happyReduction_69 happy_x_1
	 =  case happyOut41 happy_x_1 of { happy_var_1 -> 
	happyIn42
		 (happy_var_1
	)}

happyReduce_70 = happySpecReduce_3  39# happyReduction_70
happyReduction_70 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut43 happy_x_1 of { happy_var_1 -> 
	case happyOut50 happy_x_2 of { happy_var_2 -> 
	case happyOut42 happy_x_3 of { happy_var_3 -> 
	happyIn43
		 (AbsLatte.EMul happy_var_1 happy_var_2 happy_var_3
	)}}}

happyReduce_71 = happySpecReduce_1  39# happyReduction_71
happyReduction_71 happy_x_1
	 =  case happyOut42 happy_x_1 of { happy_var_1 -> 
	happyIn43
		 (happy_var_1
	)}

happyReduce_72 = happySpecReduce_3  40# happyReduction_72
happyReduction_72 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut44 happy_x_1 of { happy_var_1 -> 
	case happyOut49 happy_x_2 of { happy_var_2 -> 
	case happyOut43 happy_x_3 of { happy_var_3 -> 
	happyIn44
		 (AbsLatte.EAdd happy_var_1 happy_var_2 happy_var_3
	)}}}

happyReduce_73 = happySpecReduce_1  40# happyReduction_73
happyReduction_73 happy_x_1
	 =  case happyOut43 happy_x_1 of { happy_var_1 -> 
	happyIn44
		 (happy_var_1
	)}

happyReduce_74 = happySpecReduce_3  41# happyReduction_74
happyReduction_74 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut45 happy_x_1 of { happy_var_1 -> 
	case happyOut51 happy_x_2 of { happy_var_2 -> 
	case happyOut44 happy_x_3 of { happy_var_3 -> 
	happyIn45
		 (AbsLatte.ERel happy_var_1 happy_var_2 happy_var_3
	)}}}

happyReduce_75 = happySpecReduce_1  41# happyReduction_75
happyReduction_75 happy_x_1
	 =  case happyOut44 happy_x_1 of { happy_var_1 -> 
	happyIn45
		 (happy_var_1
	)}

happyReduce_76 = happySpecReduce_3  42# happyReduction_76
happyReduction_76 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut45 happy_x_1 of { happy_var_1 -> 
	case happyOut16 happy_x_2 of { happy_var_2 -> 
	case happyOut46 happy_x_3 of { happy_var_3 -> 
	happyIn46
		 (AbsLatte.EAnd happy_var_1 happy_var_2 happy_var_3
	)}}}

happyReduce_77 = happySpecReduce_1  42# happyReduction_77
happyReduction_77 happy_x_1
	 =  case happyOut45 happy_x_1 of { happy_var_1 -> 
	happyIn46
		 (happy_var_1
	)}

happyReduce_78 = happySpecReduce_3  43# happyReduction_78
happyReduction_78 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut46 happy_x_1 of { happy_var_1 -> 
	case happyOut17 happy_x_2 of { happy_var_2 -> 
	case happyOut47 happy_x_3 of { happy_var_3 -> 
	happyIn47
		 (AbsLatte.EOr happy_var_1 happy_var_2 happy_var_3
	)}}}

happyReduce_79 = happySpecReduce_1  43# happyReduction_79
happyReduction_79 happy_x_1
	 =  case happyOut46 happy_x_1 of { happy_var_1 -> 
	happyIn47
		 (happy_var_1
	)}

happyReduce_80 = happySpecReduce_0  44# happyReduction_80
happyReduction_80  =  happyIn48
		 ([]
	)

happyReduce_81 = happySpecReduce_1  44# happyReduction_81
happyReduction_81 happy_x_1
	 =  case happyOut47 happy_x_1 of { happy_var_1 -> 
	happyIn48
		 ((:[]) happy_var_1
	)}

happyReduce_82 = happySpecReduce_3  44# happyReduction_82
happyReduction_82 happy_x_3
	happy_x_2
	happy_x_1
	 =  case happyOut47 happy_x_1 of { happy_var_1 -> 
	case happyOut48 happy_x_3 of { happy_var_3 -> 
	happyIn48
		 ((:) happy_var_1 happy_var_3
	)}}

happyReduce_83 = happySpecReduce_1  45# happyReduction_83
happyReduction_83 happy_x_1
	 =  case happyOut20 happy_x_1 of { happy_var_1 -> 
	happyIn49
		 (AbsLatte.Plus happy_var_1
	)}

happyReduce_84 = happySpecReduce_1  45# happyReduction_84
happyReduction_84 happy_x_1
	 =  case happyOut18 happy_x_1 of { happy_var_1 -> 
	happyIn49
		 (AbsLatte.Minus happy_var_1
	)}

happyReduce_85 = happySpecReduce_1  46# happyReduction_85
happyReduction_85 happy_x_1
	 =  case happyOut21 happy_x_1 of { happy_var_1 -> 
	happyIn50
		 (AbsLatte.Times happy_var_1
	)}

happyReduce_86 = happySpecReduce_1  46# happyReduction_86
happyReduction_86 happy_x_1
	 =  case happyOut22 happy_x_1 of { happy_var_1 -> 
	happyIn50
		 (AbsLatte.Div happy_var_1
	)}

happyReduce_87 = happySpecReduce_1  46# happyReduction_87
happyReduction_87 happy_x_1
	 =  case happyOut23 happy_x_1 of { happy_var_1 -> 
	happyIn50
		 (AbsLatte.Mod happy_var_1
	)}

happyReduce_88 = happySpecReduce_1  47# happyReduction_88
happyReduction_88 happy_x_1
	 =  case happyOut24 happy_x_1 of { happy_var_1 -> 
	happyIn51
		 (AbsLatte.LTH happy_var_1
	)}

happyReduce_89 = happySpecReduce_1  47# happyReduction_89
happyReduction_89 happy_x_1
	 =  case happyOut13 happy_x_1 of { happy_var_1 -> 
	happyIn51
		 (AbsLatte.LE happy_var_1
	)}

happyReduce_90 = happySpecReduce_1  47# happyReduction_90
happyReduction_90 happy_x_1
	 =  case happyOut25 happy_x_1 of { happy_var_1 -> 
	happyIn51
		 (AbsLatte.GTH happy_var_1
	)}

happyReduce_91 = happySpecReduce_1  47# happyReduction_91
happyReduction_91 happy_x_1
	 =  case happyOut14 happy_x_1 of { happy_var_1 -> 
	happyIn51
		 (AbsLatte.GE happy_var_1
	)}

happyReduce_92 = happySpecReduce_1  47# happyReduction_92
happyReduction_92 happy_x_1
	 =  case happyOut12 happy_x_1 of { happy_var_1 -> 
	happyIn51
		 (AbsLatte.EQU happy_var_1
	)}

happyReduce_93 = happySpecReduce_1  47# happyReduction_93
happyReduction_93 happy_x_1
	 =  case happyOut15 happy_x_1 of { happy_var_1 -> 
	happyIn51
		 (AbsLatte.NE happy_var_1
	)}

happyNewToken action sts stk [] =
	happyDoAction 37# notHappyAtAll action sts stk []

happyNewToken action sts stk (tk:tks) =
	let cont i = happyDoAction i tk action sts stk tks in
	case tk of {
	PT _ (TS _ 1) -> cont 1#;
	PT _ (TS _ 2) -> cont 2#;
	PT _ (TS _ 3) -> cont 3#;
	PT _ (TS _ 4) -> cont 4#;
	PT _ (TS _ 5) -> cont 5#;
	PT _ (TS _ 6) -> cont 6#;
	PT _ (TS _ 7) -> cont 7#;
	PT _ (TS _ 8) -> cont 8#;
	PT _ (TS _ 9) -> cont 9#;
	PT _ (TS _ 10) -> cont 10#;
	PT _ (TS _ 11) -> cont 11#;
	PT _ (T_POpenBlock _) -> cont 12#;
	PT _ (T_PCloseBlock _) -> cont 13#;
	PT _ (T_PIf _) -> cont 14#;
	PT _ (T_PElse _) -> cont 15#;
	PT _ (T_PWhile _) -> cont 16#;
	PT _ (T_PReturn _) -> cont 17#;
	PT _ (T_PTrue _) -> cont 18#;
	PT _ (T_PFalse _) -> cont 19#;
	PT _ (T_PEQU _) -> cont 20#;
	PT _ (T_PLE _) -> cont 21#;
	PT _ (T_PGE _) -> cont 22#;
	PT _ (T_PNE _) -> cont 23#;
	PT _ (T_PAnd _) -> cont 24#;
	PT _ (T_POr _) -> cont 25#;
	PT _ (T_PMinus _) -> cont 26#;
	PT _ (T_PNot _) -> cont 27#;
	PT _ (T_PPlus _) -> cont 28#;
	PT _ (T_PTimes _) -> cont 29#;
	PT _ (T_PDiv _) -> cont 30#;
	PT _ (T_PMod _) -> cont 31#;
	PT _ (T_PLTH _) -> cont 32#;
	PT _ (T_PGTH _) -> cont 33#;
	PT _ (T_PString _) -> cont 34#;
	PT _ (T_PInteger _) -> cont 35#;
	PT _ (T_PIdent _) -> cont 36#;
	_ -> happyError' ((tk:tks), [])
	}

happyError_ explist 37# tk tks = happyError' (tks, explist)
happyError_ explist _ tk tks = happyError' ((tk:tks), explist)

happyThen :: () => Err a -> (a -> Err b) -> Err b
happyThen = (thenM)
happyReturn :: () => a -> Err a
happyReturn = (returnM)
happyThen1 m k tks = (thenM) m (\a -> k a tks)
happyReturn1 :: () => a -> b -> Err a
happyReturn1 = \a tks -> (returnM) a
happyError' :: () => ([(Token)], [String]) -> Err a
happyError' = (\(tokens, _) -> happyError tokens)
pProgram tks = happySomeParser where
 happySomeParser = happyThen (happyParse 0# tks) (\x -> happyReturn (happyOut29 x))

happySeq = happyDontSeq


returnM :: a -> Err a
returnM = return

thenM :: Err a -> (a -> Err b) -> Err b
thenM = (>>=)

happyError :: [Token] -> Err a
happyError ts =
  Bad $ "syntax error at " ++ tokenPos ts ++ 
  case ts of
    [] -> []
    [Err _] -> " due to lexer error"
    _ -> " before " ++ unwords (map (id . prToken) (take 4 ts))

myLexer = tokens
{-# LINE 1 "templates/GenericTemplate.hs" #-}
{-# LINE 1 "templates/GenericTemplate.hs" #-}
{-# LINE 1 "<built-in>" #-}
{-# LINE 1 "<command-line>" #-}
{-# LINE 11 "<command-line>" #-}
# 1 "/usr/include/stdc-predef.h" 1 3 4

# 17 "/usr/include/stdc-predef.h" 3 4














































{-# LINE 11 "<command-line>" #-}
{-# LINE 1 "/usr/lib/ghc/include/ghcversion.h" #-}

















{-# LINE 11 "<command-line>" #-}
{-# LINE 1 "/tmp/ghcb5f8_0/ghc_2.h" #-}




























































































































































{-# LINE 11 "<command-line>" #-}
{-# LINE 1 "templates/GenericTemplate.hs" #-}
-- Id: GenericTemplate.hs,v 1.26 2005/01/14 14:47:22 simonmar Exp 













-- Do not remove this comment. Required to fix CPP parsing when using GCC and a clang-compiled alex.
#if __GLASGOW_HASKELL__ > 706
#define LT(n,m) ((Happy_GHC_Exts.tagToEnum# (n Happy_GHC_Exts.<# m)) :: Bool)
#define GTE(n,m) ((Happy_GHC_Exts.tagToEnum# (n Happy_GHC_Exts.>=# m)) :: Bool)
#define EQ(n,m) ((Happy_GHC_Exts.tagToEnum# (n Happy_GHC_Exts.==# m)) :: Bool)
#else
#define LT(n,m) (n Happy_GHC_Exts.<# m)
#define GTE(n,m) (n Happy_GHC_Exts.>=# m)
#define EQ(n,m) (n Happy_GHC_Exts.==# m)
#endif
{-# LINE 43 "templates/GenericTemplate.hs" #-}

data Happy_IntList = HappyCons Happy_GHC_Exts.Int# Happy_IntList







{-# LINE 65 "templates/GenericTemplate.hs" #-}

{-# LINE 75 "templates/GenericTemplate.hs" #-}

{-# LINE 84 "templates/GenericTemplate.hs" #-}

infixr 9 `HappyStk`
data HappyStk a = HappyStk a (HappyStk a)

-----------------------------------------------------------------------------
-- starting the parse

happyParse start_state = happyNewToken start_state notHappyAtAll notHappyAtAll

-----------------------------------------------------------------------------
-- Accepting the parse

-- If the current token is 0#, it means we've just accepted a partial
-- parse (a %partial parser).  We must ignore the saved token on the top of
-- the stack in this case.
happyAccept 0# tk st sts (_ `HappyStk` ans `HappyStk` _) =
        happyReturn1 ans
happyAccept j tk st sts (HappyStk ans _) = 
        (happyTcHack j (happyTcHack st)) (happyReturn1 ans)

-----------------------------------------------------------------------------
-- Arrays only: do the next action



happyDoAction i tk st
        = {- nothing -}


          case action of
                0#           -> {- nothing -}
                                     happyFail (happyExpListPerState ((Happy_GHC_Exts.I# (st)) :: Int)) i tk st
                -1#          -> {- nothing -}
                                     happyAccept i tk st
                n | LT(n,(0# :: Happy_GHC_Exts.Int#)) -> {- nothing -}

                                                   (happyReduceArr Happy_Data_Array.! rule) i tk st
                                                   where rule = (Happy_GHC_Exts.I# ((Happy_GHC_Exts.negateInt# ((n Happy_GHC_Exts.+# (1# :: Happy_GHC_Exts.Int#))))))
                n                 -> {- nothing -}


                                     happyShift new_state i tk st
                                     where new_state = (n Happy_GHC_Exts.-# (1# :: Happy_GHC_Exts.Int#))
   where off    = happyAdjustOffset (indexShortOffAddr happyActOffsets st)
         off_i  = (off Happy_GHC_Exts.+#  i)
         check  = if GTE(off_i,(0# :: Happy_GHC_Exts.Int#))
                  then EQ(indexShortOffAddr happyCheck off_i, i)
                  else False
         action
          | check     = indexShortOffAddr happyTable off_i
          | otherwise = indexShortOffAddr happyDefActions st




indexShortOffAddr (HappyA# arr) off =
        Happy_GHC_Exts.narrow16Int# i
  where
        i = Happy_GHC_Exts.word2Int# (Happy_GHC_Exts.or# (Happy_GHC_Exts.uncheckedShiftL# high 8#) low)
        high = Happy_GHC_Exts.int2Word# (Happy_GHC_Exts.ord# (Happy_GHC_Exts.indexCharOffAddr# arr (off' Happy_GHC_Exts.+# 1#)))
        low  = Happy_GHC_Exts.int2Word# (Happy_GHC_Exts.ord# (Happy_GHC_Exts.indexCharOffAddr# arr off'))
        off' = off Happy_GHC_Exts.*# 2#




{-# INLINE happyLt #-}
happyLt x y = LT(x,y)


readArrayBit arr bit =
    Bits.testBit (Happy_GHC_Exts.I# (indexShortOffAddr arr ((unbox_int bit) `Happy_GHC_Exts.iShiftRA#` 4#))) (bit `mod` 16)
  where unbox_int (Happy_GHC_Exts.I# x) = x






data HappyAddr = HappyA# Happy_GHC_Exts.Addr#


-----------------------------------------------------------------------------
-- HappyState data type (not arrays)

{-# LINE 180 "templates/GenericTemplate.hs" #-}

-----------------------------------------------------------------------------
-- Shifting a token

happyShift new_state 0# tk st sts stk@(x `HappyStk` _) =
     let i = (case Happy_GHC_Exts.unsafeCoerce# x of { (Happy_GHC_Exts.I# (i)) -> i }) in
--     trace "shifting the error token" $
     happyDoAction i tk new_state (HappyCons (st) (sts)) (stk)

happyShift new_state i tk st sts stk =
     happyNewToken new_state (HappyCons (st) (sts)) ((happyInTok (tk))`HappyStk`stk)

-- happyReduce is specialised for the common cases.

happySpecReduce_0 i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happySpecReduce_0 nt fn j tk st@((action)) sts stk
     = happyGoto nt j tk st (HappyCons (st) (sts)) (fn `HappyStk` stk)

happySpecReduce_1 i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happySpecReduce_1 nt fn j tk _ sts@((HappyCons (st@(action)) (_))) (v1`HappyStk`stk')
     = let r = fn v1 in
       happySeq r (happyGoto nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_2 i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happySpecReduce_2 nt fn j tk _ (HappyCons (_) (sts@((HappyCons (st@(action)) (_))))) (v1`HappyStk`v2`HappyStk`stk')
     = let r = fn v1 v2 in
       happySeq r (happyGoto nt j tk st sts (r `HappyStk` stk'))

happySpecReduce_3 i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happySpecReduce_3 nt fn j tk _ (HappyCons (_) ((HappyCons (_) (sts@((HappyCons (st@(action)) (_))))))) (v1`HappyStk`v2`HappyStk`v3`HappyStk`stk')
     = let r = fn v1 v2 v3 in
       happySeq r (happyGoto nt j tk st sts (r `HappyStk` stk'))

happyReduce k i fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happyReduce k nt fn j tk st sts stk
     = case happyDrop (k Happy_GHC_Exts.-# (1# :: Happy_GHC_Exts.Int#)) sts of
         sts1@((HappyCons (st1@(action)) (_))) ->
                let r = fn stk in  -- it doesn't hurt to always seq here...
                happyDoSeq r (happyGoto nt j tk st1 sts1 r)

happyMonadReduce k nt fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happyMonadReduce k nt fn j tk st sts stk =
      case happyDrop k (HappyCons (st) (sts)) of
        sts1@((HappyCons (st1@(action)) (_))) ->
          let drop_stk = happyDropStk k stk in
          happyThen1 (fn stk tk) (\r -> happyGoto nt j tk st1 sts1 (r `HappyStk` drop_stk))

happyMonad2Reduce k nt fn 0# tk st sts stk
     = happyFail [] 0# tk st sts stk
happyMonad2Reduce k nt fn j tk st sts stk =
      case happyDrop k (HappyCons (st) (sts)) of
        sts1@((HappyCons (st1@(action)) (_))) ->
         let drop_stk = happyDropStk k stk

             off = happyAdjustOffset (indexShortOffAddr happyGotoOffsets st1)
             off_i = (off Happy_GHC_Exts.+#  nt)
             new_state = indexShortOffAddr happyTable off_i




          in
          happyThen1 (fn stk tk) (\r -> happyNewToken new_state sts1 (r `HappyStk` drop_stk))

happyDrop 0# l = l
happyDrop n (HappyCons (_) (t)) = happyDrop (n Happy_GHC_Exts.-# (1# :: Happy_GHC_Exts.Int#)) t

happyDropStk 0# l = l
happyDropStk n (x `HappyStk` xs) = happyDropStk (n Happy_GHC_Exts.-# (1#::Happy_GHC_Exts.Int#)) xs

-----------------------------------------------------------------------------
-- Moving to a new state after a reduction


happyGoto nt j tk st = 
   {- nothing -}
   happyDoAction j tk new_state
   where off = happyAdjustOffset (indexShortOffAddr happyGotoOffsets st)
         off_i = (off Happy_GHC_Exts.+#  nt)
         new_state = indexShortOffAddr happyTable off_i




-----------------------------------------------------------------------------
-- Error recovery (0# is the error token)

-- parse error if we are in recovery and we fail again
happyFail explist 0# tk old_st _ stk@(x `HappyStk` _) =
     let i = (case Happy_GHC_Exts.unsafeCoerce# x of { (Happy_GHC_Exts.I# (i)) -> i }) in
--      trace "failing" $ 
        happyError_ explist i tk

{-  We don't need state discarding for our restricted implementation of
    "error".  In fact, it can cause some bogus parses, so I've disabled it
    for now --SDM

-- discard a state
happyFail  0# tk old_st (HappyCons ((action)) (sts)) 
                                                (saved_tok `HappyStk` _ `HappyStk` stk) =
--      trace ("discarding state, depth " ++ show (length stk))  $
        happyDoAction 0# tk action sts ((saved_tok`HappyStk`stk))
-}

-- Enter error recovery: generate an error token,
--                       save the old token and carry on.
happyFail explist i tk (action) sts stk =
--      trace "entering error recovery" $
        happyDoAction 0# tk action sts ( (Happy_GHC_Exts.unsafeCoerce# (Happy_GHC_Exts.I# (i))) `HappyStk` stk)

-- Internal happy errors:

notHappyAtAll :: a
notHappyAtAll = error "Internal Happy error\n"

-----------------------------------------------------------------------------
-- Hack to get the typechecker to accept our action functions


happyTcHack :: Happy_GHC_Exts.Int# -> a -> a
happyTcHack x y = y
{-# INLINE happyTcHack #-}


-----------------------------------------------------------------------------
-- Seq-ing.  If the --strict flag is given, then Happy emits 
--      happySeq = happyDoSeq
-- otherwise it emits
--      happySeq = happyDontSeq

happyDoSeq, happyDontSeq :: a -> b -> b
happyDoSeq   a b = a `seq` b
happyDontSeq a b = b

-----------------------------------------------------------------------------
-- Don't inline any functions from the template.  GHC has a nasty habit
-- of deciding to inline happyGoto everywhere, which increases the size of
-- the generated parser quite a bit.


{-# NOINLINE happyDoAction #-}
{-# NOINLINE happyTable #-}
{-# NOINLINE happyCheck #-}
{-# NOINLINE happyActOffsets #-}
{-# NOINLINE happyGotoOffsets #-}
{-# NOINLINE happyDefActions #-}

{-# NOINLINE happyShift #-}
{-# NOINLINE happySpecReduce_0 #-}
{-# NOINLINE happySpecReduce_1 #-}
{-# NOINLINE happySpecReduce_2 #-}
{-# NOINLINE happySpecReduce_3 #-}
{-# NOINLINE happyReduce #-}
{-# NOINLINE happyMonadReduce #-}
{-# NOINLINE happyGoto #-}
{-# NOINLINE happyFail #-}

-- end of Happy Template.
