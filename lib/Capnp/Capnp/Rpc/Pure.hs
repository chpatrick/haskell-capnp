{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}
module Capnp.Capnp.Rpc.Pure where

-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: capnp/rpc.capnp

import Data.Int
import Data.Word

import Data.Capnp.Untyped.Pure (List)
import Data.Capnp.Basics.Pure (Data, Text)
import Control.Monad.Catch (MonadThrow)
import Data.Capnp.TraversalLimit (MonadLimit)

import qualified Data.Capnp.Message as M'
import qualified Data.Capnp.Untyped.Pure as PU'
import qualified Codec.Capnp as C'

import qualified Capnp.ById.Xb312981b2552a250
import qualified Capnp.ById.Xbdf87d7bb8304e81.Pure
import qualified Capnp.ById.Xbdf87d7bb8304e81

data Call
    = Call
        { questionId :: Word32
        , target :: MessageTarget
        , interfaceId :: Word64
        , methodId :: Word16
        , params :: Payload
        , sendResultsTo :: Call'sendResultsTo
        , allowThirdPartyTailCall :: Bool
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Call M'.ConstMessage) Call where
    decerialize raw = Call
            <$> (Capnp.ById.Xb312981b2552a250.get_Call'questionId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Call'target raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Call'interfaceId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Call'methodId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Call'params raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Call'sendResultsTo raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Call'allowThirdPartyTailCall raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage Call where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Call M'.ConstMessage)

data CapDescriptor
    = CapDescriptor'none
    | CapDescriptor'senderHosted (Word32)
    | CapDescriptor'senderPromise (Word32)
    | CapDescriptor'receiverHosted (Word32)
    | CapDescriptor'receiverAnswer (PromisedAnswer)
    | CapDescriptor'thirdPartyHosted (ThirdPartyCapDescriptor)
    | CapDescriptor'unknown' (Word16)
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.CapDescriptor M'.ConstMessage) CapDescriptor where
    decerialize raw = case raw of

        Capnp.ById.Xb312981b2552a250.CapDescriptor'none -> pure CapDescriptor'none
        Capnp.ById.Xb312981b2552a250.CapDescriptor'senderHosted val -> CapDescriptor'senderHosted <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.CapDescriptor'senderPromise val -> CapDescriptor'senderPromise <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.CapDescriptor'receiverHosted val -> CapDescriptor'receiverHosted <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.CapDescriptor'receiverAnswer val -> CapDescriptor'receiverAnswer <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.CapDescriptor'thirdPartyHosted val -> CapDescriptor'thirdPartyHosted <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.CapDescriptor'unknown' val -> CapDescriptor'unknown' <$> C'.decerialize val

instance C'.IsStruct M'.ConstMessage CapDescriptor where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.CapDescriptor M'.ConstMessage)

data Message
    = Message'unimplemented (Message)
    | Message'abort (Exception)
    | Message'call (Call)
    | Message'return (Return)
    | Message'finish (Finish)
    | Message'resolve (Resolve)
    | Message'release (Release)
    | Message'obsoleteSave (Maybe (PU'.PtrType))
    | Message'bootstrap (Bootstrap)
    | Message'obsoleteDelete (Maybe (PU'.PtrType))
    | Message'provide (Provide)
    | Message'accept (Accept)
    | Message'join (Join)
    | Message'disembargo (Disembargo)
    | Message'unknown' (Word16)
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Message M'.ConstMessage) Message where
    decerialize raw = case raw of

        Capnp.ById.Xb312981b2552a250.Message'unimplemented val -> Message'unimplemented <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'abort val -> Message'abort <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'call val -> Message'call <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'return val -> Message'return <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'finish val -> Message'finish <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'resolve val -> Message'resolve <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'release val -> Message'release <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'obsoleteSave val -> Message'obsoleteSave <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'bootstrap val -> Message'bootstrap <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'obsoleteDelete val -> Message'obsoleteDelete <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'provide val -> Message'provide <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'accept val -> Message'accept <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'join val -> Message'join <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'disembargo val -> Message'disembargo <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Message'unknown' val -> Message'unknown' <$> C'.decerialize val

