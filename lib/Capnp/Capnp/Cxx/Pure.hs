{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveGeneric #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
{- |
Module: Capnp.Capnp.Cxx.Pure
Description: High-level generated module for capnp/c++.capnp
This module is the generated code for capnp/c++.capnp,
for the high-level api.
-}
module Capnp.Capnp.Cxx.Pure (
) where
-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: capnp/c++.capnp
import Data.Int
import Data.Word
import Data.Default (Default(def))
import GHC.Generics (Generic)
import Data.Capnp.Basics.Pure (Data, Text)
import Control.Monad.Catch (MonadThrow)
import Data.Capnp.TraversalLimit (MonadLimit)
import Control.Monad (forM_)
import qualified Data.Capnp.Message as M'
import qualified Data.Capnp.Untyped as U'
import qualified Data.Capnp.Untyped.Pure as PU'
import qualified Data.Capnp.GenHelpers.Pure as PH'
import qualified Codec.Capnp as C'
import qualified Data.Vector as V
import qualified Data.ByteString as BS
import qualified Capnp.ById.Xbdf87d7bb8304e81