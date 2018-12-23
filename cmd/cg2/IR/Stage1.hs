-- First stage IR. This models the data structures in schema.capnp more closely
-- than the other intermediate forms. Differences:
--
-- * Lots of information which we won't use is discarded.
-- * Nodes no longer reference eachother by ID; instead we include direct
--   references to the objects.
-- * The details of some structures are tweaked to make them more ergonomic
--   to use and/or more idiomatic Haskell.
module IR.Stage1
    ( File(..)
    , Node(..)
    , Node'(..)
    , Struct(..)
    , Field(..)
    ) where

import Data.Word

import qualified IR.Common as Common
import qualified IR.Name   as Name

data File = File
    { fileNodes :: [(Name.UnQ, Node)]
    , fileName  :: FilePath
    , fileId    :: !Word64
    }
    deriving(Show, Read, Eq)

data Node = Node
    { nodeNested :: [(Name.UnQ, Node)]
    , nodeUnion  :: Node'
    , nodeId     :: !Word64
    }
    deriving(Show, Read, Eq)

data Node'
    = NodeEnum [Name.UnQ]
    | NodeStruct Struct
    | NodeInterface
    | NodeOther
    deriving(Show, Read, Eq)

data Struct = Struct
    { dataWordCount :: !Word16
    , pointerCount  :: !Word16
    , isGroup       :: !Bool
    , tagOffset     :: !Word32
    , fields        :: [Field]
    }
    deriving(Show, Read, Eq)

data Field = Field
    { name    :: Name.UnQ
    , tag     :: Maybe Word16
    , locType :: Common.FieldLocType
    }
    deriving(Show, Read, Eq)
