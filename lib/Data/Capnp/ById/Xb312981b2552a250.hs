{-# OPTIONS_GHC -Wno-unused-imports #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE KindSignatures #-}
module Data.Capnp.ById.Xb312981b2552a250 where

-- Code generated by capnpc-haskell. DO NOT EDIT.
-- Generated from schema file: /usr/include/capnp/rpc.capnp

import Data.Int
import Data.Word
import qualified Data.Bits
import qualified Data.Maybe
import qualified Codec.Capnp
import qualified Data.Capnp.BuiltinTypes
import qualified Data.Capnp.TraversalLimit
import qualified Data.Capnp.Untyped

import qualified Data.Capnp.ById.Xbdf87d7bb8304e81

newtype Call (m :: * -> *) b = Call (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Call m b) b where
    fromStruct = pure . Call
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Call m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Call m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_Call'questionId :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m Word32
get_Call'questionId (Call struct) = Codec.Capnp.getWordField struct 0 0 0

has_Call'questionId :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m Bool
has_Call'questionId(Call struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Call'target :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m (MessageTarget m b)
get_Call'target (Call struct) =
    Data.Capnp.Untyped.getPtr 0 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_Call'target :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m Bool
has_Call'target(Call struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 0 struct
get_Call'interfaceId :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m Word64
get_Call'interfaceId (Call struct) = Codec.Capnp.getWordField struct 1 0 0

has_Call'interfaceId :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m Bool
has_Call'interfaceId(Call struct) = pure $ 1 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Call'methodId :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m Word16
get_Call'methodId (Call struct) = Codec.Capnp.getWordField struct 0 32 0

has_Call'methodId :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m Bool
has_Call'methodId(Call struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Call'params :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m (Payload m b)
get_Call'params (Call struct) =
    Data.Capnp.Untyped.getPtr 1 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_Call'params :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m Bool
has_Call'params(Call struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 1 struct
get_Call'sendResultsTo :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m (Call'sendResultsTo m b)
get_Call'sendResultsTo (Call struct) = Codec.Capnp.fromStruct struct

has_Call'sendResultsTo :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m Bool
has_Call'sendResultsTo(Call struct) = pure True
get_Call'allowThirdPartyTailCall :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m Bool
get_Call'allowThirdPartyTailCall (Call struct) = Codec.Capnp.getWordField struct 2 0 0

has_Call'allowThirdPartyTailCall :: Data.Capnp.Untyped.ReadCtx m b => Call m b -> m Bool
has_Call'allowThirdPartyTailCall(Call struct) = pure $ 2 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
data CapDescriptor (m :: * -> *) b
    = CapDescriptor'none
    | CapDescriptor'senderHosted Word32
    | CapDescriptor'senderPromise Word32
    | CapDescriptor'receiverHosted Word32
    | CapDescriptor'receiverAnswer (PromisedAnswer m b)
    | CapDescriptor'thirdPartyHosted (ThirdPartyCapDescriptor m b)
    | CapDescriptor'unknown' Word16







instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (CapDescriptor m b) b where
    fromStruct struct = do
        tag <-  Codec.Capnp.getWordField struct 0 0 0
        case tag of
            5 -> CapDescriptor'thirdPartyHosted <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            4 -> CapDescriptor'receiverAnswer <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            3 -> CapDescriptor'receiverHosted <$>  Codec.Capnp.getWordField struct 0 32 0
            2 -> CapDescriptor'senderPromise <$>  Codec.Capnp.getWordField struct 0 32 0
            1 -> CapDescriptor'senderHosted <$>  Codec.Capnp.getWordField struct 0 32 0
            0 -> pure CapDescriptor'none
            _ -> pure $ CapDescriptor'unknown' tag

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (CapDescriptor m b) b where
    fromPtr = Codec.Capnp.structPtr
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (CapDescriptor m b)) b where
    fromPtr = Codec.Capnp.structListPtr

