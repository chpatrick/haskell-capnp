{-# OPTIONS_GHC -Wno-unused-imports #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveGeneric #-}
{- |
Module: Capnp.Gen.Capnp.Json
Description: Low-level generated module for capnp/json.capnp
This module is the generated code for capnp/json.capnp, for the
low-level api.
-}
module Capnp.Gen.Capnp.Json where
-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: capnp/json.capnp
import Data.Int
import Data.Word
import GHC.Generics (Generic)
import Capnp.Bits (Word1)
import qualified Data.Bits
import qualified Data.Maybe
import qualified Data.ByteString
import qualified Capnp.Classes as C'
import qualified Capnp.Basics as B'
import qualified Capnp.GenHelpers as H'
import qualified Capnp.TraversalLimit as TL'
import qualified Capnp.Untyped as U'
import qualified Capnp.Message as M'
import qualified Capnp.Gen.ById.Xbdf87d7bb8304e81
newtype JsonValue msg = JsonValue_newtype_ (U'.Struct msg)
instance U'.TraverseMsg JsonValue where
    tMsg f (JsonValue_newtype_ s) = JsonValue_newtype_ <$> U'.tMsg f s
instance C'.FromStruct msg (JsonValue msg) where
    fromStruct = pure . JsonValue_newtype_
instance C'.ToStruct msg (JsonValue msg) where
    toStruct (JsonValue_newtype_ struct) = struct
instance U'.HasMessage (JsonValue msg) where
    type InMessage (JsonValue msg) = msg
    message (JsonValue_newtype_ struct) = U'.message struct
instance U'.MessageDefault (JsonValue msg) where
    messageDefault = JsonValue_newtype_ . U'.messageDefault
instance B'.ListElem msg (JsonValue msg) where
    newtype List msg (JsonValue msg) = List_JsonValue (U'.ListOf msg (U'.Struct msg))
    listFromPtr msg ptr = List_JsonValue <$> C'.fromPtr msg ptr
    toUntypedList (List_JsonValue l) = U'.ListStruct l
    length (List_JsonValue l) = U'.length l
    index i (List_JsonValue l) = U'.index i l >>= (let {go :: U'.ReadCtx m msg => U'.Struct msg -> m (JsonValue msg); go = C'.fromStruct} in go)
instance C'.FromPtr msg (JsonValue msg) where
    fromPtr msg ptr = JsonValue_newtype_ <$> C'.fromPtr msg ptr
instance C'.ToPtr s (JsonValue (M'.MutMsg s)) where
    toPtr msg (JsonValue_newtype_ struct) = C'.toPtr msg struct
instance B'.MutListElem s (JsonValue (M'.MutMsg s)) where
    setIndex (JsonValue_newtype_ elt) i (List_JsonValue l) = U'.setIndex elt i l
    newList msg len = List_JsonValue <$> U'.allocCompositeList msg 2 1 len
instance C'.Allocate s (JsonValue (M'.MutMsg s)) where
    new msg = JsonValue_newtype_ <$> U'.allocStruct msg 2 1
data JsonValue' msg
    = JsonValue'null
    | JsonValue'boolean Bool
    | JsonValue'number Double
    | JsonValue'string (B'.Text msg)
    | JsonValue'array (B'.List msg (JsonValue msg))
    | JsonValue'object (B'.List msg (JsonValue'Field msg))
    | JsonValue'call (JsonValue'Call msg)
    | JsonValue'unknown' Word16
get_JsonValue' :: U'.ReadCtx m msg => JsonValue msg -> m (JsonValue' msg)
get_JsonValue' (JsonValue_newtype_ struct) = C'.fromStruct struct
set_JsonValue'null :: U'.RWCtx m s => JsonValue (M'.MutMsg s) -> m ()
set_JsonValue'null (JsonValue_newtype_ struct) = H'.setWordField struct (0 :: Word16) 0 0 0
set_JsonValue'boolean :: U'.RWCtx m s => JsonValue (M'.MutMsg s) -> Bool -> m ()
set_JsonValue'boolean (JsonValue_newtype_ struct) value = do
    H'.setWordField struct (1 :: Word16) 0 0 0
    H'.setWordField struct (fromIntegral (C'.toWord value) :: Word1) 0 16 0
set_JsonValue'number :: U'.RWCtx m s => JsonValue (M'.MutMsg s) -> Double -> m ()
set_JsonValue'number (JsonValue_newtype_ struct) value = do
    H'.setWordField struct (2 :: Word16) 0 0 0
    H'.setWordField struct (fromIntegral (C'.toWord value) :: Word64) 1 0 0
