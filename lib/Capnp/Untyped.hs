{-# LANGUAGE ApplicativeDo              #-}
{-# LANGUAGE ConstraintKinds            #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase                 #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE NamedFieldPuns             #-}
{-# LANGUAGE RankNTypes                 #-}
{-# LANGUAGE RecordWildCards            #-}
{-# LANGUAGE TypeFamilies               #-}
{-|
Module: Capnp.Untyped
Description: Utilities for reading capnproto messages with no schema.

The types and functions in this module know about things like structs and
lists, but are not schema aware.

Each of the data types exported by this module is parametrized over a Message
type (see "Capnp.Message"), used as the underlying storage.
-}
module Capnp.Untyped
    ( Ptr(..), List(..), Struct, ListOf, Cap
    , structByteCount
    , structWordCount
    , structPtrCount
    , structListByteCount
    , structListWordCount
    , structListPtrCount
    , getData, getPtr
    , setData, setPtr
    , copyStruct
    , getClient
    , get, index, length
    , setIndex
    , take
    , rootPtr
    , setRoot
    , rawBytes
    , ReadCtx
    , RWCtx
    , HasMessage(..), MessageDefault(..)
    , allocStruct
    , allocCompositeList
    , allocList0
    , allocList1
    , allocList8
    , allocList16
    , allocList32
    , allocList64
    , allocListPtr
    , appendCap

    , TraverseMsg(..)
    )
  where

import Prelude hiding (length, take)

import Data.Bits
import Data.Word

import Control.Exception.Safe    (impureThrow)
import Control.Monad             (forM_)
import Control.Monad.Catch       (MonadCatch, MonadThrow(throwM))
import Control.Monad.Catch.Pure  (CatchT(runCatchT))
import Control.Monad.Primitive   (PrimMonad (..))
import Control.Monad.Trans.Class (MonadTrans(lift))

import qualified Data.ByteString as BS

import Capnp.Address        (OffsetError (..), WordAddr (..), pointerFrom)
import Capnp.Bits
    ( BitCount (..)
    , ByteCount (..)
    , Word1 (..)
    , WordCount (..)
    , bitsToBytesCeil
    , bytesToWordsCeil
    , replaceBits
    , wordsToBytes
    )
import Capnp.Pointer        (ElementSize (..))
import Capnp.TraversalLimit (MonadLimit(invoice))
import Data.Mutable         (Thaw (..))

import qualified Capnp.Errors  as E
import qualified Capnp.Message as M
import qualified Capnp.Pointer as P

-- | Type (constraint) synonym for the constraints needed for most read
-- operations.
type ReadCtx m msg = (M.Message m msg, MonadThrow m, MonadLimit m)

-- | Synonym for ReadCtx + WriteCtx
type RWCtx m s = (ReadCtx m (M.MutMsg s), M.WriteCtx m s)

-- | A an absolute pointer to a value (of arbitrary type) in a message.
-- Note that there is no variant for far pointers, which don't make sense
-- with absolute addressing.
data Ptr msg
    = PtrCap (Cap msg)
    | PtrList (List msg)
    | PtrStruct (Struct msg)

-- | A list of values (of arbitrary type) in a message.
data List msg
    = List0 (ListOf msg ())
    | List1 (ListOf msg Bool)
    | List8 (ListOf msg Word8)
    | List16 (ListOf msg Word16)
    | List32 (ListOf msg Word32)
    | List64 (ListOf msg Word64)
    | ListPtr (ListOf msg (Maybe (Ptr msg)))
    | ListStruct (ListOf msg (Struct msg))

-- | A "normal" (non-composite) list.
data NormalList msg = NormalList
    { nPtr :: !(M.WordPtr msg)
    , nLen :: !Int
    }

-- | A list of values of type 'a' in a message.
data ListOf msg a where
    ListOfStruct
        :: Struct msg -- First element. data/ptr sizes are the same for
                      -- all elements.
        -> !Int       -- Number of elements
        -> ListOf msg (Struct msg)
    ListOfVoid   :: !(NormalList msg) -> ListOf msg ()
    ListOfBool   :: !(NormalList msg) -> ListOf msg Bool
    ListOfWord8  :: !(NormalList msg) -> ListOf msg Word8
    ListOfWord16 :: !(NormalList msg) -> ListOf msg Word16
    ListOfWord32 :: !(NormalList msg) -> ListOf msg Word32
    ListOfWord64 :: !(NormalList msg) -> ListOf msg Word64
    ListOfPtr    :: !(NormalList msg) -> ListOf msg (Maybe (Ptr msg))

-- | A Capability in a message.
data Cap msg = Cap msg !Word32

-- | A struct value in a message.
data Struct msg
    = Struct
        !(M.WordPtr msg) -- Start of struct
        !Word16 -- Data section size.
        !Word16 -- Pointer section size.

-- | N.B. this should mostly be considered an implementation detail, but
-- it is exposed because it is used by generated code.
--
-- 'TraverseMsg' is similar to 'Traversable' from the prelude, but
-- the intent is that rather than conceptually being a "container",
-- the instance is a value backed by a message, and the point of the
-- type class is to be able to apply transformations to the underlying
-- message.
--
-- We don't just use 'Traversable' for this for two reasons:
--
-- 1. While algebraically it makes sense, it would be very unintuitive to
--    e.g. have the 'Traversable' instance for 'List' not traverse over the
--    *elements* of the list.
-- 2. For the instance for WordPtr, we actually need a stronger constraint than
--    Applicative in order for the implementation to type check. A previous
--    version of the library *did* have @tMsg :: Applicative m => ...@, but
--    performance considerations eventually forced us to open up the hood a
--    bit.
class TraverseMsg f where
    tMsg :: TraverseMsgCtx m msgA msgB => (msgA -> m msgB) -> f msgA -> m (f msgB)

type TraverseMsgCtx m msgA msgB = (MonadThrow m, M.Message m msgA, M.Message m msgB)

instance TraverseMsg M.WordPtr where
    tMsg f M.WordPtr{pMessage, pAddr=pAddr@WordAt{segIndex}} = do
        msg' <- f pMessage
        seg' <- M.getSegment msg' segIndex
        pure M.WordPtr
            { pMessage = msg'
            , pSegment = seg'
            , pAddr
            }

instance TraverseMsg Ptr where
    tMsg f = \case
        PtrCap cap ->
            PtrCap <$> tMsg f cap
        PtrList l ->
            PtrList <$> tMsg f l
        PtrStruct s ->
            PtrStruct <$> tMsg f s

instance TraverseMsg Cap where
    tMsg f (Cap msg n) = Cap <$> f msg <*> pure n

instance TraverseMsg Struct where
    tMsg f (Struct ptr dataSz ptrSz) = Struct
        <$> tMsg f ptr
        <*> pure dataSz
        <*> pure ptrSz

instance TraverseMsg List where
    tMsg f = \case
        List0      l -> List0      . unflip  <$> tMsg f (FlipList  l)
        List1      l -> List1      . unflip  <$> tMsg f (FlipList  l)
        List8      l -> List8      . unflip  <$> tMsg f (FlipList  l)
        List16     l -> List16     . unflip  <$> tMsg f (FlipList  l)
        List32     l -> List32     . unflip  <$> tMsg f (FlipList  l)
        List64     l -> List64     . unflip  <$> tMsg f (FlipList  l)
        ListPtr    l -> ListPtr    . unflipP <$> tMsg f (FlipListP l)
        ListStruct l -> ListStruct . unflipS <$> tMsg f (FlipListS l)

instance TraverseMsg NormalList where
    tMsg f NormalList{..} = do
        ptr <- tMsg f nPtr
        pure NormalList { nPtr = ptr, .. }

-------------------------------------------------------------------------------
-- newtype wrappers for the purpose of implementing 'TraverseMsg'; these adjust
-- the shape of 'ListOf' so that we can define an instance. We need a couple
-- different wrappers depending on the shape of the element type.
-------------------------------------------------------------------------------

-- 'FlipList' wraps a @ListOf msg a@ where 'a' is of kind @*@.
newtype FlipList  a msg = FlipList  { unflip  :: ListOf msg a                 }

-- 'FlipListS' wraps a @ListOf msg (Struct msg)@. We can't use 'FlipList' for
-- our instances, because we need both instances of the 'msg' parameter to stay
-- equal.
newtype FlipListS   msg = FlipListS { unflipS :: ListOf msg (Struct msg)      }

-- 'FlipListP' wraps a @ListOf msg (Maybe (Ptr msg))@. Pointers can't use
-- 'FlipList' for the same reason as structs.
newtype FlipListP   msg = FlipListP { unflipP :: ListOf msg (Maybe (Ptr msg)) }

-------------------------------------------------------------------------------
-- 'TraverseMsg' instances for 'FlipList'
-------------------------------------------------------------------------------

instance TraverseMsg (FlipList ()) where
    tMsg f (FlipList (ListOfVoid   nlist)) = FlipList . ListOfVoid <$> tMsg f nlist

instance TraverseMsg (FlipList Bool) where
    tMsg f (FlipList (ListOfBool   nlist)) = FlipList . ListOfBool   <$> tMsg f nlist

instance TraverseMsg (FlipList Word8) where
    tMsg f (FlipList (ListOfWord8  nlist)) = FlipList . ListOfWord8  <$> tMsg f nlist

instance TraverseMsg (FlipList Word16) where
    tMsg f (FlipList (ListOfWord16 nlist)) = FlipList . ListOfWord16 <$> tMsg f nlist

instance TraverseMsg (FlipList Word32) where
    tMsg f (FlipList (ListOfWord32 nlist)) = FlipList . ListOfWord32 <$> tMsg f nlist

instance TraverseMsg (FlipList Word64) where
    tMsg f (FlipList (ListOfWord64 nlist)) = FlipList . ListOfWord64 <$> tMsg f nlist

-------------------------------------------------------------------------------
-- 'TraverseMsg' instances for struct and pointer lists.
-------------------------------------------------------------------------------

instance TraverseMsg FlipListP where
    tMsg f (FlipListP (ListOfPtr nlist))   = FlipListP . ListOfPtr   <$> tMsg f nlist

instance TraverseMsg FlipListS where
    tMsg f (FlipListS (ListOfStruct tag size)) =
        FlipListS <$> (ListOfStruct <$> tMsg f tag <*> pure size)

-- helpers for applying tMsg to a @ListOf@.
tFlip  :: (TraverseMsg (FlipList a), TraverseMsgCtx m msgA msg)
    => (msgA -> m msg) -> ListOf msgA a -> m (ListOf msg a)
tFlipS :: TraverseMsgCtx m msgA msg => (msgA -> m msg) -> ListOf msgA (Struct msgA) -> m (ListOf msg (Struct msg))
tFlipP :: Applicative m => (msgA -> m msg) -> ListOf msgA (Maybe (Ptr msgA)) -> m (ListOf msg (Maybe (Ptr msg)))
tFlip  f list  = unflip  <$> tMsg f (FlipList  list)
tFlipS f list  = unflipS <$> tMsg f (FlipListS list)
tFlipP f list  = unflipP <$> tMsg f (FlipListP list)

-------------------------------------------------------------------------------
-- Boilerplate 'Thaw' instances.
--
-- These all just call the underlying methods on the message, using 'TraverseMsg'.
-------------------------------------------------------------------------------

instance Thaw a => Thaw (Maybe a) where
    type Mutable s (Maybe a) = Maybe (Mutable s a)

    thaw         = traverse thaw
    freeze       = traverse freeze
    unsafeThaw   = traverse unsafeThaw
    unsafeFreeze = traverse unsafeFreeze

instance Thaw msg => Thaw (Ptr msg) where
    type Mutable s (Ptr msg) = Ptr (Mutable s msg)

    thaw         = tMsg thaw
    freeze       = tMsg freeze
    unsafeThaw   = tMsg unsafeThaw
    unsafeFreeze = tMsg unsafeFreeze

instance Thaw msg => Thaw (List msg) where
    type Mutable s (List msg) = List (Mutable s msg)

    thaw         = tMsg thaw
    freeze       = tMsg freeze
    unsafeThaw   = tMsg unsafeThaw
    unsafeFreeze = tMsg unsafeFreeze

instance Thaw msg => Thaw (NormalList msg) where
    type Mutable s (NormalList msg) = NormalList (Mutable s msg)

    thaw         = tMsg thaw
    freeze       = tMsg freeze
    unsafeThaw   = tMsg unsafeThaw
    unsafeFreeze = tMsg unsafeFreeze

instance Thaw msg => Thaw (ListOf msg ()) where
    type Mutable s (ListOf msg ()) = ListOf (Mutable s msg) ()

    thaw         = tFlip thaw
    freeze       = tFlip freeze
    unsafeThaw   = tFlip unsafeThaw
    unsafeFreeze = tFlip unsafeFreeze

instance Thaw msg => Thaw (ListOf msg Bool) where
    type Mutable s (ListOf msg Bool) = ListOf (Mutable s msg) Bool

    thaw         = tFlip thaw
    freeze       = tFlip freeze
    unsafeThaw   = tFlip unsafeThaw
    unsafeFreeze = tFlip unsafeFreeze

instance Thaw msg => Thaw (ListOf msg Word8) where
    type Mutable s (ListOf msg Word8) = ListOf (Mutable s msg) Word8

    thaw         = tFlip thaw
    freeze       = tFlip freeze
    unsafeThaw   = tFlip unsafeThaw
    unsafeFreeze = tFlip unsafeFreeze

instance Thaw msg => Thaw (ListOf msg Word16) where
    type Mutable s (ListOf msg Word16) = ListOf (Mutable s msg) Word16

    thaw         = tFlip thaw
    freeze       = tFlip freeze
    unsafeThaw   = tFlip unsafeThaw
    unsafeFreeze = tFlip unsafeFreeze

instance Thaw msg => Thaw (ListOf msg Word32) where
    type Mutable s (ListOf msg Word32) = ListOf (Mutable s msg) Word32

    thaw         = tFlip thaw
    freeze       = tFlip freeze
    unsafeThaw   = tFlip unsafeThaw
    unsafeFreeze = tFlip unsafeFreeze

instance Thaw msg => Thaw (ListOf msg Word64) where
    type Mutable s (ListOf msg Word64) = ListOf (Mutable s msg) Word64

    thaw         = tFlip thaw
    freeze       = tFlip freeze
    unsafeThaw   = tFlip unsafeThaw
    unsafeFreeze = tFlip unsafeFreeze

instance Thaw msg => Thaw (ListOf msg (Struct msg)) where
    type Mutable s (ListOf msg (Struct msg)) = ListOf (Mutable s msg) (Struct (Mutable s msg))

    thaw         = tFlipS thaw
    freeze       = tFlipS freeze
    unsafeThaw   = tFlipS unsafeThaw
    unsafeFreeze = tFlipS unsafeFreeze

instance Thaw msg => Thaw (ListOf msg (Maybe (Ptr msg))) where
    type Mutable s (ListOf msg (Maybe (Ptr msg))) =
        ListOf (Mutable s msg) (Maybe (Ptr (Mutable s msg)))

    thaw         = tFlipP thaw
    freeze       = tFlipP freeze
    unsafeThaw   = tFlipP unsafeThaw
    unsafeFreeze = tFlipP unsafeFreeze

instance Thaw (Struct M.ConstMsg) where
    type Mutable s (Struct M.ConstMsg) = Struct (Mutable s M.ConstMsg)

    thaw         = runCatchImpure . tMsg thaw
    freeze       = runCatchImpure . tMsg freeze
    unsafeThaw   = runCatchImpure . tMsg unsafeThaw
    unsafeFreeze = runCatchImpure . tMsg unsafeFreeze

-------------------------------------------------------------------------------
-- Helpers for the above boilerplate Thaw instances
-------------------------------------------------------------------------------

-- trivial wrapaper around CatchT, so we can add a PrimMonad instance.
newtype CatchTWrap m a = CatchTWrap { runCatchTWrap :: CatchT m a }
    deriving(Functor, Applicative, Monad, MonadTrans, MonadThrow, MonadCatch)

instance PrimMonad m => PrimMonad (CatchTWrap m) where
    type PrimState (CatchTWrap m) = PrimState m
    primitive = lift . primitive

-- | @runCatchImpure m@ runs @m@, and if it throws, raises the
-- exception with 'impureThrow'.
runCatchImpure :: Monad m => CatchTWrap m a -> m a
runCatchImpure m = do
    res <- runCatchT $ runCatchTWrap m
    pure $ case res of
        Left e  -> impureThrow e
        Right v -> v

-------------------------------------------------------------------------------

-- | Types @a@ whose storage is owned by a message..
class HasMessage a where
    -- | The type of the messages containing @a@s.
    type InMessage a

    -- | Get the message in which the @a@ is stored.
    message :: a -> InMessage a

-- | Types which have a "default" value, but require a message
-- to construct it.
--
-- The default is usually conceptually zero-size. This is mostly useful
-- for generated code, so that it can use standard decoding techniques
-- on default values.
class HasMessage a => MessageDefault a where
    messageDefault :: ReadCtx m (InMessage a) => InMessage a -> m a

instance HasMessage (M.WordPtr msg) where
    type InMessage (M.WordPtr msg) = msg
    message M.WordPtr{pMessage} = pMessage

instance HasMessage (Ptr msg) where
    type InMessage (Ptr msg) = msg

    message (PtrCap cap)       = message cap
    message (PtrList list)     = message list
    message (PtrStruct struct) = message struct

instance HasMessage (Cap msg) where
    type InMessage (Cap msg) = msg

    message (Cap msg _) = msg

instance HasMessage (Struct msg) where
    type InMessage (Struct msg) = msg

    message (Struct ptr _ _) = message ptr

instance MessageDefault (Struct msg) where
    messageDefault msg = do
        pSegment <- M.getSegment msg 0
        pure $ Struct M.WordPtr{pMessage = msg, pSegment, pAddr = WordAt 0 0} 0 0

instance HasMessage (List msg) where
    type InMessage (List msg) = msg

    message (List0 list)      = message list
    message (List1 list)      = message list
    message (List8 list)      = message list
    message (List16 list)     = message list
    message (List32 list)     = message list
    message (List64 list)     = message list
    message (ListPtr list)    = message list
    message (ListStruct list) = message list

instance HasMessage (ListOf msg a) where
    type InMessage (ListOf msg a) = msg

    message (ListOfStruct tag _) = message tag
    message (ListOfVoid list)    = message list
    message (ListOfBool list)    = message list
    message (ListOfWord8 list)   = message list
    message (ListOfWord16 list)  = message list
    message (ListOfWord32 list)  = message list
    message (ListOfWord64 list)  = message list
    message (ListOfPtr list)     = message list

instance MessageDefault (ListOf msg ()) where
    messageDefault msg = ListOfVoid <$> messageDefault msg
instance MessageDefault (ListOf msg (Struct msg)) where
    messageDefault msg = flip ListOfStruct 0 <$> messageDefault msg
instance MessageDefault (ListOf msg Bool) where
    messageDefault msg = ListOfBool <$> messageDefault msg
instance MessageDefault (ListOf msg Word8) where
    messageDefault msg = ListOfWord8 <$> messageDefault msg
instance MessageDefault (ListOf msg Word16) where
    messageDefault msg = ListOfWord16 <$> messageDefault msg
instance MessageDefault (ListOf msg Word32) where
    messageDefault msg = ListOfWord32 <$> messageDefault msg
instance MessageDefault (ListOf msg Word64) where
    messageDefault msg = ListOfWord64 <$> messageDefault msg
instance MessageDefault (ListOf msg (Maybe (Ptr msg))) where
    messageDefault msg = ListOfPtr <$> messageDefault msg

instance HasMessage (NormalList msg) where
    type InMessage (NormalList msg) = msg

    message = M.pMessage . nPtr

instance MessageDefault (NormalList msg) where
    messageDefault msg = do
        pSegment <- M.getSegment msg 0
        pure NormalList
            { nPtr = M.WordPtr { pMessage = msg, pSegment, pAddr = WordAt 0 0 }
            , nLen = 0
            }

getClient :: ReadCtx m msg => Cap msg -> m M.Client
getClient (Cap msg idx) = M.getCap msg (fromIntegral idx)

-- | @get ptr@ returns the Ptr stored at @ptr@.
-- Deducts 1 from the quota for each word read (which may be multiple in the
-- case of far pointers).
get :: ReadCtx m msg => M.WordPtr msg -> m (Maybe (Ptr msg))
get ptr@M.WordPtr{pMessage, pAddr} = do
    word <- getWord ptr
    case P.parsePtr word of
        Nothing -> return Nothing
        Just p -> case p of
            P.CapPtr cap -> return $ Just $ PtrCap (Cap pMessage cap)
            P.StructPtr off dataSz ptrSz -> return $ Just $ PtrStruct $
                Struct ptr { M.pAddr = resolveOffset pAddr off } dataSz ptrSz
            P.ListPtr off eltSpec -> Just <$>
                getList ptr { M.pAddr = resolveOffset pAddr off } eltSpec
            P.FarPtr twoWords offset segment -> do
                pSegment <- M.getSegment pMessage (fromIntegral segment)
                let addr' = WordAt { wordIndex = fromIntegral offset
                                   , segIndex = fromIntegral segment
                                   }
                if not twoWords
                    then get M.WordPtr{pMessage, pSegment, pAddr = addr' }
                    else do
                        landingPad <- getWord M.WordPtr { pMessage, pSegment, M.pAddr = addr' }
                        case P.parsePtr landingPad of
                            Just (P.FarPtr False off seg) -> do
                                let segIndex = fromIntegral seg
                                pSegment <- M.getSegment pMessage segIndex
                                tagWord <- getWord M.WordPtr
                                    { pMessage
                                    , pSegment
                                    , M.pAddr = addr' { wordIndex = wordIndex addr' + 1 }
                                    }
                                let finalPtr = M.WordPtr
                                        { pMessage
                                        , pSegment
                                        , pAddr = WordAt
                                            { wordIndex = fromIntegral off
                                            , segIndex
                                            }
                                        }
                                case P.parsePtr tagWord of
                                    Just (P.StructPtr 0 dataSz ptrSz) ->
                                        return $ Just $ PtrStruct $
                                            Struct finalPtr dataSz ptrSz
                                    Just (P.ListPtr 0 eltSpec) ->
                                        Just <$> getList finalPtr eltSpec
                                    -- TODO: I'm not sure whether far pointers to caps are
                                    -- legal; it's clear how they would work, but I don't
                                    -- see a use, and the spec is unclear. Should check
                                    -- how the reference implementation does this, copy
                                    -- that, and submit a patch to the spec.
                                    Just (P.CapPtr cap) ->
                                        return $ Just $ PtrCap (Cap pMessage cap)
                                    ptr -> throwM $ E.InvalidDataError $
                                        "The tag word of a far pointer's " ++
                                        "2-word landing pad should be an intra " ++
                                        "segment pointer with offset 0, but " ++
                                        "we read " ++ show ptr
                            ptr -> throwM $ E.InvalidDataError $
                                "The first word of a far pointer's 2-word " ++
                                "landing pad should be another far pointer " ++
                                "(with a one-word landing pad), but we read " ++
                                show ptr

  where
    getWord M.WordPtr{pSegment, pAddr=WordAt{wordIndex}} =
        invoice 1 *> M.read pSegment wordIndex
    resolveOffset addr@WordAt{..} off =
        addr { wordIndex = wordIndex + fromIntegral off + 1 }
    getList ptr@M.WordPtr{pAddr=addr@WordAt{wordIndex}} eltSpec = PtrList <$>
        case eltSpec of
            P.EltNormal sz len -> pure $ case sz of
                Sz0   -> List0  (ListOfVoid    nlist)
                Sz1   -> List1  (ListOfBool    nlist)
                Sz8   -> List8  (ListOfWord8   nlist)
                Sz16  -> List16 (ListOfWord16  nlist)
                Sz32  -> List32 (ListOfWord32  nlist)
                Sz64  -> List64 (ListOfWord64  nlist)
                SzPtr -> ListPtr (ListOfPtr nlist)
              where
                nlist = NormalList ptr (fromIntegral len)
            P.EltComposite _ -> do
                tagWord <- getWord ptr
                case P.parsePtr' tagWord of
                    P.StructPtr numElts dataSz ptrSz ->
                        pure $ ListStruct $ ListOfStruct
                            (Struct ptr { M.pAddr = addr { wordIndex = wordIndex + 1 } }
                                    dataSz
                                    ptrSz)
                            (fromIntegral numElts)
                    tag -> throwM $ E.InvalidDataError $
                        "Composite list tag was not a struct-" ++
                        "formatted word: " ++ show tag

-- | Return the EltSpec needed for a pointer to the given list.
listEltSpec :: List msg -> P.EltSpec
listEltSpec (ListStruct list@(ListOfStruct (Struct _ dataSz ptrSz) _)) =
    P.EltComposite $ fromIntegral (length list) * (fromIntegral dataSz + fromIntegral ptrSz)
listEltSpec (List0 list)   = P.EltNormal Sz0 $ fromIntegral (length list)
listEltSpec (List1 list)   = P.EltNormal Sz1 $ fromIntegral (length list)
listEltSpec (List8 list)   = P.EltNormal Sz8 $ fromIntegral (length list)
listEltSpec (List16 list)  = P.EltNormal Sz16 $ fromIntegral (length list)
listEltSpec (List32 list)  = P.EltNormal Sz32 $ fromIntegral (length list)
listEltSpec (List64 list)  = P.EltNormal Sz64 $ fromIntegral (length list)
listEltSpec (ListPtr list) = P.EltNormal SzPtr $ fromIntegral (length list)

-- | Return the starting address of the list.
listAddr :: List msg -> WordAddr
listAddr (ListStruct (ListOfStruct (Struct M.WordPtr{pAddr} _ _) _)) =
    -- pAddr is the address of the first element of the list, but
    -- composite lists start with a tag word:
    pAddr { wordIndex = wordIndex pAddr - 1 }
listAddr (List0 (ListOfVoid NormalList{nPtr=M.WordPtr{pAddr}})) = pAddr
listAddr (List1 (ListOfBool NormalList{nPtr=M.WordPtr{pAddr}})) = pAddr
listAddr (List8 (ListOfWord8 NormalList{nPtr=M.WordPtr{pAddr}})) = pAddr
listAddr (List16 (ListOfWord16 NormalList{nPtr=M.WordPtr{pAddr}})) = pAddr
listAddr (List32 (ListOfWord32 NormalList{nPtr=M.WordPtr{pAddr}})) = pAddr
listAddr (List64 (ListOfWord64 NormalList{nPtr=M.WordPtr{pAddr}})) = pAddr
listAddr (ListPtr (ListOfPtr NormalList{nPtr=M.WordPtr{pAddr}})) = pAddr

-- | Return the address of the pointer's target. It is illegal to call this on
-- a pointer which targets a capability.
ptrAddr :: Ptr msg -> WordAddr
ptrAddr (PtrCap _) = error "ptrAddr called on a capability pointer."
ptrAddr (PtrStruct (Struct M.WordPtr{pAddr}_ _)) = pAddr
ptrAddr (PtrList list) = listAddr list

-- | @'setIndex value i list@ Set the @i@th element of @list@ to @value@.
setIndex :: RWCtx m s => a -> Int -> ListOf (M.MutMsg s) a -> m ()
setIndex _ i list | length list <= i =
    throwM E.BoundsError { E.index = i, E.maxIndex = length list }
setIndex value i list = case list of
    ListOfVoid _       -> pure ()
    ListOfBool nlist   -> setNIndex nlist 64 (Word1 value)
    ListOfWord8 nlist  -> setNIndex nlist 8 value
    ListOfWord16 nlist -> setNIndex nlist 4 value
    ListOfWord32 nlist -> setNIndex nlist 2 value
    ListOfWord64 nlist -> setNIndex nlist 1 value
    ListOfPtr nlist -> case value of
        Just p | message p /= message list -> do
            newPtr <- copyPtr (message list) value
            setIndex newPtr i list
        Nothing                -> setNIndex nlist 1 (P.serializePtr Nothing)
        Just (PtrCap (Cap _ cap))    -> setNIndex nlist 1 (P.serializePtr (Just (P.CapPtr cap)))
        Just p@(PtrList ptrList)     ->
            setPtrIndex nlist p $ P.ListPtr 0 (listEltSpec ptrList)
        Just p@(PtrStruct (Struct _ dataSz ptrSz)) ->
            setPtrIndex nlist p $ P.StructPtr 0 dataSz ptrSz
    list@(ListOfStruct _ _) -> do
        dest <- index i list
        copyStruct dest value
  where
    setNIndex :: (ReadCtx m (M.MutMsg s), M.WriteCtx m s, Bounded a, Integral a) => NormalList (M.MutMsg s) -> Int -> a -> m ()
    setNIndex NormalList{nPtr=M.WordPtr{pSegment, pAddr=WordAt{wordIndex}}} eltsPerWord value = do
        let eltWordIndex = wordIndex + WordCount (i `div` eltsPerWord)
        word <- M.read pSegment wordIndex
        let shift = (i `mod` eltsPerWord) * (64 `div` eltsPerWord)
        M.write pSegment wordIndex $ replaceBits value word shift
    setPtrIndex :: (ReadCtx m (M.MutMsg s), M.WriteCtx m s) => NormalList (M.MutMsg s) -> Ptr (M.MutMsg s) -> P.Ptr -> m ()
    setPtrIndex NormalList{nPtr=nPtr@M.WordPtr{pAddr=addr@WordAt{wordIndex}}, nLen} absPtr relPtr =
        let srcPtr = nPtr { M.pAddr = addr { wordIndex = wordIndex + WordCount i } }
        in setPointerTo srcPtr (ptrAddr absPtr) relPtr

-- | @'setPointerTo' msg srcLoc dstAddr relPtr@ sets the word at @srcLoc@ in @msg@ to a
-- pointer like @relPtr@, but pointing to @dstAddr@. @relPtr@ should not be a far pointer.
-- If the two addresses are in different segments, a landing pad will be allocated and
-- @dstAddr@ will contain a far pointer.
setPointerTo :: M.WriteCtx m s => M.WordPtr (M.MutMsg s) -> WordAddr -> P.Ptr -> m ()
setPointerTo
        srcPtr@M.WordPtr
            { pMessage = msg
            , pSegment=srcSegment, pAddr=srcAddr@WordAt{wordIndex=srcWordIndex}
            }
        dstAddr
        relPtr
    =
    case pointerFrom srcAddr dstAddr relPtr of
        Right absPtr ->
            M.write srcSegment srcWordIndex $ P.serializePtr $ Just absPtr
        Left OutOfRange ->
            error "BUG: segment is too large to set the pointer."
        Left DifferentSegments -> do
            -- We need a far pointer; allocate a landing pad in the target segment,
            -- set it to point to the final destination, an then set the source pointer
            -- pointer to point to the landing pad.
            let WordAt{segIndex} = dstAddr
            M.WordPtr{pSegment=landingPadSegment, pAddr=landingPadAddr}
                <- M.allocInSeg msg segIndex 1
            case pointerFrom landingPadAddr dstAddr relPtr of
                Right landingPad -> do
                    let WordAt{segIndex,wordIndex} = landingPadAddr
                    M.write landingPadSegment wordIndex (P.serializePtr $ Just landingPad)
                    M.write srcSegment srcWordIndex $
                        P.serializePtr $ Just $ P.FarPtr False (fromIntegral wordIndex) (fromIntegral segIndex)
                Left DifferentSegments ->
                    error "BUG: allocated a landing pad in the wrong segment!"
                Left OutOfRange ->
                    error "BUG: segment is too large to set the pointer."

copyCap :: RWCtx m s => M.MutMsg s -> Cap (M.MutMsg s) -> m (Cap (M.MutMsg s))
copyCap dest cap = getClient cap >>= appendCap dest

copyPtr :: RWCtx m s => M.MutMsg s -> Maybe (Ptr (M.MutMsg s)) -> m (Maybe (Ptr (M.MutMsg s)))
copyPtr _ Nothing                = pure Nothing
copyPtr dest (Just (PtrCap cap))    = Just . PtrCap <$> copyCap dest cap
copyPtr dest (Just (PtrList src))   = Just . PtrList <$> copyList dest src
copyPtr dest (Just (PtrStruct src)) = Just . PtrStruct <$> do
    destStruct <- allocStruct
            dest
            (fromIntegral $ structWordCount src)
            (fromIntegral $ structPtrCount src)
    copyStruct destStruct src
    pure destStruct

copyList :: RWCtx m s => M.MutMsg s -> List (M.MutMsg s) -> m (List (M.MutMsg s))
copyList dest src = case src of
    List0 src      -> List0 <$> allocList0 dest (length src)
    List1 src      -> List1 <$> copyNewListOf dest src allocList1
    List8 src      -> List8 <$> copyNewListOf dest src allocList8
    List16 src     -> List16 <$> copyNewListOf dest src allocList16
    List32 src     -> List32 <$> copyNewListOf dest src allocList32
    List64 src     -> List64 <$> copyNewListOf dest src allocList64
    ListPtr src    -> ListPtr <$> copyNewListOf dest src allocListPtr
    ListStruct src -> ListStruct <$> do
        destList <- allocCompositeList
            dest
            (fromIntegral $ structListWordCount src)
            (structListPtrCount  src)
            (length src)
        copyListOf destList src
        pure destList

copyNewListOf
    :: RWCtx m s
    => M.MutMsg s
    -> ListOf (M.MutMsg s) a
    -> (M.MutMsg s -> Int -> m (ListOf (M.MutMsg s) a))
    -> m (ListOf (M.MutMsg s) a)
copyNewListOf destMsg src new = do
    dest <- new destMsg (length src)
    copyListOf dest src
    pure dest


copyListOf :: RWCtx m s => ListOf (M.MutMsg s) a -> ListOf (M.MutMsg s) a -> m ()
copyListOf dest src =
    forM_ [0..length src - 1] $ \i -> do
        value <- index i src
        setIndex value i dest

-- | @'copyStruct' dest src@ copies the source struct to the destination struct.
copyStruct :: RWCtx m s => Struct (M.MutMsg s) -> Struct (M.MutMsg s) -> m ()
copyStruct dest src = do
    -- We copy both the data and pointer sections from src to dest,
    -- padding the tail of the destination section with zeros/null
    -- pointers as necessary. If the destination section is
    -- smaller than the source section, this will raise a BoundsError.
    --
    -- TODO: possible enhancement: allow the destination section to be
    -- smaller than the source section if and only if the tail of the
    -- source section is all zeros (default values).
    copySection (dataSection dest) (dataSection src) 0
    copySection (ptrSection  dest) (ptrSection  src) Nothing
  where
    copySection dest src pad = do
        -- Copy the source section to the destination section:
        copyListOf dest src
        -- Pad the remainder with zeros/default values:
        forM_ [length src..length dest - 1] $ \i ->
            setIndex pad i dest


-- | @index i list@ returns the ith element in @list@. Deducts 1 from the quota
index :: ReadCtx m msg => Int -> ListOf msg a -> m a
index i list = invoice 1 >> index' list
  where
    index' :: ReadCtx m msg => ListOf msg a -> m a
    index' (ListOfVoid nlist)
        | i < nLen nlist = pure ()
        | otherwise = throwM E.BoundsError { E.index = i, E.maxIndex = nLen nlist - 1 }
    index' (ListOfStruct (Struct ptr@M.WordPtr{pAddr=addr@WordAt{..}} dataSz ptrSz) len)
        | i < len = do
            let offset = WordCount $ i * (fromIntegral dataSz + fromIntegral ptrSz)
            let addr' = addr { wordIndex = wordIndex + offset }
            return $ Struct ptr { M.pAddr = addr' } dataSz ptrSz
        | otherwise = throwM E.BoundsError { E.index = i, E.maxIndex = len - 1}
    index' (ListOfBool   nlist) = do
        Word1 val <- indexNList nlist 64
        pure val
    index' (ListOfWord8  nlist) = indexNList nlist 8
    index' (ListOfWord16 nlist) = indexNList nlist 4
    index' (ListOfWord32 nlist) = indexNList nlist 2
    index' (ListOfWord64 (NormalList M.WordPtr{pSegment, pAddr=WordAt{wordIndex}} len))
        | i < len = M.read pSegment $ wordIndex + WordCount i
        | otherwise = throwM E.BoundsError { E.index = i, E.maxIndex = len - 1}
    index' (ListOfPtr (NormalList ptr@M.WordPtr{pAddr=addr@WordAt{..}} len))
        | i < len = get ptr { M.pAddr = addr { wordIndex = wordIndex + WordCount i } }
        | otherwise = throwM E.BoundsError { E.index = i, E.maxIndex = len - 1}
    indexNList :: (ReadCtx m msg, Integral a) => NormalList msg -> Int -> m a
    indexNList (NormalList M.WordPtr{pSegment, pAddr=addr@WordAt{..}} len) eltsPerWord
        | i < len = do
            let wordIndex' = wordIndex + WordCount (i `div` eltsPerWord)
            word <- M.read pSegment wordIndex'
            let shift = (i `mod` eltsPerWord) * (64 `div` eltsPerWord)
            pure $ fromIntegral $ word `shiftR` shift
        | otherwise = throwM E.BoundsError { E.index = i, E.maxIndex = len - 1 }

-- | Returns the length of a list
length :: ListOf msg a -> Int
length (ListOfStruct _ len) = len
length (ListOfVoid   nlist) = nLen nlist
length (ListOfBool   nlist) = nLen nlist
length (ListOfWord8  nlist) = nLen nlist
length (ListOfWord16 nlist) = nLen nlist
length (ListOfWord32 nlist) = nLen nlist
length (ListOfWord64 nlist) = nLen nlist
length (ListOfPtr    nlist) = nLen nlist

-- | Return a prefix of the list, of the given length.
take :: MonadThrow m => Int -> ListOf msg a -> m (ListOf msg a)
take count list
    | length list < count =
        throwM E.BoundsError { E.index = count, E.maxIndex = length list - 1 }
    | otherwise = pure $ go list
  where
    go (ListOfStruct tag _) = ListOfStruct tag count
    go (ListOfVoid nlist)   = ListOfVoid $ nTake nlist
    go (ListOfBool nlist)   = ListOfBool $ nTake nlist
    go (ListOfWord8 nlist)  = ListOfWord8 $ nTake nlist
    go (ListOfWord16 nlist) = ListOfWord16 $ nTake nlist
    go (ListOfWord32 nlist) = ListOfWord32 $ nTake nlist
    go (ListOfWord64 nlist) = ListOfWord64 $ nTake nlist
    go (ListOfPtr nlist)    = ListOfPtr $ nTake nlist

    nTake :: NormalList msg -> NormalList msg
    nTake NormalList{..} = NormalList { nLen = count, .. }

-- | The data section of a struct, as a list of Word64
dataSection :: Struct msg -> ListOf msg Word64
dataSection (Struct ptr dataSz _) =
    ListOfWord64 $ NormalList ptr (fromIntegral dataSz)

-- | The pointer section of a struct, as a list of Ptr
ptrSection :: Struct msg -> ListOf msg (Maybe (Ptr msg))
ptrSection (Struct ptr@M.WordPtr{pAddr=addr@WordAt{wordIndex}} dataSz ptrSz) =
    ListOfPtr $ NormalList
        { nPtr = ptr { M.pAddr = addr { wordIndex = wordIndex + fromIntegral dataSz } }
        , nLen = fromIntegral ptrSz
        }

-- | Get the size (in words) of a struct's data section.
structWordCount :: Struct msg -> WordCount
structWordCount (Struct _ptr dataSz _ptrSz) = fromIntegral dataSz

-- | Get the size (in bytes) of a struct's data section.
structByteCount :: Struct msg -> ByteCount
structByteCount = wordsToBytes . structWordCount

-- | Get the size of a struct's pointer section.
structPtrCount  :: Struct msg -> Word16
structPtrCount (Struct _ptr _dataSz ptrSz) = ptrSz

-- | Get the size (in words) of the data sections in a struct list.
structListWordCount :: ListOf msg (Struct msg) -> WordCount
structListWordCount (ListOfStruct s _) = structWordCount s

-- | Get the size (in words) of the data sections in a struct list.
structListByteCount :: ListOf msg (Struct msg) -> ByteCount
structListByteCount (ListOfStruct s _) = structByteCount s

-- | Get the size of the pointer sections in a struct list.
structListPtrCount  :: ListOf msg (Struct msg) -> Word16
structListPtrCount  (ListOfStruct s _) = structPtrCount s

-- | @'getData' i struct@ gets the @i@th word from the struct's data section,
-- returning 0 if it is absent.
getData :: ReadCtx m msg => Int -> Struct msg -> m Word64
getData i struct
    | fromIntegral (structWordCount struct) <= i = 0 <$ invoice 1
    | otherwise = index i (dataSection struct)

-- | @'getPtr' i struct@ gets the @i@th word from the struct's pointer section,
-- returning Nothing if it is absent.
getPtr :: ReadCtx m msg => Int -> Struct msg -> m (Maybe (Ptr msg))
getPtr i struct
    | fromIntegral (structPtrCount struct) <= i = Nothing <$ invoice 1
    | otherwise = index i (ptrSection struct)

-- | @'setData' value i struct@ sets the @i@th word in the struct's data section
-- to @value@.
setData :: (ReadCtx m (M.MutMsg s), M.WriteCtx m s)
    => Word64 -> Int -> Struct (M.MutMsg s) -> m ()
setData value i = setIndex value i . dataSection

-- | @'setData' value i struct@ sets the @i@th pointer in the struct's pointer
-- section to @value@.
setPtr :: (ReadCtx m (M.MutMsg s), M.WriteCtx m s) => Maybe (Ptr (M.MutMsg s)) -> Int -> Struct (M.MutMsg s) -> m ()
setPtr value i = setIndex value i . ptrSection

-- | 'rawBytes' returns the raw bytes corresponding to the list.
rawBytes :: ReadCtx m msg => ListOf msg Word8 -> m BS.ByteString
rawBytes (ListOfWord8 (NormalList M.WordPtr{pSegment, pAddr=WordAt{wordIndex}} len)) = do
    invoice $ fromIntegral $ bytesToWordsCeil (ByteCount len)
    bytes <- M.toByteString pSegment
    let ByteCount byteOffset = wordsToBytes wordIndex
    pure $ BS.take len $ BS.drop byteOffset bytes


-- | Returns the root pointer of a message.
rootPtr :: ReadCtx m msg => msg -> m (Struct msg)
rootPtr msg = do
    seg <- M.getSegment msg 0
    root <- get M.WordPtr
        { pMessage = msg
        , pSegment = seg
        , pAddr = WordAt 0 0
        }
    case root of
        Just (PtrStruct struct) -> pure struct
        Nothing -> messageDefault msg
        _ -> throwM $ E.SchemaViolationError
                "Unexpected root type; expected struct."


-- | Make the given struct the root object of its message.
setRoot :: M.WriteCtx m s => Struct (M.MutMsg s) -> m ()
setRoot (Struct M.WordPtr{pMessage, pAddr=addr} dataSz ptrSz) = do
    pSegment <- M.getSegment pMessage 0
    let rootPtr = M.WordPtr{pMessage, pSegment, pAddr = WordAt 0 0}
    setPointerTo rootPtr addr (P.StructPtr 0 dataSz ptrSz)

-- | Allocate a struct in the message.
allocStruct :: M.WriteCtx m s => M.MutMsg s -> Word16 -> Word16 -> m (Struct (M.MutMsg s))
allocStruct msg dataSz ptrSz = do
    let totalSz = fromIntegral dataSz + fromIntegral ptrSz
    ptr <- M.alloc msg totalSz
    pure $ Struct ptr dataSz ptrSz

-- | Allocate a composite list.
allocCompositeList
    :: M.WriteCtx m s
    => M.MutMsg s -- ^ The message to allocate in.
    -> Word16     -- ^ The size of the data section
    -> Word16     -- ^ The size of the pointer section
    -> Int        -- ^ The length of the list in elements.
    -> m (ListOf (M.MutMsg s) (Struct (M.MutMsg s)))
allocCompositeList msg dataSz ptrSz len = do
    let eltSize = fromIntegral dataSz + fromIntegral ptrSz
    ptr@M.WordPtr{pSegment, pAddr=addr@WordAt{wordIndex}}
        <- M.alloc msg (WordCount $ len * eltSize + 1) -- + 1 for the tag word.
    M.write pSegment wordIndex $ P.serializePtr' $ P.StructPtr (fromIntegral len) dataSz ptrSz
    let firstStruct = Struct
            ptr { M.pAddr = addr { wordIndex = wordIndex + 1 } }
            dataSz
            ptrSz
    pure $ ListOfStruct firstStruct len

-- | Allocate a list of capnproto @Void@ values.
allocList0   :: M.WriteCtx m s => M.MutMsg s -> Int -> m (ListOf (M.MutMsg s) ())

-- | Allocate a list of booleans
allocList1   :: M.WriteCtx m s => M.MutMsg s -> Int -> m (ListOf (M.MutMsg s) Bool)

-- | Allocate a list of 8-bit values.
allocList8   :: M.WriteCtx m s => M.MutMsg s -> Int -> m (ListOf (M.MutMsg s) Word8)

-- | Allocate a list of 16-bit values.
allocList16  :: M.WriteCtx m s => M.MutMsg s -> Int -> m (ListOf (M.MutMsg s) Word16)

-- | Allocate a list of 32-bit values.
allocList32  :: M.WriteCtx m s => M.MutMsg s -> Int -> m (ListOf (M.MutMsg s) Word32)

-- | Allocate a list of 64-bit words.
allocList64  :: M.WriteCtx m s => M.MutMsg s -> Int -> m (ListOf (M.MutMsg s) Word64)

-- | Allocate a list of pointers.
allocListPtr :: M.WriteCtx m s => M.MutMsg s -> Int -> m (ListOf (M.MutMsg s) (Maybe (Ptr (M.MutMsg s))))

allocList0   msg len = ListOfVoid   <$> allocNormalList 0  msg len
allocList1   msg len = ListOfBool   <$> allocNormalList 1  msg len
allocList8   msg len = ListOfWord8  <$> allocNormalList 8  msg len
allocList16  msg len = ListOfWord16 <$> allocNormalList 16 msg len
allocList32  msg len = ListOfWord32 <$> allocNormalList 32 msg len
allocList64  msg len = ListOfWord64 <$> allocNormalList 64 msg len
allocListPtr msg len = ListOfPtr    <$> allocNormalList 64 msg len

-- | Allocate a NormalList
allocNormalList
    :: M.WriteCtx m s
    => Int        -- ^ The number of elements per 64-bit word
    -> M.MutMsg s -- ^ The message to allocate in
    -> Int        -- ^ The number of bits per element
    -> m (NormalList (M.MutMsg s))
allocNormalList bitsPerElt msg len = do
    -- round 'len' up to the nearest word boundary.
    let totalBits = BitCount (len * bitsPerElt)
        totalWords = bytesToWordsCeil $ bitsToBytesCeil totalBits
    ptr <- M.alloc msg totalWords
    pure NormalList { nPtr = ptr, nLen = len }

appendCap :: M.WriteCtx m s => M.MutMsg s -> M.Client -> m (Cap (M.MutMsg s))
appendCap msg client = do
    i <- M.appendCap msg client
    pure $ Cap msg (fromIntegral i)
