{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs             #-}
{-| Module: Data.Capnp.BuiltinTypes.Generic
    Description: Handling of "built-in" capnp datatypes.

    In particular, things that are primitive types in the schema language,
    but not on the wire (chiefly Data and Text, which are both just lists of
    bytes).
-}
module Data.Capnp.BuiltinTypes.Generic
    ( Text
    , Data
    , List
    , getData
    , getText
    , getList
    ) where

import Data.Word

import Control.Monad       (when)
import Control.Monad.Catch (MonadThrow(throwM))

import qualified Data.ByteString            as BS
import qualified Data.Capnp.Errors          as E
import qualified Data.Capnp.Message         as M
import qualified Data.Capnp.Message.Generic as GM
import qualified Data.Capnp.Untyped.Generic as GU

-- | Typed lists.
--
-- Unlike 'GU.ListOf', typed lists can be lists of any type, not just the
-- basic storage types.
data List msg a where
    List :: (b -> a) -> (a -> b) -> GU.ListOf msg b -> List msg a

mapMut :: (a -> b) -> (b -> a) -> List msg a -> List msg b
mapMut from to (List from' to' base) = List (from . from') (to' . to) base

instance Functor (List M.Message) where
    fmap f = mapMut f undefined

-- | A textual string ("Text" in capnproto's schema language). On the wire,
-- this is NUL-terminated. The encoding should be UTF-8, but the library *does
-- not* verify this; users of the library must do validation themselves, if
-- they care about this.
--
-- Rationale: validation would require doing an up-front pass over the data,
-- which runs counter to the overall design of capnproto.
--
-- The argument to the constructor is the slice of the original message
-- containing the text (but not the NUL terminator).
newtype Text msg = Text (GU.ListOf msg Word8)

-- | A blob of bytes ("Data" in capnproto's schema language). The argument
-- to the constructor is a slice into the message, containing the raw bytes.
newtype Data msg = Data (GU.ListOf msg Word8)

-- | Interpret a list of Word8 as a capnproto 'Data' value.
getData :: (GM.Message m msg seg, GU.ReadCtx m) => GU.ListOf msg Word8 -> m (Data msg)
getData = pure . Data

-- | Interpret a list of Word8 as a capnproto 'Text' value.
--
-- This vaildates that the list is NUL-terminated, but not that it is valid
-- UTF-8. If it is not NUL-terminaed, a 'SchemaViolationError' is thrown.
getText :: (GM.Message m msg seg, GU.ReadCtx m) => GU.ListOf msg Word8 -> m (Text msg)
getText list = do
    let len = GU.length list
    when (len == 0) $ throwM $ E.SchemaViolationError
        "Text is not NUL-terminated (list of bytes has length 0)"
    lastByte <- GU.index (len - 1) list
    when (lastByte /= 0) $ throwM $ E.SchemaViolationError $
        "Text is not NUL-terminated (last byte is " ++ show lastByte ++ ")"
    pure $ Text list

-- | Convert an untyped list to a typed list (of the same underlying data type).
getList :: (GM.Message m msg seg, GU.ReadCtx m) => GU.ListOf msg a -> m (List msg a)
getList = pure . List id id


dataBytes :: (GM.Message m msg seg, GU.ReadCtx m) => Data msg -> m BS.ByteString
dataBytes (Data list) = GU.rawBytes list

textBytes :: (GM.Message m msg seg, GU.ReadCtx m) => Text msg -> m BS.ByteString
textBytes (Text list) = do
    bytes <- GU.rawBytes list
    -- Chop off the NUL byte:
    pure (BS.take (BS.length bytes - 1) bytes)
