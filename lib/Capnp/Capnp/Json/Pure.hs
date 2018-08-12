{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
{- |
Module: Capnp.Capnp.Json.Pure
Description: High-level generated module for capnp/json.capnp
This module is the generated code for capnp/json.capnp,
for the high-level api.
-}
module Capnp.Capnp.Json.Pure (JsonValue(..), JsonValue'Call(..), JsonValue'Field(..)
) where
-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: capnp/json.capnp
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
import qualified Capnp.ById.X8ef99297a43a5e34
import qualified Capnp.ById.Xbdf87d7bb8304e81.Pure
import qualified Capnp.ById.Xbdf87d7bb8304e81
data JsonValue
     = JsonValue'null |
    JsonValue'boolean (Bool) |
    JsonValue'number (Double) |
    JsonValue'string (Text) |
    JsonValue'array (List (JsonValue)) |
    JsonValue'object (List (JsonValue'Field)) |
    JsonValue'call (JsonValue'Call) |
    JsonValue'unknown' (Word16)
    deriving(Show, Read, Eq)
instance C'.Decerialize JsonValue where
    type Cerial msg JsonValue = Capnp.ById.X8ef99297a43a5e34.JsonValue msg
    decerialize raw = do
        raw <- Capnp.ById.X8ef99297a43a5e34.get_JsonValue' raw
        case raw of
            Capnp.ById.X8ef99297a43a5e34.JsonValue'null -> pure JsonValue'null
            Capnp.ById.X8ef99297a43a5e34.JsonValue'boolean val -> pure (JsonValue'boolean val)
            Capnp.ById.X8ef99297a43a5e34.JsonValue'number val -> pure (JsonValue'number val)
            Capnp.ById.X8ef99297a43a5e34.JsonValue'string val -> JsonValue'string <$> C'.decerialize val
            Capnp.ById.X8ef99297a43a5e34.JsonValue'array val -> JsonValue'array <$> C'.decerialize val
            Capnp.ById.X8ef99297a43a5e34.JsonValue'object val -> JsonValue'object <$> C'.decerialize val
            Capnp.ById.X8ef99297a43a5e34.JsonValue'call val -> JsonValue'call <$> C'.decerialize val
            Capnp.ById.X8ef99297a43a5e34.JsonValue'unknown' val -> pure (JsonValue'unknown' val)
instance C'.FromStruct M'.ConstMsg JsonValue where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.X8ef99297a43a5e34.JsonValue M'.ConstMsg)
instance C'.Cerialize JsonValue where
    marshalInto raw value = do
        case value of
            JsonValue'null -> Capnp.ById.X8ef99297a43a5e34.set_JsonValue'null raw
            JsonValue'boolean arg_ -> Capnp.ById.X8ef99297a43a5e34.set_JsonValue'boolean raw arg_
            JsonValue'number arg_ -> Capnp.ById.X8ef99297a43a5e34.set_JsonValue'number raw arg_
            JsonValue'string arg_ -> do
                field_ <- PH'.marshalText raw arg_
                Capnp.ById.X8ef99297a43a5e34.set_JsonValue'string raw field_
            JsonValue'array arg_ -> do
                let len_ = V.length arg_
                field_ <- Capnp.ById.X8ef99297a43a5e34.new_JsonValue'array len_ raw
                forM_ [0..len_ - 1] $ \i -> do
                    elt <- C'.index i field_
                    C'.marshalInto elt (arg_ V.! i)
            JsonValue'object arg_ -> do
                let len_ = V.length arg_
                field_ <- Capnp.ById.X8ef99297a43a5e34.new_JsonValue'object len_ raw
                forM_ [0..len_ - 1] $ \i -> do
                    elt <- C'.index i field_
                    C'.marshalInto elt (arg_ V.! i)
            JsonValue'call arg_ -> do
                field_ <- Capnp.ById.X8ef99297a43a5e34.new_JsonValue'call raw
                C'.marshalInto field_ arg_
            JsonValue'unknown' _ -> pure ()
data JsonValue'Call
     = JsonValue'Call
        {function :: Text,
        params :: List (JsonValue)}
    deriving(Show, Read, Eq)
instance C'.Decerialize JsonValue'Call where
    type Cerial msg JsonValue'Call = Capnp.ById.X8ef99297a43a5e34.JsonValue'Call msg
    decerialize raw = do
        JsonValue'Call <$>
            (Capnp.ById.X8ef99297a43a5e34.get_JsonValue'Call'function raw >>= C'.decerialize) <*>
            (Capnp.ById.X8ef99297a43a5e34.get_JsonValue'Call'params raw >>= C'.decerialize)
instance C'.FromStruct M'.ConstMsg JsonValue'Call where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.X8ef99297a43a5e34.JsonValue'Call M'.ConstMsg)
instance C'.Cerialize JsonValue'Call where
    marshalInto raw value = do
        case value of
            JsonValue'Call{..} -> do
                field_ <- PH'.marshalText raw function
                Capnp.ById.X8ef99297a43a5e34.set_JsonValue'Call'function raw field_
                let len_ = V.length params
                field_ <- Capnp.ById.X8ef99297a43a5e34.new_JsonValue'Call'params len_ raw
                forM_ [0..len_ - 1] $ \i -> do
                    elt <- C'.index i field_
                    C'.marshalInto elt (params V.! i)
data JsonValue'Field
     = JsonValue'Field
        {name :: Text,
        value :: JsonValue}
    deriving(Show, Read, Eq)
instance C'.Decerialize JsonValue'Field where
    type Cerial msg JsonValue'Field = Capnp.ById.X8ef99297a43a5e34.JsonValue'Field msg
    decerialize raw = do
        JsonValue'Field <$>
            (Capnp.ById.X8ef99297a43a5e34.get_JsonValue'Field'name raw >>= C'.decerialize) <*>
            (Capnp.ById.X8ef99297a43a5e34.get_JsonValue'Field'value raw >>= C'.decerialize)
instance C'.FromStruct M'.ConstMsg JsonValue'Field where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.X8ef99297a43a5e34.JsonValue'Field M'.ConstMsg)
instance C'.Cerialize JsonValue'Field where
    marshalInto raw value = do
        case value of
            JsonValue'Field{..} -> do
                field_ <- PH'.marshalText raw name
                Capnp.ById.X8ef99297a43a5e34.set_JsonValue'Field'name raw field_
                field_ <- Capnp.ById.X8ef99297a43a5e34.new_JsonValue'Field'value raw
                C'.marshalInto field_ value