instance C'.IsStruct M'.ConstMessage Message where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Message M'.ConstMessage)

data MessageTarget
    = MessageTarget'importedCap (Word32)
    | MessageTarget'promisedAnswer (PromisedAnswer)
    | MessageTarget'unknown' (Word16)
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.MessageTarget M'.ConstMessage) MessageTarget where
    decerialize raw = case raw of

        Capnp.ById.Xb312981b2552a250.MessageTarget'importedCap val -> MessageTarget'importedCap <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.MessageTarget'promisedAnswer val -> MessageTarget'promisedAnswer <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.MessageTarget'unknown' val -> MessageTarget'unknown' <$> C'.decerialize val

instance C'.IsStruct M'.ConstMessage MessageTarget where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.MessageTarget M'.ConstMessage)

data Payload
    = Payload
        { content :: Maybe (PU'.PtrType)
        , capTable :: List (CapDescriptor)
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Payload M'.ConstMessage) Payload where
    decerialize raw = Payload
            <$> (Capnp.ById.Xb312981b2552a250.get_Payload'content raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Payload'capTable raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage Payload where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Payload M'.ConstMessage)

data Provide
    = Provide
        { questionId :: Word32
        , target :: MessageTarget
        , recipient :: Maybe (PU'.PtrType)
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Provide M'.ConstMessage) Provide where
    decerialize raw = Provide
            <$> (Capnp.ById.Xb312981b2552a250.get_Provide'questionId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Provide'target raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Provide'recipient raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage Provide where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Provide M'.ConstMessage)

data Return
    = Return'
        { answerId :: Word32
        , releaseParamCaps :: Bool
        , union' :: Return'
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Return M'.ConstMessage) Return where
    decerialize raw = Return'
            <$> (Capnp.ById.Xb312981b2552a250.get_Return''answerId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Return''releaseParamCaps raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Return''union' raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage Return where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Return M'.ConstMessage)

data Return'
    = Return'results (Payload)
    | Return'exception (Exception)
    | Return'canceled
    | Return'resultsSentElsewhere
    | Return'takeFromOtherQuestion (Word32)
    | Return'acceptFromThirdParty (Maybe (PU'.PtrType))
    | Return'unknown' (Word16)
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Return' M'.ConstMessage) Return' where
    decerialize raw = case raw of

        Capnp.ById.Xb312981b2552a250.Return'results val -> Return'results <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Return'exception val -> Return'exception <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Return'canceled -> pure Return'canceled
        Capnp.ById.Xb312981b2552a250.Return'resultsSentElsewhere -> pure Return'resultsSentElsewhere
        Capnp.ById.Xb312981b2552a250.Return'takeFromOtherQuestion val -> Return'takeFromOtherQuestion <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Return'acceptFromThirdParty val -> Return'acceptFromThirdParty <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Return'unknown' val -> Return'unknown' <$> C'.decerialize val

instance C'.IsStruct M'.ConstMessage Return' where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Return' M'.ConstMessage)

data Release
    = Release
        { id :: Word32
        , referenceCount :: Word32
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Release M'.ConstMessage) Release where
    decerialize raw = Release
            <$> (Capnp.ById.Xb312981b2552a250.get_Release'id raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Release'referenceCount raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage Release where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Release M'.ConstMessage)

data Exception'Type
    = Exception'Type'failed
    | Exception'Type'overloaded
    | Exception'Type'disconnected
    | Exception'Type'unimplemented
    | Exception'Type'unknown' (Word16)
    deriving(Show, Read, Eq)

instance C'.Decerialize Capnp.ById.Xb312981b2552a250.Exception'Type Exception'Type where
    decerialize raw = case raw of

        Capnp.ById.Xb312981b2552a250.Exception'Type'failed -> pure Exception'Type'failed
        Capnp.ById.Xb312981b2552a250.Exception'Type'overloaded -> pure Exception'Type'overloaded
        Capnp.ById.Xb312981b2552a250.Exception'Type'disconnected -> pure Exception'Type'disconnected
        Capnp.ById.Xb312981b2552a250.Exception'Type'unimplemented -> pure Exception'Type'unimplemented
        Capnp.ById.Xb312981b2552a250.Exception'Type'unknown' val -> Exception'Type'unknown' <$> C'.decerialize val

data Resolve
    = Resolve'
        { promiseId :: Word32
        , union' :: Resolve'
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Resolve M'.ConstMessage) Resolve where
    decerialize raw = Resolve'
            <$> (Capnp.ById.Xb312981b2552a250.get_Resolve''promiseId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Resolve''union' raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage Resolve where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Resolve M'.ConstMessage)

data Resolve'
    = Resolve'cap (CapDescriptor)
    | Resolve'exception (Exception)
    | Resolve'unknown' (Word16)
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Resolve' M'.ConstMessage) Resolve' where
    decerialize raw = case raw of

        Capnp.ById.Xb312981b2552a250.Resolve'cap val -> Resolve'cap <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Resolve'exception val -> Resolve'exception <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Resolve'unknown' val -> Resolve'unknown' <$> C'.decerialize val

instance C'.IsStruct M'.ConstMessage Resolve' where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Resolve' M'.ConstMessage)

data ThirdPartyCapDescriptor
    = ThirdPartyCapDescriptor
        { id :: Maybe (PU'.PtrType)
        , vineId :: Word32
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.ThirdPartyCapDescriptor M'.ConstMessage) ThirdPartyCapDescriptor where
    decerialize raw = ThirdPartyCapDescriptor
            <$> (Capnp.ById.Xb312981b2552a250.get_ThirdPartyCapDescriptor'id raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_ThirdPartyCapDescriptor'vineId raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage ThirdPartyCapDescriptor where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.ThirdPartyCapDescriptor M'.ConstMessage)

data Finish
    = Finish
        { questionId :: Word32
        , releaseResultCaps :: Bool
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Finish M'.ConstMessage) Finish where
    decerialize raw = Finish
            <$> (Capnp.ById.Xb312981b2552a250.get_Finish'questionId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Finish'releaseResultCaps raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage Finish where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Finish M'.ConstMessage)

data Accept
    = Accept
        { questionId :: Word32
        , provision :: Maybe (PU'.PtrType)
        , embargo :: Bool
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Accept M'.ConstMessage) Accept where
    decerialize raw = Accept
            <$> (Capnp.ById.Xb312981b2552a250.get_Accept'questionId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Accept'provision raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Accept'embargo raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage Accept where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Accept M'.ConstMessage)

data Disembargo'context
    = Disembargo'context'senderLoopback (Word32)
    | Disembargo'context'receiverLoopback (Word32)
    | Disembargo'context'accept
    | Disembargo'context'provide (Word32)
    | Disembargo'context'unknown' (Word16)
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Disembargo'context M'.ConstMessage) Disembargo'context where
    decerialize raw = case raw of

        Capnp.ById.Xb312981b2552a250.Disembargo'context'senderLoopback val -> Disembargo'context'senderLoopback <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Disembargo'context'receiverLoopback val -> Disembargo'context'receiverLoopback <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Disembargo'context'accept -> pure Disembargo'context'accept
        Capnp.ById.Xb312981b2552a250.Disembargo'context'provide val -> Disembargo'context'provide <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Disembargo'context'unknown' val -> Disembargo'context'unknown' <$> C'.decerialize val

instance C'.IsStruct M'.ConstMessage Disembargo'context where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Disembargo'context M'.ConstMessage)

data Exception
    = Exception
        { reason :: Text
        , obsoleteIsCallersFault :: Bool
        , obsoleteDurability :: Word16
        , type_ :: Exception'Type
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Exception M'.ConstMessage) Exception where
    decerialize raw = Exception
            <$> (Capnp.ById.Xb312981b2552a250.get_Exception'reason raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Exception'obsoleteIsCallersFault raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Exception'obsoleteDurability raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Exception'type_ raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage Exception where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Exception M'.ConstMessage)

data PromisedAnswer
    = PromisedAnswer
        { questionId :: Word32
        , transform :: List (PromisedAnswer'Op)
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.PromisedAnswer M'.ConstMessage) PromisedAnswer where
    decerialize raw = PromisedAnswer
            <$> (Capnp.ById.Xb312981b2552a250.get_PromisedAnswer'questionId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_PromisedAnswer'transform raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage PromisedAnswer where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.PromisedAnswer M'.ConstMessage)

data Call'sendResultsTo
    = Call'sendResultsTo'caller
    | Call'sendResultsTo'yourself
    | Call'sendResultsTo'thirdParty (Maybe (PU'.PtrType))
    | Call'sendResultsTo'unknown' (Word16)
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Call'sendResultsTo M'.ConstMessage) Call'sendResultsTo where
    decerialize raw = case raw of

        Capnp.ById.Xb312981b2552a250.Call'sendResultsTo'caller -> pure Call'sendResultsTo'caller
        Capnp.ById.Xb312981b2552a250.Call'sendResultsTo'yourself -> pure Call'sendResultsTo'yourself
        Capnp.ById.Xb312981b2552a250.Call'sendResultsTo'thirdParty val -> Call'sendResultsTo'thirdParty <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.Call'sendResultsTo'unknown' val -> Call'sendResultsTo'unknown' <$> C'.decerialize val

instance C'.IsStruct M'.ConstMessage Call'sendResultsTo where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Call'sendResultsTo M'.ConstMessage)

data Bootstrap
    = Bootstrap
        { questionId :: Word32
        , deprecatedObjectId :: Maybe (PU'.PtrType)
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Bootstrap M'.ConstMessage) Bootstrap where
    decerialize raw = Bootstrap
            <$> (Capnp.ById.Xb312981b2552a250.get_Bootstrap'questionId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Bootstrap'deprecatedObjectId raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage Bootstrap where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Bootstrap M'.ConstMessage)

data PromisedAnswer'Op
    = PromisedAnswer'Op'noop
    | PromisedAnswer'Op'getPointerField (Word16)
    | PromisedAnswer'Op'unknown' (Word16)
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.PromisedAnswer'Op M'.ConstMessage) PromisedAnswer'Op where
    decerialize raw = case raw of

        Capnp.ById.Xb312981b2552a250.PromisedAnswer'Op'noop -> pure PromisedAnswer'Op'noop
        Capnp.ById.Xb312981b2552a250.PromisedAnswer'Op'getPointerField val -> PromisedAnswer'Op'getPointerField <$> C'.decerialize val
        Capnp.ById.Xb312981b2552a250.PromisedAnswer'Op'unknown' val -> PromisedAnswer'Op'unknown' <$> C'.decerialize val

instance C'.IsStruct M'.ConstMessage PromisedAnswer'Op where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.PromisedAnswer'Op M'.ConstMessage)

data Disembargo
    = Disembargo
        { target :: MessageTarget
        , context :: Disembargo'context
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Disembargo M'.ConstMessage) Disembargo where
    decerialize raw = Disembargo
            <$> (Capnp.ById.Xb312981b2552a250.get_Disembargo'target raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Disembargo'context raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage Disembargo where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Disembargo M'.ConstMessage)

data Join
    = Join
        { questionId :: Word32
        , target :: MessageTarget
        , keyPart :: Maybe (PU'.PtrType)
        }
    deriving(Show, Read, Eq)

instance C'.Decerialize (Capnp.ById.Xb312981b2552a250.Join M'.ConstMessage) Join where
    decerialize raw = Join
            <$> (Capnp.ById.Xb312981b2552a250.get_Join'questionId raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Join'target raw >>= C'.decerialize)
            <*> (Capnp.ById.Xb312981b2552a250.get_Join'keyPart raw >>= C'.decerialize)

instance C'.IsStruct M'.ConstMessage Join where
    fromStruct struct = do
        raw <- C'.fromStruct struct
        C'.decerialize (raw :: Capnp.ById.Xb312981b2552a250.Join M'.ConstMessage)

