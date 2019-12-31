module Common.Ident where

import qualified AbsLatte

data Position = Position {
  line :: Int,
  column :: Int
}

newtype Ident = Ident String deriving (Eq, Ord)

pIdent2Ident :: AbsLatte.PIdent -> (Ident, Position)
pIdent2Ident (AbsLatte.PIdent ((line, column), name)) = (Ident name, Position line column)

p2Pos :: (Int, Int) -> Position
p2Pos = uncurry Position