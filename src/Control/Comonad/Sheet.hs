{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ConstraintKinds  #-}
{-# LANGUAGE TypeFamilies     #-}

module Control.Comonad.Sheet where

import Control.Comonad.Sheet.Manipulate
import Control.Comonad.Sheet.Reference
import Control.Comonad.Sheet.Indexed
import Data.Functor.Nested

import Data.Function
import Control.Comonad
import Control.Applicative
import Data.Traversable

evaluate :: (ComonadApply w) => w (w a -> a) -> w a
evaluate fs = fix $ (fs <@>) . duplicate

cell :: (Comonad w, Go r w) => RefList r -> w a -> a
cell = (extract .) . go

cells :: (Traversable t, Comonad w, Go r w) => t (RefList r) -> w a -> t a
cells = traverse cell

sheet :: ( InsertNested l (Nested ts) , Applicative (Nested ts)
         , DimensionalAs x (Nested ts a) , AsDimensionalAs x (Nested ts a) ~ l a )
         => a -> x -> Nested ts a
sheet background functions = insert functions (pure background)

indexedSheet :: ( InsertNested l (Nested ts) , Applicative (Nested ts)
                , DimensionalAs x (Nested ts a) , AsDimensionalAs x (Nested ts a) ~ l a)
                => Coordinate (NestedCount ts) -> a -> x -> Indexed ts a
indexedSheet i = (Indexed i .) . sheet