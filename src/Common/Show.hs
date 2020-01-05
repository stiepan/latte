module Common.Show where

import Common.Ident

import qualified AbsLatte

joinWith :: String -> [String] -> String
joinWith sep [] = ""
joinWith sep sts = foldr1 (\el acc -> el ++ (sep ++ acc)) sts

spaceSep :: [String] -> String
spaceSep = joinWith " "

instance Show Position where
  show (Position line column) = "line " ++ ((show line) ++ (":" ++ (show column)))

instance Show Ident where
  show (Ident str) = '"':(str ++ "\"")

showType :: AbsLatte.Type -> String
showType AbsLatte.Int = "int"
showType AbsLatte.Str = "string"
showType AbsLatte.Bool = "boolean"
showType AbsLatte.Void = "void"
showType (AbsLatte.Fun t ats) = (showType t) ++  "(" ++ (joinWith ", " (map showType ats)) ++ ")"