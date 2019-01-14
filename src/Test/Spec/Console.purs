module Test.Spec.Console
  ( setAttr
  , reset
  , withAttrs
  , tellLn
  , tellLns
  , write
  , logWriter
  , moveUpAndClearDown
  ) where

import Prelude

import Ansi.Codes (colorSuffix, prefix)
import Control.Monad.Writer (class MonadWriter, WriterT, execWriterT, tell)
import Data.Foldable (foldr, for_)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)

foreign import write :: String -> Effect Unit
foreign import moveUpAndClearDown :: Int -> Effect Unit

logWriter :: forall m. MonadEffect m => WriterT String m Unit -> m Unit
logWriter = execWriterT >=> write >>> liftEffect

tellLn
  :: forall m
   . MonadWriter String m
  => String
  -> m Unit
tellLn l = tell $ l <> "\n"

tellLns
  :: forall m
   . MonadWriter String m
  => Array String
  -> m Unit
tellLns l = for_ l $ (_<> "\n") >>> tell


setAttr
  :: forall m
   . MonadWriter String m
  => Int
  -> m Unit
setAttr code = tell $ prefix <> show code <> colorSuffix

reset
  :: forall m
   . MonadWriter String m
  => m Unit
reset = setAttr 0

withAttrs
  :: forall m
   . MonadWriter String m
  => Array Int
  -> m Unit
  -> m Unit
withAttrs as r = foldr iter r as
  where iter attr acc = setAttr attr *> acc *> reset
