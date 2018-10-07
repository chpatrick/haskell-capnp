{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies          #-}
module Codec.Capnp
    ( newRoot
    , setRoot
    , getRoot
    , Get(..)
    , Set(..)
    , Has(..)
    , encodeV
    ) where

import Data.Capnp.Classes

import qualified Data.Capnp.Message as M
import qualified Data.Capnp.Untyped as U

-- | 'newRoot' allocates and returns a new value inside the message, setting
-- it as the root object of the message.
newRoot :: (ToStruct (M.MutMsg s) a, Allocate s a, M.WriteCtx m s)
    => M.MutMsg s -> m a
newRoot msg = do
    ret <- new msg
    setRoot ret
    pure ret

-- | 'setRoot' sets its argument to be the root object in its message.
setRoot :: (ToStruct (M.MutMsg s) a, M.WriteCtx m s) => a -> m ()
setRoot = U.setRoot . toStruct

-- | 'getRoot' returns the root object of a message.
getRoot :: (FromStruct msg a, U.ReadCtx m msg) => msg -> m a
getRoot msg = U.rootPtr msg >>= fromStruct

newtype Get a = Get { get :: a }
newtype Set a = Set { set :: a }
newtype Has a = Has { has :: a }

-- | Convert a value to it's serialized form, as the root object of its
-- message.
encodeV ::
    ( U.RWCtx m s
    , Cerialize s a
    , ToStruct (M.MutMsg s) (Cerial (M.MutMsg s) a)
    ) =>
    a -> m (Cerial (M.MutMsg s) a)
encodeV value = do
    msg <- M.newMessage
    cerial <- cerialize msg value
    setRoot cerial
    pure cerial
