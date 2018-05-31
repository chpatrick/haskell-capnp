{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
module Data.Capnp.ById.Xb8630836983feed7.Pure where

-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: schema/capnp/persistent.capnp

import Data.Int
import Data.Word

import Data.Capnp.Untyped.Pure (List)
import Data.Capnp.BuiltinTypes.Pure (Data, Text)

import qualified Data.Capnp.Untyped.Pure
import qualified Data.Capnp.Untyped
import qualified Codec.Capnp

import qualified Data.Capnp.ById.Xb8630836983feed7
import qualified Data.Capnp.ById.Xbdf87d7bb8304e81.Pure
import qualified Data.Capnp.ById.Xbdf87d7bb8304e81

data Persistent'SaveResults
    = Persistent'SaveResults
        { sturdyRef :: Maybe (Data.Capnp.Untyped.Pure.PtrType)
        }
    deriving(Show, Read, Eq)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m Persistent'SaveResults b where
    fromStruct = Codec.Capnp.decerialize . Data.Capnp.ById.Xb8630836983feed7.Persistent'SaveResults

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.Decerialize (Data.Capnp.ById.Xb8630836983feed7.Persistent'SaveResults m b) Persistent'SaveResults where
    decerialize raw = undefined
data Persistent'SaveParams
    = Persistent'SaveParams
        { sealFor :: Maybe (Data.Capnp.Untyped.Pure.PtrType)
        }
    deriving(Show, Read, Eq)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m Persistent'SaveParams b where
    fromStruct = Codec.Capnp.decerialize . Data.Capnp.ById.Xb8630836983feed7.Persistent'SaveParams

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.Decerialize (Data.Capnp.ById.Xb8630836983feed7.Persistent'SaveParams m b) Persistent'SaveParams where
    decerialize raw = undefined
