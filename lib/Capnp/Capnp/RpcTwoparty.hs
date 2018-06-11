{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
module Capnp.Capnp.RpcTwoparty where

-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: capnp/rpc-twoparty.capnp

import Data.Int
import Data.Word

import Data.Capnp.Untyped.Pure (List)
import Data.Capnp.BuiltinTypes.Pure (Data, Text)
import Control.Monad.Catch (MonadThrow)
import Data.Capnp.TraversalLimit (MonadLimit)

import qualified Data.Capnp.Untyped.Pure
import qualified Data.Capnp.Untyped
import qualified Codec.Capnp

import qualified Capnp.ById.Xa184c7885cdaf2a1
import qualified Capnp.ById.Xbdf87d7bb8304e81.Pure
import qualified Capnp.ById.Xbdf87d7bb8304e81

data JoinKeyPart
    = JoinKeyPart
        { joinId :: Word32
        , partCount :: Word16
        , partNum :: Word16
        }
    deriving(Show, Read, Eq)

instance Codec.Capnp.Decerialize Capnp.ById.Xa184c7885cdaf2a1.JoinKeyPart JoinKeyPart where
    decerialize raw = JoinKeyPart
            <$> (Capnp.ById.Xa184c7885cdaf2a1.get_JoinKeyPart'joinId raw >>= Codec.Capnp.decerialize)
            <*> (Capnp.ById.Xa184c7885cdaf2a1.get_JoinKeyPart'partCount raw >>= Codec.Capnp.decerialize)
            <*> (Capnp.ById.Xa184c7885cdaf2a1.get_JoinKeyPart'partNum raw >>= Codec.Capnp.decerialize)

instance Codec.Capnp.IsStruct JoinKeyPart where
    fromStruct struct = do
        raw <- Codec.Capnp.fromStruct struct
        Codec.Capnp.decerialize (raw :: Capnp.ById.Xa184c7885cdaf2a1.JoinKeyPart)

data JoinResult
    = JoinResult
        { joinId :: Word32
        , succeeded :: Bool
        , cap :: Maybe (Data.Capnp.Untyped.Pure.PtrType)
        }
    deriving(Show, Read, Eq)

instance Codec.Capnp.Decerialize Capnp.ById.Xa184c7885cdaf2a1.JoinResult JoinResult where
    decerialize raw = JoinResult
            <$> (Capnp.ById.Xa184c7885cdaf2a1.get_JoinResult'joinId raw >>= Codec.Capnp.decerialize)
            <*> (Capnp.ById.Xa184c7885cdaf2a1.get_JoinResult'succeeded raw >>= Codec.Capnp.decerialize)
            <*> (Capnp.ById.Xa184c7885cdaf2a1.get_JoinResult'cap raw >>= Codec.Capnp.decerialize)

instance Codec.Capnp.IsStruct JoinResult where
    fromStruct struct = do
        raw <- Codec.Capnp.fromStruct struct
        Codec.Capnp.decerialize (raw :: Capnp.ById.Xa184c7885cdaf2a1.JoinResult)

data Side
    = Side'server
    | Side'client
    | Side'unknown' (Word16)
    deriving(Show, Read, Eq)

instance Codec.Capnp.Decerialize Capnp.ById.Xa184c7885cdaf2a1.Side Side where
    decerialize raw = case raw of

        Capnp.ById.Xa184c7885cdaf2a1.Side'server -> pure Side'server
        Capnp.ById.Xa184c7885cdaf2a1.Side'client -> pure Side'client
        Capnp.ById.Xa184c7885cdaf2a1.Side'unknown' val -> Side'unknown' <$> Codec.Capnp.decerialize val

data ProvisionId
    = ProvisionId
        { joinId :: Word32
        }
    deriving(Show, Read, Eq)

instance Codec.Capnp.Decerialize Capnp.ById.Xa184c7885cdaf2a1.ProvisionId ProvisionId where
    decerialize raw = ProvisionId
            <$> (Capnp.ById.Xa184c7885cdaf2a1.get_ProvisionId'joinId raw >>= Codec.Capnp.decerialize)

instance Codec.Capnp.IsStruct ProvisionId where
    fromStruct struct = do
        raw <- Codec.Capnp.fromStruct struct
        Codec.Capnp.decerialize (raw :: Capnp.ById.Xa184c7885cdaf2a1.ProvisionId)

data VatId
    = VatId
        { side :: Side
        }
    deriving(Show, Read, Eq)

instance Codec.Capnp.Decerialize Capnp.ById.Xa184c7885cdaf2a1.VatId VatId where
    decerialize raw = VatId
            <$> (Capnp.ById.Xa184c7885cdaf2a1.get_VatId'side raw >>= Codec.Capnp.decerialize)

instance Codec.Capnp.IsStruct VatId where
    fromStruct struct = do
        raw <- Codec.Capnp.fromStruct struct
        Codec.Capnp.decerialize (raw :: Capnp.ById.Xa184c7885cdaf2a1.VatId)