set_JsonValue'string :: U'.RWCtx m s => JsonValue (M'.MutMsg s) -> (B'.Text (M'.MutMsg s)) -> m ()
set_JsonValue'string(JsonValue_newtype_ struct) value = do
    H'.setWordField struct (3 :: Word16) 0 0 0
    ptr <- C'.toPtr (U'.message struct) value
    U'.setPtr ptr 0 struct
new_JsonValue'string :: U'.RWCtx m s => Int -> JsonValue (M'.MutMsg s) -> m ((B'.Text (M'.MutMsg s)))
new_JsonValue'string len struct = do
    result <- B'.newText (U'.message struct) len
    set_JsonValue'string struct result
    pure result
set_JsonValue'array :: U'.RWCtx m s => JsonValue (M'.MutMsg s) -> (B'.List (M'.MutMsg s) (JsonValue (M'.MutMsg s))) -> m ()
set_JsonValue'array(JsonValue_newtype_ struct) value = do
    H'.setWordField struct (4 :: Word16) 0 0 0
    ptr <- C'.toPtr (U'.message struct) value
    U'.setPtr ptr 0 struct
new_JsonValue'array :: U'.RWCtx m s => Int -> JsonValue (M'.MutMsg s) -> m ((B'.List (M'.MutMsg s) (JsonValue (M'.MutMsg s))))
new_JsonValue'array len struct = do
    result <- C'.newList (U'.message struct) len
    set_JsonValue'array struct result
    pure result
set_JsonValue'object :: U'.RWCtx m s => JsonValue (M'.MutMsg s) -> (B'.List (M'.MutMsg s) (JsonValue'Field (M'.MutMsg s))) -> m ()
set_JsonValue'object(JsonValue_newtype_ struct) value = do
    H'.setWordField struct (5 :: Word16) 0 0 0
    ptr <- C'.toPtr (U'.message struct) value
    U'.setPtr ptr 0 struct
new_JsonValue'object :: U'.RWCtx m s => Int -> JsonValue (M'.MutMsg s) -> m ((B'.List (M'.MutMsg s) (JsonValue'Field (M'.MutMsg s))))
new_JsonValue'object len struct = do
    result <- C'.newList (U'.message struct) len
    set_JsonValue'object struct result
    pure result
set_JsonValue'call :: U'.RWCtx m s => JsonValue (M'.MutMsg s) -> (JsonValue'Call (M'.MutMsg s)) -> m ()
set_JsonValue'call(JsonValue_newtype_ struct) value = do
    H'.setWordField struct (6 :: Word16) 0 0 0
    ptr <- C'.toPtr (U'.message struct) value
    U'.setPtr ptr 0 struct
new_JsonValue'call :: U'.RWCtx m s => JsonValue (M'.MutMsg s) -> m ((JsonValue'Call (M'.MutMsg s)))
new_JsonValue'call struct = do
    result <- C'.new (U'.message struct)
    set_JsonValue'call struct result
    pure result
set_JsonValue'unknown' :: U'.RWCtx m s => JsonValue (M'.MutMsg s) -> Word16 -> m ()
set_JsonValue'unknown'(JsonValue_newtype_ struct) tagValue = H'.setWordField struct (tagValue :: Word16) 0 0 0
instance C'.FromStruct msg (JsonValue' msg) where
    fromStruct struct = do
        tag <-  H'.getWordField struct 0 0 0
        case tag of
            6 -> JsonValue'call <$>  (U'.getPtr 0 struct >>= C'.fromPtr (U'.message struct))
            5 -> JsonValue'object <$>  (U'.getPtr 0 struct >>= C'.fromPtr (U'.message struct))
            4 -> JsonValue'array <$>  (U'.getPtr 0 struct >>= C'.fromPtr (U'.message struct))
            3 -> JsonValue'string <$>  (U'.getPtr 0 struct >>= C'.fromPtr (U'.message struct))
            2 -> JsonValue'number <$>  H'.getWordField struct 1 0 0
            1 -> JsonValue'boolean <$>  H'.getWordField struct 0 16 0
            0 -> pure JsonValue'null
            _ -> pure $ JsonValue'unknown' tag
