{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
{- |
Module: Capnp.Capnp.Persistent.Pure
Description: High-level generated module for capnp/persistent.capnp
This module is the generated code for capnp/persistent.capnp,
for the high-level api.
-}
module Capnp.Capnp.Persistent.Pure (Persistent'SaveParams(..), Persistent'SaveResults(..)
) where
-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: capnp/persistent.capnp
import Data.Int
import Data.Word
import Data.Capnp.Untyped.Pure (List)
import Data.Capnp.Basics.Pure (Data, Text)
import Control.Monad.Catch (MonadThrow)
import Data.Capnp.TraversalLimit (MonadLimit)
import Control.Monad (forM_)
import qualified Data.Capnp.Message as M'
import qualified Data.Capnp.Basics as B'
import qualified Data.Capnp.Untyped as U'
import qualified Data.Capnp.Untyped.Pure as PU'
import qualified Codec.Capnp as C'
import qualified Data.Capnp.GenHelpers.Pure as PH'
import qualified Data.Vector as V
import qualified Data.ByteString as BS
import qualified Capnp.ById.Xb8630836983feed7
import qualified Capnp.ById.Xbdf87d7bb8304e81.Pure
import qualified Capnp.ById.Xbdf87d7bb8304e81
data Persistent'SaveParams
     = Persistent'SaveParams
        {sealFor :: Maybe (PU'.PtrType)}
    deriving(Show, Read, Eq)
instance C'.Decerialize Persistent'SaveParams where
    type Cerial msg Persistent'SaveParams = Capnp.ById.Xb8630836983feed7.Persistent'SaveParams msg
    decerialize raw = do
        Persistent'SaveParams <$>
            (Capnp.ById.Xb8630836983feed7.get_Persistent'SaveParams'sealFor raw >>= C'.decerialize)
instance C'.FromStruct M'.ConstMsg Persistent'SaveParams where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb8630836983feed7.Persistent'SaveParams M'.ConstMsg)
instance C'.Cerialize Persistent'SaveParams where
    marshalInto raw value = do
        case value of
            Persistent'SaveParams{..} -> do
                pure ()
data Persistent'SaveResults
     = Persistent'SaveResults
        {sturdyRef :: Maybe (PU'.PtrType)}
    deriving(Show, Read, Eq)
instance C'.Decerialize Persistent'SaveResults where
    type Cerial msg Persistent'SaveResults = Capnp.ById.Xb8630836983feed7.Persistent'SaveResults msg
    decerialize raw = do
        Persistent'SaveResults <$>
            (Capnp.ById.Xb8630836983feed7.get_Persistent'SaveResults'sturdyRef raw >>= C'.decerialize)
instance C'.FromStruct M'.ConstMsg Persistent'SaveResults where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb8630836983feed7.Persistent'SaveResults M'.ConstMsg)
instance C'.Cerialize Persistent'SaveResults where
    marshalInto raw value = do
        case value of
            Persistent'SaveResults{..} -> do
                pure ()