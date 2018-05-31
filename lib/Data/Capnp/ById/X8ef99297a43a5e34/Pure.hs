{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
module Data.Capnp.ById.X8ef99297a43a5e34.Pure where

-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: schema/capnp/json.capnp

import Data.Int
import Data.Word

import Data.Capnp.Untyped.Pure (List)
import Data.Capnp.BuiltinTypes.Pure (Data, Text)

import qualified Data.Capnp.Untyped.Pure
import qualified Data.Capnp.Untyped
import qualified Codec.Capnp

import qualified Data.Capnp.ById.X8ef99297a43a5e34
import qualified Data.Capnp.ById.Xbdf87d7bb8304e81.Pure
import qualified Data.Capnp.ById.Xbdf87d7bb8304e81

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

data JsonValue'Call
    = JsonValue'Call
        { function :: Text
        , params :: List (JsonValue)
        }
    deriving(Show, Read, Eq)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m JsonValue'Call b where
    fromStruct = Codec.Capnp.decerialize . Data.Capnp.ById.X8ef99297a43a5e34.JsonValue'Call

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.Decerialize (Data.Capnp.ById.X8ef99297a43a5e34.JsonValue'Call m b) JsonValue'Call where
    decerialize raw = undefined
data JsonValue'Field
    = JsonValue'Field
        { name :: Text
        , value :: JsonValue
        }
    deriving(Show, Read, Eq)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m JsonValue'Field b where
    fromStruct = Codec.Capnp.decerialize . Data.Capnp.ById.X8ef99297a43a5e34.JsonValue'Field

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.Decerialize (Data.Capnp.ById.X8ef99297a43a5e34.JsonValue'Field m b) JsonValue'Field where
    decerialize raw = undefined
