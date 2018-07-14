{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
module Capnp.Capnp.Json.Pure where

-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: capnp/json.capnp

import Data.Int
import Data.Word

import Data.Capnp.Untyped.Pure (List)
import Data.Capnp.Basics.Pure (Data, Text)
import Control.Monad.Catch (MonadThrow)
import Data.Capnp.TraversalLimit (MonadLimit)

import qualified Data.Capnp.Message as M'
import qualified Data.Capnp.Untyped.Pure as PU'
import qualified Codec.Capnp as C'

import qualified Capnp.ById.X8ef99297a43a5e34
import qualified Capnp.ById.Xbdf87d7bb8304e81.Pure
import qualified Capnp.ById.Xbdf87d7bb8304e81

data JsonValue
    = JsonValue'null
    | JsonValue'boolean (Bool)
    | JsonValue'number (Double)
    | JsonValue'string (Text)
    | JsonValue'array (List (JsonValue))
    | JsonValue'object (List (JsonValue'Field))
    | JsonValue'call (JsonValue'Call)
    | JsonValue'unknown' (Word16)
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.X8ef99297a43a5e34.JsonValue M'.ConstMessage) JsonValue where
    decerialize raw = case raw of

        Capnp.ById.X8ef99297a43a5e34.JsonValue'null -> pure JsonValue'null
        Capnp.ById.X8ef99297a43a5e34.JsonValue'boolean val -> JsonValue'boolean <$> C'.decerialize val
        Capnp.ById.X8ef99297a43a5e34.JsonValue'number val -> JsonValue'number <$> C'.decerialize val
        Capnp.ById.X8ef99297a43a5e34.JsonValue'string val -> JsonValue'string <$> C'.decerialize val
        Capnp.ById.X8ef99297a43a5e34.JsonValue'array val -> JsonValue'array <$> C'.decerialize val
        Capnp.ById.X8ef99297a43a5e34.JsonValue'object val -> JsonValue'object <$> C'.decerialize val
        Capnp.ById.X8ef99297a43a5e34.JsonValue'call val -> JsonValue'call <$> C'.decerialize val
        Capnp.ById.X8ef99297a43a5e34.JsonValue'unknown' val -> JsonValue'unknown' <$> C'.decerialize val

instance C'.IsStruct M'.ConstMessage JsonValue where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.X8ef99297a43a5e34.JsonValue M'.ConstMessage)

data JsonValue'Call
    = JsonValue'Call
        { function :: Text
        , params :: List (JsonValue)
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.X8ef99297a43a5e34.JsonValue'Call M'.ConstMessage) JsonValue'Call where
    decerialize raw = JsonValue'Call
            <$> (Capnp.ById.X8ef99297a43a5e34.get_JsonValue'Call'function raw >>= C'.decerialize)
            <*> (Capnp.ById.X8ef99297a43a5e34.get_JsonValue'Call'params raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage JsonValue'Call where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.X8ef99297a43a5e34.JsonValue'Call M'.ConstMessage)

data JsonValue'Field
    = JsonValue'Field
        { name :: Text
        , value :: JsonValue
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.X8ef99297a43a5e34.JsonValue'Field M'.ConstMessage) JsonValue'Field where
    decerialize raw = JsonValue'Field
            <$> (Capnp.ById.X8ef99297a43a5e34.get_JsonValue'Field'name raw >>= C'.decerialize)
            <*> (Capnp.ById.X8ef99297a43a5e34.get_JsonValue'Field'value raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage JsonValue'Field where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.X8ef99297a43a5e34.JsonValue'Field M'.ConstMessage)

