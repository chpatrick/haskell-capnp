-- IR for a high-level representation of the low-level API modules.
--
-- This talks about things like getters, setters, wrapper types for structs,
-- etc. It's still not at the level of detail of actual Haskell, but encodes
-- the constructs to be generated, as opposed to the declarative description
-- of the schema.
{-# LANGUAGE DuplicateRecordFields #-}
module IR.Raw (File(..), Decl(..), Variant(..), TagSetter(..)) where

import Data.Word

import qualified IR.Common as Common
import qualified IR.Name   as Name

data File = File
    { fileId      :: !Word64
    , fileName    :: FilePath
    , fileImports :: [Word64]
    , decls       :: [Decl]
    }
    deriving(Show, Read, Eq)

data Decl
    -- | Define a newtype wrapper around a struct. This also defines
    -- some instances of type classes that exist for all such wrappers.
    = StructWrapper
        { typeCtor :: Name.LocalQ
        }
    -- | Define instances of several type classes which should only
    -- exist for "real" structs, i.e. not groups.
    | StructInstances
        { typeCtor      :: Name.LocalQ
        -- ^ The type constructor for the type to generate instances for.

        -- Needed for some instances:
        , dataWordCount :: !Word16
        , pointerCount  :: !Word16
        }
    | InterfaceWrapper
        { typeCtor :: Name.LocalQ
        }
    | UnionVariant
        { typeCtor       :: Name.LocalQ
        , tagOffset      :: !Word32
        , unionDataCtors :: [Variant]
        }
    | Enum
        { typeCtor  :: Name.LocalQ
        , dataCtors :: [Name.LocalQ]
        }
    | Getter
        { fieldName     :: Name.LocalQ
        , containerType :: Name.LocalQ
        , fieldLocType  :: Common.FieldLocType Name.CapnpQ
        }
    | Setter
        { fieldName     :: Name.LocalQ
        , containerType :: Name.LocalQ
        , fieldLocType  :: Common.FieldLocType Name.CapnpQ

        , tag           :: Maybe TagSetter
        -- ^ Info for setting the tag, if this is a union.
        }
    deriving(Show, Read, Eq)

data TagSetter = TagSetter
    { tagOffset :: !Word32
    , tagValue  :: !Word16
    }
    deriving(Show, Read, Eq)

data Variant = Variant
    { name     :: Name.LocalQ
    , tagValue :: !Word16
    , locType  :: Common.FieldLocType Name.CapnpQ
    }
    deriving(Show, Read, Eq)
