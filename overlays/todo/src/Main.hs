{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Main where

import Control.Monad (filterM)
import Control.Monad.Trans.Maybe (MaybeT(MaybeT), runMaybeT)
import Data.Foldable (asum)
import Data.Foldable (toList)
import Data.List.NonEmpty (NonEmpty((:|)))
import Data.Maybe (listToMaybe)
import Prelude hiding (FilePath)
import Turtle

import qualified Data.List.NonEmpty as NonEmpty

main :: IO ()
main = do
  cwd <- pwd
  let closest = asum . fmap candidate $ parents cwd
  result <- runMaybeT . unCandidate $ closest <|> defaultTodoTxt
  maybe notFoundError openInEditor result

newtype Candidate a = Candidate
  { unCandidate :: MaybeT IO a
  } deriving (Functor, Applicative, Alternative)

notFoundError :: IO ()
notFoundError = die "No todo.txt file found."

openInEditor :: FilePath -> IO ()
openInEditor file = do
  editor' <- need "EDITOR"
  case editor' of
    Nothing -> die "No $EDITOR environment variable set."
    Just editor -> do
      procs editor [fromString (encodeString file)] mempty

candidate :: FilePath -> Candidate FilePath
candidate dir =
  Candidate . MaybeT $ do
    let path = dir </> todoTxt
    exists <- testfile path
    pure $
      if exists
        then Just path
        else Nothing

todoTxt :: FilePath
todoTxt = "todo.txt"

parents :: FilePath -> [FilePath]
parents = toList . iterate' parent'

defaultTodoTxt :: Candidate FilePath
defaultTodoTxt =
  Candidate . MaybeT $ do
    candidate <- need "DEFAULT_TODO_TXT"
    traverse (realpath' . fromText) candidate

realpath' :: FilePath -> IO FilePath
realpath' path = do
  homeExpanded <-
    case encodeString path of
      '~':'/':rest -> (</>) <$> home <*> pure (decodeString rest)
      _ -> pure path
  realpath homeExpanded

parent' :: FilePath -> Maybe (FilePath)
parent' path =
  if parent path == path
    then Nothing
    else Just (parent path)

iterate' :: (a -> Maybe a) -> a -> NonEmpty a
iterate' = go []
  where
    go :: [a] -> (a -> Maybe a) -> a -> NonEmpty a
    go results f prev =
      case f prev of
        Nothing -> NonEmpty.reverse (prev :| results)
        Just next -> go (prev : results) f next
