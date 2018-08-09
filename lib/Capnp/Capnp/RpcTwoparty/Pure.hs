{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
{- |
Module: Capnp.Capnp.RpcTwoparty.Pure
Description: High-level generated module for capnp/rpc-twoparty.capnp
This module is the generated code for capnp/rpc-twoparty.capnp,
for the high-level api.
-}
module Capnp.Capnp.RpcTwoparty.Pure (JoinKeyPart(..), JoinResult(..), ProvisionId(..), Capnp.ById.Xa184c7885cdaf2a1.Side(..), VatId(..)
) where
-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: capnp/rpc-twoparty.capnp
import Data.Int
import Data.Word
import Data.Capnp.Untyped.Pure (List)
import Data.Capnp.Basics.Pure (Data, Text)
import Control.Monad.Catch (MonadThrow)
import Data.Capnp.TraversalLimit (MonadLimit)
import Control.Monad (forM_)
import qualified Data.Capnp.Message as M'
import qualified Data.Capnp.Untyped.Pure as PU'
import qualified Codec.Capnp as C'
import qualified Data.Capnp.GenHelpers.Pure as PH'
import qualified Data.Vector as V
import qualified Capnp.ById.Xa184c7885cdaf2a1
import qualified Capnp.ById.Xbdf87d7bb8304e81.Pure
import qualified Capnp.ById.Xbdf87d7bb8304e81
data JoinKeyPart
     = JoinKeyPart
        {joinId :: Word32,
        partCount :: Word16,
        partNum :: Word16}
    deriving(Show, Read, Eq)
instance C'.Decerialize (Capnp.ById.Xa184c7885cdaf2a1.JoinKeyPart M'.ConstMsg) JoinKeyPart where
    decerialize raw = JoinKeyPart <$>
        (Capnp.ById.Xa184c7885cdaf2a1.get_JoinKeyPart'joinId raw >>= C'.decerialize) <*>
        (Capnp.ById.Xa184c7885cdaf2a1.get_JoinKeyPart'partCount raw >>= C'.decerialize) <*>
        (Capnp.ById.Xa184c7885cdaf2a1.get_JoinKeyPart'partNum raw >>= C'.decerialize)
instance C'.IsStruct M'.ConstMsg JoinKeyPart where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xa184c7885cdaf2a1.JoinKeyPart M'.ConstMsg)
instance C'.Cerialize s JoinKeyPart (Capnp.ById.Xa184c7885cdaf2a1.JoinKeyPart (M'.MutMsg s)) where
    marshalInto raw value = do
        case value of
            JoinKeyPart{..} -> do
                Capnp.ById.Xa184c7885cdaf2a1.set_JoinKeyPart'joinId raw joinId
                Capnp.ById.Xa184c7885cdaf2a1.set_JoinKeyPart'partCount raw partCount
                Capnp.ById.Xa184c7885cdaf2a1.set_JoinKeyPart'partNum raw partNum
data JoinResult
     = JoinResult
        {joinId :: Word32,
        succeeded :: Bool,
        cap :: Maybe (PU'.PtrType)}
    deriving(Show, Read, Eq)
instance C'.Decerialize (Capnp.ById.Xa184c7885cdaf2a1.JoinResult M'.ConstMsg) JoinResult where
    decerialize raw = JoinResult <$>
        (Capnp.ById.Xa184c7885cdaf2a1.get_JoinResult'joinId raw >>= C'.decerialize) <*>
        (Capnp.ById.Xa184c7885cdaf2a1.get_JoinResult'succeeded raw >>= C'.decerialize) <*>
        (Capnp.ById.Xa184c7885cdaf2a1.get_JoinResult'cap raw >>= C'.decerialize)
instance C'.IsStruct M'.ConstMsg JoinResult where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xa184c7885cdaf2a1.JoinResult M'.ConstMsg)
instance C'.Cerialize s JoinResult (Capnp.ById.Xa184c7885cdaf2a1.JoinResult (M'.MutMsg s)) where
    marshalInto raw value = do
        case value of
            JoinResult{..} -> do
                Capnp.ById.Xa184c7885cdaf2a1.set_JoinResult'joinId raw joinId
                Capnp.ById.Xa184c7885cdaf2a1.set_JoinResult'succeeded raw succeeded
                pure ()
data ProvisionId
     = ProvisionId
        {joinId :: Word32}
    deriving(Show, Read, Eq)
instance C'.Decerialize (Capnp.ById.Xa184c7885cdaf2a1.ProvisionId M'.ConstMsg) ProvisionId where
    decerialize raw = ProvisionId <$>
        (Capnp.ById.Xa184c7885cdaf2a1.get_ProvisionId'joinId raw >>= C'.decerialize)
instance C'.IsStruct M'.ConstMsg ProvisionId where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xa184c7885cdaf2a1.ProvisionId M'.ConstMsg)
instance C'.Cerialize s ProvisionId (Capnp.ById.Xa184c7885cdaf2a1.ProvisionId (M'.MutMsg s)) where
    marshalInto raw value = do
        case value of
            ProvisionId{..} -> do
                Capnp.ById.Xa184c7885cdaf2a1.set_ProvisionId'joinId raw joinId
instance C'.Decerialize Capnp.ById.Xa184c7885cdaf2a1.Side Capnp.ById.Xa184c7885cdaf2a1.Side where
    decerialize = pure
data VatId
     = VatId
        {side :: Capnp.ById.Xa184c7885cdaf2a1.Side}
    deriving(Show, Read, Eq)
instance C'.Decerialize (Capnp.ById.Xa184c7885cdaf2a1.VatId M'.ConstMsg) VatId where
    decerialize raw = VatId <$>
        (Capnp.ById.Xa184c7885cdaf2a1.get_VatId'side raw >>= C'.decerialize)
instance C'.IsStruct M'.ConstMsg VatId where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xa184c7885cdaf2a1.VatId M'.ConstMsg)
instance C'.Cerialize s VatId (Capnp.ById.Xa184c7885cdaf2a1.VatId (M'.MutMsg s)) where
    marshalInto raw value = do
        case value of
            VatId{..} -> do
                Capnp.ById.Xa184c7885cdaf2a1.set_VatId'side raw side