module Common.DList where
-- implementation similar to Data.DList package
-- based on https://kseo.github.io/posts/2017-01-21-writer-monad.html
newtype DList a = DL { unDL :: [a] -> [a] }


instance Semigroup (DList a) where
  l <> r  = DL (unDL l . unDL r)


instance Monoid (DList a) where
    mempty  = DL id


toDList :: [a] -> DList a
toDList l = DL (l++)


singleton e = toDList [e]


toList :: DList a -> [a]
toList dl = (unDL dl) []
