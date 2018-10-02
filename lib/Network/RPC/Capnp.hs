{-# LANGUAGE DuplicateRecordFields      #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase                 #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE NamedFieldPuns             #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE RankNTypes                 #-}
{-# LANGUAGE RecordWildCards            #-}
{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE TypeFamilies               #-}
module Network.RPC.Capnp
    ( RpcT
    , Client
    , Server(..)
    , VatConfig(..)
    , Transport(..)
    , handleTransport
    , runRpcT
    , bootstrap
    , call

    , Rpc.Exception(..)
    , Rpc.Exception'Type(..)

    , Promise
    , Fulfiller
    , newPromise
    , fulfill
    , isResolved
    , wait
    , waitIO

    , export

    , nullClient
    ) where

import Control.Concurrent.STM
import Data.Word

import Control.Concurrent.Async        (concurrently_)
import Control.Exception
    (Exception, SomeException, fromException, throwIO, try)
import Control.Monad                   (forever)
import Control.Monad.Catch             (MonadThrow(..))
import Control.Monad.IO.Class          (MonadIO, liftIO)
import Control.Monad.Primitive         (PrimMonad(..))
import Control.Monad.Reader            (ReaderT, ask, runReaderT)
import Control.Monad.Trans.Class       (MonadTrans(lift))
import Data.Default                    (Default(..))
import Data.Maybe                      (isJust)
import System.IO                       (Handle)
import Text.ParserCombinators.ReadPrec (pfail)
import Text.Read                       (Lexeme(Ident), lexP, readPrec)

import qualified Data.Map.Strict as M
import qualified Data.Text       as T
import qualified Data.Vector     as V

import Capnp.Capnp.Rpc.Pure    hiding (Exception)
import Data.Capnp.Untyped.Pure (PtrType(PtrStruct), Struct)

import Data.Capnp (def, hGetValue, hPutValue)

import qualified Capnp.Capnp.Rpc.Pure as Rpc

instance Exception Rpc.Exception

-- These aliases are actually defined in the schema, but the schema compiler
-- doesn't expose them to the code generator plugin, so we re-define them
-- ourselves.
type QuestionId = Word32
type AnswerId = Word32
type ExportId = Word32
type ImportId = Word32

data Transport m = Transport
    { sendMsg :: Message -> m ()
    , recvMsg :: m Message
    }

-- | @'handleTransport' limit handle@ creates a new transport which reads
-- and writes messages from/to @handle@. It uses @limit@ as the traaversal
-- limit when reading messages and decoding.
handleTransport :: MonadIO m => Int -> Handle -> Transport m
handleTransport limit handle = Transport
    { sendMsg = liftIO . hPutValue handle
    , recvMsg = liftIO $ hGetValue handle limit
    }

-- | Get a new exportId/questionId. The argument gets the pool to allocate from.
newId :: MonadIO m => (Vat -> TVar [Word32]) -> RpcT m Word32
newId pool = do
    vat <- RpcT ask
    liftIO $ atomically $ do
        oldIds <- readTVar (pool vat)
        case oldIds of
            [] ->
                retry
            (id:ids) -> do
                writeTVar (pool vat) ids
                pure id

-- | A "null" client, which throws unimplemented in response to all method
-- calls.
nullClient :: Client
nullClient = NullClient

newExportId :: MonadIO m => RpcT m ExportId
newExportId = newId exportIdPool

newQuestionId :: MonadIO m => RpcT m QuestionId
newQuestionId = newId questionIdPool

newtype RpcT m a = RpcT (ReaderT Vat m a)
    deriving(Functor, Applicative, Monad)

instance MonadTrans RpcT where
    lift = RpcT . lift

instance MonadIO m => MonadIO (RpcT m) where
    liftIO = lift . liftIO

instance MonadThrow m => MonadThrow (RpcT m) where
    throwM = lift . throwM

instance PrimMonad m => PrimMonad (RpcT m) where
    type PrimState (RpcT m) = PrimState m
    primitive = lift . primitive

-- | A client for a capnproto capability.
--
-- Note that client's 'Show' instance does not have a way of retaininig the
-- connection, so doing @'read' . 'show'@ will reseult in a disconnected
-- capability (except in the case of 'nullClient', which is the only capability
-- that can be represented statically)..
data Client
    = RemoteClient
        { target   :: MessageTarget
        , localVat :: Vat
        }
    | LocalClient
        { exportId    :: ExportId
        , localServer :: Server
        , localVat    :: Vat
        }
    | NullClient
    | DisconnectedClient

data Server = Server
    { handleCall :: forall m. MonadIO m => Word64 -> Word16 -> Payload -> RpcT m (Promise Struct)
    , handleStop :: forall m. MonadIO m => RpcT m ()
    }

instance Eq Client where
    RemoteClient{target=ta, localVat=va} == RemoteClient{target=tb, localVat=vb} =
        (ta, va) == (tb, vb)
    LocalClient{exportId=ea, localVat=va} == LocalClient{exportId=eb, localVat=vb} =
        (ea, va) == (eb, vb)
    NullClient == NullClient = True
    DisconnectedClient == DisconnectedClient = True
    _ == _ = False

instance Read Client where
    readPrec = lexP >>= \case
        Ident "nullClient" ->
            pure nullClient
        Ident "DisconnectedClient" ->
            -- TODO: figure out something else to put here.
            pure DisconnectedClient
        _ ->
            pfail

instance Show Client where
    show NullClient = "nullClient"
    -- TODO: we should put something here that makes sense given the exposed API:
    show _          = "DisconnectedClient"

-- | Export a local interface server, so it may be offered on the network.
--
-- TODO: I(zenhack) really don't like the fact that we're using a higher-rank
-- type here. We probably will eventually want 'Client' to be parametrized
-- over @m@ or something at some point, so we can specialize clients for a
-- particular @m@.
export :: MonadIO m => Server -> RpcT m Client
export localServer = do
    exportId <- newExportId
    localVat <- RpcT ask
    pure LocalClient{exportId, localServer, localVat}

bootstrap :: MonadIO m => RpcT m Client
bootstrap = do
    questionId <- newQuestionId
    vat <- RpcT ask
    let msg = Message'bootstrap def { questionId }
    liftIO $ atomically $ sendQuestion vat (BootstrapQuestion questionId)
    pure RemoteClient
        { target = MessageTarget'promisedAnswer def { questionId }
        , localVat = vat
        }

sendQuestion :: Vat -> Question -> STM ()
sendQuestion Vat{sendQ,questions} question = do
    writeTBQueue sendQ $ getQuestionMessage question
    modifyTVar questions $ M.insert (getQuestionId question) question

call :: MonadIO m => Word64 -> Word16 -> Payload -> Client -> RpcT m (Promise Struct)
call interfaceId methodId params RemoteClient{ target, localVat } = do
    questionId <- newQuestionId
    let callMsg = Call
            { sendResultsTo = Call'sendResultsTo'caller
            , allowThirdPartyTailCall = False
            , ..
            }
    (promise, fulfiller) <- liftIO $ atomically newPromise
    liftIO $ atomically $ sendQuestion localVat $ CallQuestion
        { callMsg
        , sendReturn = fulfiller
        }
    pure promise
call interfaceId methodId params LocalClient{localServer=Server{handleCall}} =
    handleCall interfaceId methodId params
call _ _ _ NullClient = alwaysThrow def
    { reason = "Client is null"
    , type_ = Exception'Type'unimplemented
    }
call _ _ _ DisconnectedClient = alwaysThrow def
    { reason = "Client is disconnected"
    , type_ = Exception'Type'disconnected
    }

alwaysThrow :: MonadIO m => Rpc.Exception -> RpcT m (Promise Struct)
alwaysThrow exn = do
    (promise, fulfiller) <- liftIO $ atomically newPromise
    liftIO $ atomically $ breakPromise fulfiller exn
    pure promise

newtype Fulfiller a = Fulfiller
    { var :: TVar (Maybe (Either Rpc.Exception a))
    }

fulfill :: Fulfiller a -> a -> STM ()
fulfill Fulfiller{var} val = modifyTVar' var $ \case
    Nothing ->
        Just (Right val)
    Just _ ->
        -- TODO: report this in a more controlled way.
        error "BUG: tried to fullfill a promise twice!"

breakPromise :: Fulfiller a -> Rpc.Exception -> STM ()
breakPromise Fulfiller{var} exn = modifyTVar' var $ \case
    Nothing ->
        Just (Left exn)
    Just _ ->
        error "BUG: tried to break an already resolved promise!"

wait :: Promise a -> STM a
wait Promise{var} = do
    val <- readTVar var
    case val of
        Nothing ->
            retry
        Just (Right result) ->
            pure result
        Just (Left exn) ->
            throwSTM exn

waitIO :: MonadIO m => Promise a -> m a
waitIO = liftIO . atomically . wait

isResolved :: Promise a -> STM Bool
isResolved Promise{var} = isJust <$> readTVar var

newPromise :: STM (Promise a, Fulfiller a)
newPromise = do
    var <- newTVar Nothing
    pure (Promise{var}, Fulfiller{var})

newtype Promise a = Promise
    { var :: TVar (Maybe (Either Rpc.Exception a))
    }

data Question
    = CallQuestion
        { callMsg    :: Call
        , sendReturn :: Fulfiller Struct
        }
    | BootstrapQuestion !QuestionId

newtype Answer
    = ServerAnswer Server

newtype Export
    = ExportServer Server

getQuestionMessage :: Question -> Message
getQuestionMessage CallQuestion{callMsg} = Message'call callMsg
getQuestionMessage (BootstrapQuestion questionId) =
    Message'bootstrap def { questionId }

getQuestionId :: Question -> QuestionId
getQuestionId CallQuestion{callMsg=Call{questionId}} = questionId
getQuestionId (BootstrapQuestion questionId)         = questionId

data Vat = Vat
    { questions       :: TVar (M.Map QuestionId Question)
    , answers         :: TVar (M.Map AnswerId Answer)
    , imports         :: TVar (M.Map ImportId CapDescriptor)
    , exports         :: TVar (M.Map ExportId Server)

    , questionIdPool  :: TVar [Word32]
    , exportIdPool    :: TVar [Word32]

    , bootstrapServer :: Maybe Server

    , sendQ           :: TBQueue Message
    , recvQ           :: TBQueue Message
    }

instance Eq Vat where
    -- it is sufficient to compare any of the TVars, since we create the whole
    -- vat as a unit:
    Vat{questions=qa} == Vat{questions=qb} = qa == qb

data VatConfig = VatConfig
    { maxQuestions    :: !Word32
    , maxExports      :: !Word32
    , bootstrapServer :: Maybe Server
    }

instance Default VatConfig where
    def = VatConfig
        { maxQuestions = 32
        , maxExports = 32
        , bootstrapServer = Nothing
        }

runRpcT :: VatConfig -> Transport IO -> RpcT IO () -> IO ()
runRpcT config transport (RpcT m) = do
    vat <- newVat config
    foldl concurrently_
        (recvLoop transport vat)
        [ sendLoop transport vat
        , coordinator vat
        , runReaderT m vat
        ]

newVat :: VatConfig -> IO Vat
newVat VatConfig{..} = atomically $ do
    questions <- newTVar M.empty
    answers <- newTVar M.empty
    imports  <- newTVar M.empty
    exports <- newTVar M.empty

    questionIdPool <- newTVar [0..maxQuestions-1]
    exportIdPool <- newTVar [0..maxExports-1]

    sendQ <- newTBQueue $ fromIntegral maxQuestions
    recvQ <- newTBQueue $ fromIntegral maxQuestions

    pure Vat{..}

sendLoop :: Transport IO -> Vat -> IO ()
sendLoop transport Vat{sendQ} =
    forever $ atomically (readTBQueue sendQ) >>= sendMsg transport

recvLoop :: Transport IO -> Vat -> IO ()
recvLoop transport Vat{recvQ} =
    forever $ recvMsg transport >>= atomically . writeTBQueue recvQ


-- | The coordinator handles incoming messages, dispatching them as
-- method calls to local objects, forwarding return values to the right
-- place, etc.
coordinator :: Vat -> IO ()
coordinator vat@Vat{..} = forever $ do
    msg <- atomically $ readTBQueue recvQ
    let replyUnimplemented =
            atomically $ writeTBQueue sendQ $ Message'unimplemented msg
    case msg of
        Message'abort exn ->
            throwIO exn
        Message'return ret ->
            handleReturn vat msg ret
        Message'bootstrap Bootstrap{questionId} ->
            case bootstrapServer of
                Nothing ->
                    replyUnimplemented
                Just server -> atomically $
                    modifyTVar' answers $ M.insert questionId (ServerAnswer server)
                    -- TODO: also add it to exports and send a Return.
        Message'call Call{target,interfaceId,methodId,params} ->
            case target of
                MessageTarget'importedCap _ ->
                    replyUnimplemented
                MessageTarget'promisedAnswer PromisedAnswer{questionId, transform}
                    | V.length transform == 0 -> do
                        result <- atomically $ M.lookup questionId <$> readTVar answers
                        case result of
                            Nothing -> do
                                let exn = def
                                        { reason = "Received 'Call' on non-existant promised answer #"
                                            <> T.pack (show questionId)
                                        , type_ = Exception'Type'failed
                                        }
                                atomically $ writeTBQueue sendQ $ Message'abort exn
                                -- TODO: adjust this so we don't throw (and thus kill the connection)
                                -- before the abort message is actually sent.
                                throwIO exn
                            Just (ServerAnswer Server{handleCall}) -> do
                                result <- try $ do
                                    ret <- handleCall interfaceId methodId params
                                    liftIO $ waitIO ret
                                atomically $ writeTBQueue sendQ $ Message'return $ case result of
                                    -- The server returned successfully; pass along the result.
                                    Right ok -> def
                                        { answerId = questionId
                                        , union' = Return'results def
                                            { content = Just (PtrStruct ok)
                                            }
                                        }
                                    Left (e :: SomeException) -> def
                                        -- The server threw an exception; we need to report this
                                        -- to the caller.
                                        { answerId = questionId
                                        , union' = Return'exception $
                                            case fromException e of
                                                Just (e :: Rpc.Exception) ->
                                                    -- If the exception was a capnp exception,
                                                    -- just pass it along.
                                                    e
                                                Nothing -> def
                                                    -- Otherwise, return something opaque to
                                                    -- the caller; the exception could potentially
                                                    -- contain sensitive info.
                                                    { reason = "unhandled exception"
                                                    , type_ = Exception'Type'failed
                                                    }
                                        }

                    | otherwise ->
                        replyUnimplemented
                MessageTarget'unknown' _ ->
                    replyUnimplemented
        _ ->
            replyUnimplemented

-- | Handle receiving a 'Return' message.
handleReturn :: Vat -> Message -> Return -> IO ()
handleReturn Vat{..} msg Return{..} = handleErrs $ do
        question <- M.lookup answerId <$> readTVar questions
        case question of
            Nothing ->
                abort def
                    { reason = "Received 'Return' for non-existant question #"
                        <> T.pack (show answerId)
                    , type_ = Exception'Type'failed
                    }
            Just (BootstrapQuestion _) -> do
                -- This will case the other side to drop the resolved cap; we'll
                -- just keep using the promise.
                writeTBQueue sendQ $ Message'unimplemented msg
                modifyTVar questions $ M.delete answerId
                ok
            Just CallQuestion{callMsg, sendReturn} -> do
                -- We don't support caps other than the bootstrap yet, so we can
                -- send Finish right away.
                writeTBQueue sendQ $ Message'finish def { questionId = answerId }
                modifyTVar questions $ M.delete answerId
                case union' of
                    Return'results Payload{content} ->
                        handleResult sendReturn content
                    Return'exception exn -> do
                        breakPromise sendReturn exn
                        ok
                    _ ->
                        abort def
                            { reason = "Received unexpected return variant " <>
                                "(we only support results and exception)."
                            , type_ = Exception'Type'failed
                            }

  where
    -- | Run a transaction, which may *return* an error (as opposed to throwing
    -- one) via 'Left'; if it does, throw the error, otherwise return ().
    --
    -- The reason for this is so we can report errors while still commiting the
    -- transaction; if we did 'throwSTM' it would roll back the results.
    handleErrs transaction = do
        ret <- atomically transaction
        case ret of
            Left exn ->
                throwIO exn
            Right () ->
                pure ()

    -- | Send an exception to the remote vat, and also return it (to be raised
    -- by handleErrs).
    abort exn = do
        writeTBQueue sendQ $ Message'abort exn
        pure $ Left exn
    -- | Shorthand to return from a transaction with no error.
    ok = pure $ Right ()

    -- | handle the @result@ variant of a 'Return'.
    handleResult sendReturn content = case content of
        Nothing -> do
            fulfill sendReturn def
            ok
        Just (PtrStruct s) -> do
            fulfill sendReturn s
            ok
        Just _ -> abort def
            -- TODO: I(zenhack) am not sure it's actually invalid to have
            -- capability in a return value, so maybe we should relax this
            -- a bit.
            { reason = "Received non-struct pointer in " <>
                "a return message."
            , type_ = Exception'Type'failed
            }
