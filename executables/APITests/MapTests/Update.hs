module APITests.MapTests.Update where

import Test.Framework
import STMContainers.Prelude hiding (insert, delete, update)
import STMContainers.Transformers
import Control.Monad.Free
import Control.Monad.Free.TH


data UpdateF k v c =
  Insert k v c |
  Delete k c |
  Update (v -> v) k c
  deriving (Functor)

instance (Show k, Show v, Show c) => Show (UpdateF k v c) where
  showsPrec i = 
    showParen (i > 5) . \case
      Insert k v c -> 
        showString "Insert " . 
        showsPrecInner k .
        showChar ' ' .
        showsPrecInner v .
        showChar ' ' .
        showsPrecInner c
      Delete k c ->
        showString "Delete " .
        showsPrecInner k .
        showChar ' ' .
        showsPrecInner c
      Update f k c ->
        showString "Update " .
        showString "<v -> v> " .
        showsPrecInner k .
        showChar ' ' .
        showsPrecInner c
    where
      showsPrecInner = showsPrec (succ 5)

makeFree ''UpdateF

type Update k v = Free (UpdateF k v) ()

instance (Arbitrary k, Arbitrary v) => Arbitrary (Update k v) where
  arbitrary = 
    frequency
      [
        (1,   delete <$> arbitrary),
        (10,  insert <$> arbitrary <*> arbitrary),
        (3,   update <$> (const <$> arbitrary) <*> arbitrary)
      ]

