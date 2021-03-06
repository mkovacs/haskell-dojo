module ParserCombinators where

import Control.Applicative
import Control.Monad
import Data.Functor

data Parser t = Parser { runP :: String -> [(t, String)] }

result :: Parser t -> String -> [t]
result p s = [x | (x, "") <- runP p $ s]

instance Functor Parser where
  fmap f p = Parser $ \s -> [(f x, r) | (x, r) <- runP p s]

instance Applicative Parser where
  pure x = Parser $ \s -> [(x, s)]
  p <*> q = Parser $ \s -> [(f x, r) | (f, t) <- runP p s, (x, r) <- runP q t]

instance Alternative Parser where
  empty = Parser $ \s -> []
  p <|> q = Parser $ \s -> runP p s ++ runP q s

instance Monad Parser where
  p >>= f = Parser $ \s -> [(y, r) | (x, t) <- runP p s, (y, r) <- runP (f x) t]

satisfy :: (t -> Bool) -> Parser t -> Parser t
satisfy f p = Parser $ filter (f . fst) . runP p