newtype JsonValue'Call msg = JsonValue'Call_newtype_ (U'.Struct msg)
instance U'.TraverseMsg JsonValue'Call where
    tMsg f (JsonValue'Call_newtype_ s) = JsonValue'Call_newtype_ <$> U'.tMsg f s
instance C'.FromStruct msg (JsonValue'Call msg) where
    fromStruct = pure . JsonValue'Call_newtype_
instance C'.ToStruct msg (JsonValue'Call msg) where
    toStruct (JsonValue'Call_newtype_ struct) = struct
instance U'.HasMessage (JsonValue'Call msg) where
    type InMessage (JsonValue'Call msg) = msg
    message (JsonValue'Call_newtype_ struct) = U'.message struct
instance U'.MessageDefault (JsonValue'Call msg) where
    messageDefault = JsonValue'Call_newtype_ . U'.messageDefault
instance B'.ListElem msg (JsonValue'Call msg) where
    newtype List msg (JsonValue'Call msg) = List_JsonValue'Call (U'.ListOf msg (U'.Struct msg))
    listFromPtr msg ptr = List_JsonValue'Call <$> C'.fromPtr msg ptr
    toUntypedList (List_JsonValue'Call l) = U'.ListStruct l
    length (List_JsonValue'Call l) = U'.length l
    index i (List_JsonValue'Call l) = U'.index i l >>= (let {go :: U'.ReadCtx m msg => U'.Struct msg -> m (JsonValue'Call msg); go = C'.fromStruct} in go)
instance C'.FromPtr msg (JsonValue'Call msg) where
    fromPtr msg ptr = JsonValue'Call_newtype_ <$> C'.fromPtr msg ptr
instance C'.ToPtr s (JsonValue'Call (M'.MutMsg s)) where
    toPtr msg (JsonValue'Call_newtype_ struct) = C'.toPtr msg struct
instance B'.MutListElem s (JsonValue'Call (M'.MutMsg s)) where
    setIndex (JsonValue'Call_newtype_ elt) i (List_JsonValue'Call l) = U'.setIndex elt i l
    newList msg len = List_JsonValue'Call <$> U'.allocCompositeList msg 0 2 len
instance C'.Allocate s (JsonValue'Call (M'.MutMsg s)) where
    new msg = JsonValue'Call_newtype_ <$> U'.allocStruct msg 0 2
get_JsonValue'Call'function :: U'.ReadCtx m msg => JsonValue'Call msg -> m (B'.Text msg)
get_JsonValue'Call'function (JsonValue'Call_newtype_ struct) =
    U'.getPtr 0 struct
    >>= C'.fromPtr (U'.message struct)
has_JsonValue'Call'function :: U'.ReadCtx m msg => JsonValue'Call msg -> m Bool
has_JsonValue'Call'function(JsonValue'Call_newtype_ struct) = Data.Maybe.isJust <$> U'.getPtr 0 struct
set_JsonValue'Call'function :: U'.RWCtx m s => JsonValue'Call (M'.MutMsg s) -> (B'.Text (M'.MutMsg s)) -> m ()
set_JsonValue'Call'function (JsonValue'Call_newtype_ struct) value = do
    ptr <- C'.toPtr (U'.message struct) value
    U'.setPtr ptr 0 struct
new_JsonValue'Call'function :: U'.RWCtx m s => Int -> JsonValue'Call (M'.MutMsg s) -> m ((B'.Text (M'.MutMsg s)))
new_JsonValue'Call'function len struct = do
    result <- B'.newText (U'.message struct) len
    set_JsonValue'Call'function struct result
    pure result
get_JsonValue'Call'params :: U'.ReadCtx m msg => JsonValue'Call msg -> m (B'.List msg (JsonValue msg))
get_JsonValue'Call'params (JsonValue'Call_newtype_ struct) =
    U'.getPtr 1 struct
    >>= C'.fromPtr (U'.message struct)
has_JsonValue'Call'params :: U'.ReadCtx m msg => JsonValue'Call msg -> m Bool
has_JsonValue'Call'params(JsonValue'Call_newtype_ struct) = Data.Maybe.isJust <$> U'.getPtr 1 struct
set_JsonValue'Call'params :: U'.RWCtx m s => JsonValue'Call (M'.MutMsg s) -> (B'.List (M'.MutMsg s) (JsonValue (M'.MutMsg s))) -> m ()
set_JsonValue'Call'params (JsonValue'Call_newtype_ struct) value = do
    ptr <- C'.toPtr (U'.message struct) value
    U'.setPtr ptr 1 struct
new_JsonValue'Call'params :: U'.RWCtx m s => Int -> JsonValue'Call (M'.MutMsg s) -> m ((B'.List (M'.MutMsg s) (JsonValue (M'.MutMsg s))))
new_JsonValue'Call'params len struct = do
    result <- C'.newList (U'.message struct) len
    set_JsonValue'Call'params struct result
    pure result
newtype JsonValue'Field msg = JsonValue'Field_newtype_ (U'.Struct msg)
instance U'.TraverseMsg JsonValue'Field where
    tMsg f (JsonValue'Field_newtype_ s) = JsonValue'Field_newtype_ <$> U'.tMsg f s
instance C'.FromStruct msg (JsonValue'Field msg) where
    fromStruct = pure . JsonValue'Field_newtype_
instance C'.ToStruct msg (JsonValue'Field msg) where
    toStruct (JsonValue'Field_newtype_ struct) = struct
instance U'.HasMessage (JsonValue'Field msg) where
    type InMessage (JsonValue'Field msg) = msg
    message (JsonValue'Field_newtype_ struct) = U'.message struct
instance U'.MessageDefault (JsonValue'Field msg) where
    messageDefault = JsonValue'Field_newtype_ . U'.messageDefault
instance B'.ListElem msg (JsonValue'Field msg) where
    newtype List msg (JsonValue'Field msg) = List_JsonValue'Field (U'.ListOf msg (U'.Struct msg))
    listFromPtr msg ptr = List_JsonValue'Field <$> C'.fromPtr msg ptr
    toUntypedList (List_JsonValue'Field l) = U'.ListStruct l
    length (List_JsonValue'Field l) = U'.length l
    index i (List_JsonValue'Field l) = U'.index i l >>= (let {go :: U'.ReadCtx m msg => U'.Struct msg -> m (JsonValue'Field msg); go = C'.fromStruct} in go)
instance C'.FromPtr msg (JsonValue'Field msg) where
    fromPtr msg ptr = JsonValue'Field_newtype_ <$> C'.fromPtr msg ptr
instance C'.ToPtr s (JsonValue'Field (M'.MutMsg s)) where
    toPtr msg (JsonValue'Field_newtype_ struct) = C'.toPtr msg struct
instance B'.MutListElem s (JsonValue'Field (M'.MutMsg s)) where
    setIndex (JsonValue'Field_newtype_ elt) i (List_JsonValue'Field l) = U'.setIndex elt i l
    newList msg len = List_JsonValue'Field <$> U'.allocCompositeList msg 0 2 len
instance C'.Allocate s (JsonValue'Field (M'.MutMsg s)) where
    new msg = JsonValue'Field_newtype_ <$> U'.allocStruct msg 0 2
get_JsonValue'Field'name :: U'.ReadCtx m msg => JsonValue'Field msg -> m (B'.Text msg)
get_JsonValue'Field'name (JsonValue'Field_newtype_ struct) =
    U'.getPtr 0 struct
    >>= C'.fromPtr (U'.message struct)
has_JsonValue'Field'name :: U'.ReadCtx m msg => JsonValue'Field msg -> m Bool
has_JsonValue'Field'name(JsonValue'Field_newtype_ struct) = Data.Maybe.isJust <$> U'.getPtr 0 struct
set_JsonValue'Field'name :: U'.RWCtx m s => JsonValue'Field (M'.MutMsg s) -> (B'.Text (M'.MutMsg s)) -> m ()
set_JsonValue'Field'name (JsonValue'Field_newtype_ struct) value = do
    ptr <- C'.toPtr (U'.message struct) value
    U'.setPtr ptr 0 struct
new_JsonValue'Field'name :: U'.RWCtx m s => Int -> JsonValue'Field (M'.MutMsg s) -> m ((B'.Text (M'.MutMsg s)))
new_JsonValue'Field'name len struct = do
    result <- B'.newText (U'.message struct) len
    set_JsonValue'Field'name struct result
    pure result
get_JsonValue'Field'value :: U'.ReadCtx m msg => JsonValue'Field msg -> m (JsonValue msg)
get_JsonValue'Field'value (JsonValue'Field_newtype_ struct) =
    U'.getPtr 1 struct
    >>= C'.fromPtr (U'.message struct)
has_JsonValue'Field'value :: U'.ReadCtx m msg => JsonValue'Field msg -> m Bool
has_JsonValue'Field'value(JsonValue'Field_newtype_ struct) = Data.Maybe.isJust <$> U'.getPtr 1 struct
set_JsonValue'Field'value :: U'.RWCtx m s => JsonValue'Field (M'.MutMsg s) -> (JsonValue (M'.MutMsg s)) -> m ()
set_JsonValue'Field'value (JsonValue'Field_newtype_ struct) value = do
    ptr <- C'.toPtr (U'.message struct) value
    U'.setPtr ptr 1 struct
new_JsonValue'Field'value :: U'.RWCtx m s => JsonValue'Field (M'.MutMsg s) -> m ((JsonValue (M'.MutMsg s)))
new_JsonValue'Field'value struct = do
    result <- C'.new (U'.message struct)
    set_JsonValue'Field'value struct result
    pure result