data Message (m :: * -> *) b
    = Message'unimplemented (Message m b)
    | Message'abort (Exception m b)
    | Message'call (Call m b)
    | Message'return (Return m b)
    | Message'finish (Finish m b)
    | Message'resolve (Resolve m b)
    | Message'release (Release m b)
    | Message'obsoleteSave (Maybe (Data.Capnp.Untyped.Ptr m b))
    | Message'bootstrap (Bootstrap m b)
    | Message'obsoleteDelete (Maybe (Data.Capnp.Untyped.Ptr m b))
    | Message'provide (Provide m b)
    | Message'accept (Accept m b)
    | Message'join (Join m b)
    | Message'disembargo (Disembargo m b)
    | Message'unknown' Word16















instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Message m b) b where
    fromStruct struct = do
        tag <-  Codec.Capnp.getWordField struct 0 0 0
        case tag of
            13 -> Message'disembargo <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            12 -> Message'join <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            11 -> Message'accept <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            10 -> Message'provide <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            9 -> Message'obsoleteDelete <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            8 -> Message'bootstrap <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            7 -> Message'obsoleteSave <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            6 -> Message'release <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            5 -> Message'resolve <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            4 -> Message'finish <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            3 -> Message'return <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            2 -> Message'call <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            1 -> Message'abort <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            0 -> Message'unimplemented <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            _ -> pure $ Message'unknown' tag

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Message m b) b where
    fromPtr = Codec.Capnp.structPtr
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Message m b)) b where
    fromPtr = Codec.Capnp.structListPtr

data MessageTarget (m :: * -> *) b
    = MessageTarget'importedCap Word32
    | MessageTarget'promisedAnswer (PromisedAnswer m b)
    | MessageTarget'unknown' Word16



instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (MessageTarget m b) b where
    fromStruct struct = do
        tag <-  Codec.Capnp.getWordField struct 0 32 0
        case tag of
            1 -> MessageTarget'promisedAnswer <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            0 -> MessageTarget'importedCap <$>  Codec.Capnp.getWordField struct 0 0 0
            _ -> pure $ MessageTarget'unknown' tag

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (MessageTarget m b) b where
    fromPtr = Codec.Capnp.structPtr
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (MessageTarget m b)) b where
    fromPtr = Codec.Capnp.structListPtr

newtype Payload (m :: * -> *) b = Payload (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Payload m b) b where
    fromStruct = pure . Payload
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Payload m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Payload m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_Payload'content :: Data.Capnp.Untyped.ReadCtx m b => Payload m b -> m (Maybe (Data.Capnp.Untyped.Ptr m b))
get_Payload'content (Payload struct) =
    Data.Capnp.Untyped.getPtr 0 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_Payload'content :: Data.Capnp.Untyped.ReadCtx m b => Payload m b -> m Bool
has_Payload'content(Payload struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 0 struct
get_Payload'capTable :: Data.Capnp.Untyped.ReadCtx m b => Payload m b -> m (Data.Capnp.Untyped.ListOf m b (CapDescriptor m b))
get_Payload'capTable (Payload struct) =
    Data.Capnp.Untyped.getPtr 1 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_Payload'capTable :: Data.Capnp.Untyped.ReadCtx m b => Payload m b -> m Bool
has_Payload'capTable(Payload struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 1 struct
newtype Provide (m :: * -> *) b = Provide (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Provide m b) b where
    fromStruct = pure . Provide
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Provide m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Provide m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_Provide'questionId :: Data.Capnp.Untyped.ReadCtx m b => Provide m b -> m Word32
get_Provide'questionId (Provide struct) = Codec.Capnp.getWordField struct 0 0 0

has_Provide'questionId :: Data.Capnp.Untyped.ReadCtx m b => Provide m b -> m Bool
has_Provide'questionId(Provide struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Provide'target :: Data.Capnp.Untyped.ReadCtx m b => Provide m b -> m (MessageTarget m b)
get_Provide'target (Provide struct) =
    Data.Capnp.Untyped.getPtr 0 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_Provide'target :: Data.Capnp.Untyped.ReadCtx m b => Provide m b -> m Bool
has_Provide'target(Provide struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 0 struct
get_Provide'recipient :: Data.Capnp.Untyped.ReadCtx m b => Provide m b -> m (Maybe (Data.Capnp.Untyped.Ptr m b))
get_Provide'recipient (Provide struct) =
    Data.Capnp.Untyped.getPtr 1 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_Provide'recipient :: Data.Capnp.Untyped.ReadCtx m b => Provide m b -> m Bool
has_Provide'recipient(Provide struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 1 struct
newtype Return (m :: * -> *) b = Return (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Return m b) b where
    fromStruct = pure . Return
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Return m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Return m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_Return''answerId :: Data.Capnp.Untyped.ReadCtx m b => Return m b -> m Word32
get_Return''answerId (Return struct) = Codec.Capnp.getWordField struct 0 0 0

has_Return''answerId :: Data.Capnp.Untyped.ReadCtx m b => Return m b -> m Bool
has_Return''answerId(Return struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Return''releaseParamCaps :: Data.Capnp.Untyped.ReadCtx m b => Return m b -> m Bool
get_Return''releaseParamCaps (Return struct) = Codec.Capnp.getWordField struct 0 32 1

has_Return''releaseParamCaps :: Data.Capnp.Untyped.ReadCtx m b => Return m b -> m Bool
has_Return''releaseParamCaps(Return struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Return''union' :: Data.Capnp.Untyped.ReadCtx m b => Return m b -> m (Return' m b)
get_Return''union' (Return struct) = Codec.Capnp.fromStruct struct

has_Return''union' :: Data.Capnp.Untyped.ReadCtx m b => Return m b -> m Bool
has_Return''union'(Return struct) = pure True
data Return' (m :: * -> *) b
    = Return'results (Payload m b)
    | Return'exception (Exception m b)
    | Return'canceled
    | Return'resultsSentElsewhere
    | Return'takeFromOtherQuestion Word32
    | Return'acceptFromThirdParty (Maybe (Data.Capnp.Untyped.Ptr m b))
    | Return'unknown' Word16







instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Return' m b) b where
    fromStruct struct = do
        tag <-  Codec.Capnp.getWordField struct 0 48 0
        case tag of
            5 -> Return'acceptFromThirdParty <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            4 -> Return'takeFromOtherQuestion <$>  Codec.Capnp.getWordField struct 1 0 0
            3 -> pure Return'resultsSentElsewhere
            2 -> pure Return'canceled
            1 -> Return'exception <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            0 -> Return'results <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            _ -> pure $ Return'unknown' tag

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Return' m b) b where
    fromPtr = Codec.Capnp.structPtr
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Return' m b)) b where
    fromPtr = Codec.Capnp.structListPtr

newtype Release (m :: * -> *) b = Release (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Release m b) b where
    fromStruct = pure . Release
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Release m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Release m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_Release'id :: Data.Capnp.Untyped.ReadCtx m b => Release m b -> m Word32
get_Release'id (Release struct) = Codec.Capnp.getWordField struct 0 0 0

has_Release'id :: Data.Capnp.Untyped.ReadCtx m b => Release m b -> m Bool
has_Release'id(Release struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Release'referenceCount :: Data.Capnp.Untyped.ReadCtx m b => Release m b -> m Word32
get_Release'referenceCount (Release struct) = Codec.Capnp.getWordField struct 0 32 0

has_Release'referenceCount :: Data.Capnp.Untyped.ReadCtx m b => Release m b -> m Bool
has_Release'referenceCount(Release struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
data Exception'Type (m :: * -> *) b
    = Exception'Type'failed
    | Exception'Type'overloaded
    | Exception'Type'disconnected
    | Exception'Type'unimplemented
    | Exception'Type'unknown' Word16
instance Enum (Exception'Type m b) where
    toEnum = Codec.Capnp.fromWord . fromIntegral
    fromEnum = fromIntegral . Codec.Capnp.toWord


instance Codec.Capnp.IsWord (Exception'Type m b) where
    fromWord 3 = Exception'Type'unimplemented
    fromWord 2 = Exception'Type'disconnected
    fromWord 1 = Exception'Type'overloaded
    fromWord 0 = Exception'Type'failed
    fromWord tag = Exception'Type'unknown' (fromIntegral tag)
    toWord Exception'Type'unimplemented = 3
    toWord Exception'Type'disconnected = 2
    toWord Exception'Type'overloaded = 1
    toWord Exception'Type'failed = 0
    toWord (Exception'Type'unknown' tag) = fromIntegral tag
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Exception'Type m b)) b where
    fromPtr msg ptr = fmap
       (fmap (toEnum . (fromIntegral :: Word16 -> Int)))
       (Codec.Capnp.fromPtr msg ptr)

newtype Resolve (m :: * -> *) b = Resolve (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Resolve m b) b where
    fromStruct = pure . Resolve
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Resolve m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Resolve m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_Resolve''promiseId :: Data.Capnp.Untyped.ReadCtx m b => Resolve m b -> m Word32
get_Resolve''promiseId (Resolve struct) = Codec.Capnp.getWordField struct 0 0 0

has_Resolve''promiseId :: Data.Capnp.Untyped.ReadCtx m b => Resolve m b -> m Bool
has_Resolve''promiseId(Resolve struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Resolve''union' :: Data.Capnp.Untyped.ReadCtx m b => Resolve m b -> m (Resolve' m b)
get_Resolve''union' (Resolve struct) = Codec.Capnp.fromStruct struct

has_Resolve''union' :: Data.Capnp.Untyped.ReadCtx m b => Resolve m b -> m Bool
has_Resolve''union'(Resolve struct) = pure True
data Resolve' (m :: * -> *) b
    = Resolve'cap (CapDescriptor m b)
    | Resolve'exception (Exception m b)
    | Resolve'unknown' Word16



instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Resolve' m b) b where
    fromStruct struct = do
        tag <-  Codec.Capnp.getWordField struct 0 32 0
        case tag of
            1 -> Resolve'exception <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            0 -> Resolve'cap <$>  (Data.Capnp.Untyped.getPtr 0 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            _ -> pure $ Resolve'unknown' tag

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Resolve' m b) b where
    fromPtr = Codec.Capnp.structPtr
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Resolve' m b)) b where
    fromPtr = Codec.Capnp.structListPtr

newtype ThirdPartyCapDescriptor (m :: * -> *) b = ThirdPartyCapDescriptor (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (ThirdPartyCapDescriptor m b) b where
    fromStruct = pure . ThirdPartyCapDescriptor
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (ThirdPartyCapDescriptor m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (ThirdPartyCapDescriptor m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_ThirdPartyCapDescriptor'id :: Data.Capnp.Untyped.ReadCtx m b => ThirdPartyCapDescriptor m b -> m (Maybe (Data.Capnp.Untyped.Ptr m b))
get_ThirdPartyCapDescriptor'id (ThirdPartyCapDescriptor struct) =
    Data.Capnp.Untyped.getPtr 0 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_ThirdPartyCapDescriptor'id :: Data.Capnp.Untyped.ReadCtx m b => ThirdPartyCapDescriptor m b -> m Bool
has_ThirdPartyCapDescriptor'id(ThirdPartyCapDescriptor struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 0 struct
get_ThirdPartyCapDescriptor'vineId :: Data.Capnp.Untyped.ReadCtx m b => ThirdPartyCapDescriptor m b -> m Word32
get_ThirdPartyCapDescriptor'vineId (ThirdPartyCapDescriptor struct) = Codec.Capnp.getWordField struct 0 0 0

has_ThirdPartyCapDescriptor'vineId :: Data.Capnp.Untyped.ReadCtx m b => ThirdPartyCapDescriptor m b -> m Bool
has_ThirdPartyCapDescriptor'vineId(ThirdPartyCapDescriptor struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
newtype Finish (m :: * -> *) b = Finish (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Finish m b) b where
    fromStruct = pure . Finish
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Finish m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Finish m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_Finish'questionId :: Data.Capnp.Untyped.ReadCtx m b => Finish m b -> m Word32
get_Finish'questionId (Finish struct) = Codec.Capnp.getWordField struct 0 0 0

has_Finish'questionId :: Data.Capnp.Untyped.ReadCtx m b => Finish m b -> m Bool
has_Finish'questionId(Finish struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Finish'releaseResultCaps :: Data.Capnp.Untyped.ReadCtx m b => Finish m b -> m Bool
get_Finish'releaseResultCaps (Finish struct) = Codec.Capnp.getWordField struct 0 32 1

has_Finish'releaseResultCaps :: Data.Capnp.Untyped.ReadCtx m b => Finish m b -> m Bool
has_Finish'releaseResultCaps(Finish struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
newtype Accept (m :: * -> *) b = Accept (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Accept m b) b where
    fromStruct = pure . Accept
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Accept m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Accept m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_Accept'questionId :: Data.Capnp.Untyped.ReadCtx m b => Accept m b -> m Word32
get_Accept'questionId (Accept struct) = Codec.Capnp.getWordField struct 0 0 0

has_Accept'questionId :: Data.Capnp.Untyped.ReadCtx m b => Accept m b -> m Bool
has_Accept'questionId(Accept struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Accept'provision :: Data.Capnp.Untyped.ReadCtx m b => Accept m b -> m (Maybe (Data.Capnp.Untyped.Ptr m b))
get_Accept'provision (Accept struct) =
    Data.Capnp.Untyped.getPtr 0 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_Accept'provision :: Data.Capnp.Untyped.ReadCtx m b => Accept m b -> m Bool
has_Accept'provision(Accept struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 0 struct
get_Accept'embargo :: Data.Capnp.Untyped.ReadCtx m b => Accept m b -> m Bool
get_Accept'embargo (Accept struct) = Codec.Capnp.getWordField struct 0 32 0

has_Accept'embargo :: Data.Capnp.Untyped.ReadCtx m b => Accept m b -> m Bool
has_Accept'embargo(Accept struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
data Disembargo'context (m :: * -> *) b
    = Disembargo'context'senderLoopback Word32
    | Disembargo'context'receiverLoopback Word32
    | Disembargo'context'accept
    | Disembargo'context'provide Word32
    | Disembargo'context'unknown' Word16





instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Disembargo'context m b) b where
    fromStruct struct = do
        tag <-  Codec.Capnp.getWordField struct 0 32 0
        case tag of
            3 -> Disembargo'context'provide <$>  Codec.Capnp.getWordField struct 0 0 0
            2 -> pure Disembargo'context'accept
            1 -> Disembargo'context'receiverLoopback <$>  Codec.Capnp.getWordField struct 0 0 0
            0 -> Disembargo'context'senderLoopback <$>  Codec.Capnp.getWordField struct 0 0 0
            _ -> pure $ Disembargo'context'unknown' tag

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Disembargo'context m b) b where
    fromPtr = Codec.Capnp.structPtr
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Disembargo'context m b)) b where
    fromPtr = Codec.Capnp.structListPtr

newtype Exception (m :: * -> *) b = Exception (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Exception m b) b where
    fromStruct = pure . Exception
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Exception m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Exception m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_Exception'reason :: Data.Capnp.Untyped.ReadCtx m b => Exception m b -> m (Data.Capnp.BuiltinTypes.Text b)
get_Exception'reason (Exception struct) =
    Data.Capnp.Untyped.getPtr 0 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_Exception'reason :: Data.Capnp.Untyped.ReadCtx m b => Exception m b -> m Bool
has_Exception'reason(Exception struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 0 struct
get_Exception'obsoleteIsCallersFault :: Data.Capnp.Untyped.ReadCtx m b => Exception m b -> m Bool
get_Exception'obsoleteIsCallersFault (Exception struct) = Codec.Capnp.getWordField struct 0 0 0

has_Exception'obsoleteIsCallersFault :: Data.Capnp.Untyped.ReadCtx m b => Exception m b -> m Bool
has_Exception'obsoleteIsCallersFault(Exception struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Exception'obsoleteDurability :: Data.Capnp.Untyped.ReadCtx m b => Exception m b -> m Word16
get_Exception'obsoleteDurability (Exception struct) = Codec.Capnp.getWordField struct 0 16 0

has_Exception'obsoleteDurability :: Data.Capnp.Untyped.ReadCtx m b => Exception m b -> m Bool
has_Exception'obsoleteDurability(Exception struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Exception'type_ :: Data.Capnp.Untyped.ReadCtx m b => Exception m b -> m (Exception'Type m b)
get_Exception'type_ (Exception struct) = Codec.Capnp.getWordField struct 0 32 0

has_Exception'type_ :: Data.Capnp.Untyped.ReadCtx m b => Exception m b -> m Bool
has_Exception'type_(Exception struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
newtype PromisedAnswer (m :: * -> *) b = PromisedAnswer (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (PromisedAnswer m b) b where
    fromStruct = pure . PromisedAnswer
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (PromisedAnswer m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (PromisedAnswer m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_PromisedAnswer'questionId :: Data.Capnp.Untyped.ReadCtx m b => PromisedAnswer m b -> m Word32
get_PromisedAnswer'questionId (PromisedAnswer struct) = Codec.Capnp.getWordField struct 0 0 0

has_PromisedAnswer'questionId :: Data.Capnp.Untyped.ReadCtx m b => PromisedAnswer m b -> m Bool
has_PromisedAnswer'questionId(PromisedAnswer struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_PromisedAnswer'transform :: Data.Capnp.Untyped.ReadCtx m b => PromisedAnswer m b -> m (Data.Capnp.Untyped.ListOf m b (PromisedAnswer'Op m b))
get_PromisedAnswer'transform (PromisedAnswer struct) =
    Data.Capnp.Untyped.getPtr 0 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_PromisedAnswer'transform :: Data.Capnp.Untyped.ReadCtx m b => PromisedAnswer m b -> m Bool
has_PromisedAnswer'transform(PromisedAnswer struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 0 struct
data Call'sendResultsTo (m :: * -> *) b
    = Call'sendResultsTo'caller
    | Call'sendResultsTo'yourself
    | Call'sendResultsTo'thirdParty (Maybe (Data.Capnp.Untyped.Ptr m b))
    | Call'sendResultsTo'unknown' Word16




instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Call'sendResultsTo m b) b where
    fromStruct struct = do
        tag <-  Codec.Capnp.getWordField struct 0 48 0
        case tag of
            2 -> Call'sendResultsTo'thirdParty <$>  (Data.Capnp.Untyped.getPtr 2 struct >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))
            1 -> pure Call'sendResultsTo'yourself
            0 -> pure Call'sendResultsTo'caller
            _ -> pure $ Call'sendResultsTo'unknown' tag

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Call'sendResultsTo m b) b where
    fromPtr = Codec.Capnp.structPtr
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Call'sendResultsTo m b)) b where
    fromPtr = Codec.Capnp.structListPtr

newtype Bootstrap (m :: * -> *) b = Bootstrap (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Bootstrap m b) b where
    fromStruct = pure . Bootstrap
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Bootstrap m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Bootstrap m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_Bootstrap'questionId :: Data.Capnp.Untyped.ReadCtx m b => Bootstrap m b -> m Word32
get_Bootstrap'questionId (Bootstrap struct) = Codec.Capnp.getWordField struct 0 0 0

has_Bootstrap'questionId :: Data.Capnp.Untyped.ReadCtx m b => Bootstrap m b -> m Bool
has_Bootstrap'questionId(Bootstrap struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Bootstrap'deprecatedObjectId :: Data.Capnp.Untyped.ReadCtx m b => Bootstrap m b -> m (Maybe (Data.Capnp.Untyped.Ptr m b))
get_Bootstrap'deprecatedObjectId (Bootstrap struct) =
    Data.Capnp.Untyped.getPtr 0 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_Bootstrap'deprecatedObjectId :: Data.Capnp.Untyped.ReadCtx m b => Bootstrap m b -> m Bool
has_Bootstrap'deprecatedObjectId(Bootstrap struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 0 struct
data PromisedAnswer'Op (m :: * -> *) b
    = PromisedAnswer'Op'noop
    | PromisedAnswer'Op'getPointerField Word16
    | PromisedAnswer'Op'unknown' Word16



instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (PromisedAnswer'Op m b) b where
    fromStruct struct = do
        tag <-  Codec.Capnp.getWordField struct 0 0 0
        case tag of
            1 -> PromisedAnswer'Op'getPointerField <$>  Codec.Capnp.getWordField struct 0 16 0
            0 -> pure PromisedAnswer'Op'noop
            _ -> pure $ PromisedAnswer'Op'unknown' tag

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (PromisedAnswer'Op m b) b where
    fromPtr = Codec.Capnp.structPtr
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (PromisedAnswer'Op m b)) b where
    fromPtr = Codec.Capnp.structListPtr

newtype Disembargo (m :: * -> *) b = Disembargo (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Disembargo m b) b where
    fromStruct = pure . Disembargo
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Disembargo m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Disembargo m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_Disembargo'target :: Data.Capnp.Untyped.ReadCtx m b => Disembargo m b -> m (MessageTarget m b)
get_Disembargo'target (Disembargo struct) =
    Data.Capnp.Untyped.getPtr 0 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_Disembargo'target :: Data.Capnp.Untyped.ReadCtx m b => Disembargo m b -> m Bool
has_Disembargo'target(Disembargo struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 0 struct
get_Disembargo'context :: Data.Capnp.Untyped.ReadCtx m b => Disembargo m b -> m (Disembargo'context m b)
get_Disembargo'context (Disembargo struct) = Codec.Capnp.fromStruct struct

has_Disembargo'context :: Data.Capnp.Untyped.ReadCtx m b => Disembargo m b -> m Bool
has_Disembargo'context(Disembargo struct) = pure True
newtype Join (m :: * -> *) b = Join (Data.Capnp.Untyped.Struct m b)

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (Join m b) b where
    fromStruct = pure . Join
instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Join m b) b where
    fromPtr = Codec.Capnp.structPtr

instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (Join m b)) b where
    fromPtr = Codec.Capnp.structListPtr
get_Join'questionId :: Data.Capnp.Untyped.ReadCtx m b => Join m b -> m Word32
get_Join'questionId (Join struct) = Codec.Capnp.getWordField struct 0 0 0

has_Join'questionId :: Data.Capnp.Untyped.ReadCtx m b => Join m b -> m Bool
has_Join'questionId(Join struct) = pure $ 0 < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)
get_Join'target :: Data.Capnp.Untyped.ReadCtx m b => Join m b -> m (MessageTarget m b)
get_Join'target (Join struct) =
    Data.Capnp.Untyped.getPtr 0 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_Join'target :: Data.Capnp.Untyped.ReadCtx m b => Join m b -> m Bool
has_Join'target(Join struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 0 struct
get_Join'keyPart :: Data.Capnp.Untyped.ReadCtx m b => Join m b -> m (Maybe (Data.Capnp.Untyped.Ptr m b))
get_Join'keyPart (Join struct) =
    Data.Capnp.Untyped.getPtr 1 struct
    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)


has_Join'keyPart :: Data.Capnp.Untyped.ReadCtx m b => Join m b -> m Bool
has_Join'keyPart(Join struct) = Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr 1 struct