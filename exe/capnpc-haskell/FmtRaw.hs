-- Generate low-level accessors from type types in HsSchema.
{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module FmtRaw
    ( fmtModule
    ) where

import HsSchema

import Data.Capnp.Core.Schema (Id)
import Data.Monoid            ((<>))
import Text.Printf            (printf)
import Util                   (mintercalate)

import qualified Data.Text.Lazy.Builder as TB

fmtModule :: Module -> TB.Builder
fmtModule Module{..} = mintercalate "\n"
    [ "{-# OPTIONS_GHC -Wno-unused-imports #-}"
    , "module " <> fmtModRef (ByCapnpId modId) <> " where"
    , ""
    , "-- generated from " <> TB.fromText modFile
    , ""
    , "import Data.Int"
    , "import Data.Word"
    , ""
    , "import qualified Data.Capnp.BuiltinTypes"
    , "import qualified Data.Capnp.Untyped"
    , ""
    , mintercalate "\n" $ map fmtImport modImports
    , ""
    , mintercalate "\n" $ map (fmtDataDef modId) modDefs
    ]

fmtModRef :: ModuleRef -> TB.Builder
fmtModRef (ByCapnpId id) = TB.fromString $ printf "Data.Capnp.ById.X%x" id
fmtModRef (FullyQualified (Namespace ns)) = mintercalate "." (map TB.fromText ns)

fmtImport :: Import -> TB.Builder
fmtImport (Import ref) = "import qualified " <> fmtModRef ref

fmtNewtypeStruct :: Id -> Name -> TB.Builder
fmtNewtypeStruct thisMod name =
    let nameText = fmtName thisMod name
    in mconcat
        [ "newtype "
        , nameText
        , " b = "
        , nameText
        , " (Data.Capnp.Untyped.Struct b)\n"
        ]

fmtDataDef :: Id -> DataDef -> TB.Builder
fmtDataDef thisMod DataDef{dataVariants=[variant], dataCerialType=CTyStruct, ..} =
    fmtNewtypeStruct thisMod dataName
fmtDataDef thisMod DataDef{dataCerialType=CTyStruct,..} = mconcat
    [ "data ", fmtName thisMod dataName, " b"
    , "\n    = "
    , mintercalate "\n    | " (map fmtDataVariant dataVariants)
    -- Generate auxiliary newtype definitions for group fields:
    , "\n"
    , mintercalate "\n\n" (map fmtVariantAuxNewtype dataVariants)
    ]
  where
    fmtDataVariant Variant{..} = fmtName thisMod variantName <>
        case variantParams of
            Record _   -> " (" <> fmtName thisMod (subName variantName "group'") <> " b)"
            NoParams   -> ""
            Unnamed ty -> " " <> fmtType ty

    fmtVariantAuxNewtype Variant{variantName, variantParams=Record _} =
        fmtNewtypeStruct thisMod (subName variantName "group'")
    fmtVariantAuxNewtype _ = ""

    fmtType :: Type -> TB.Builder
    fmtType (ListOf eltType) =
        "(Data.Capnp.Untyped.ListOf b " <> fmtType eltType <> ")"
    fmtType (Type name []) = "(" <> fmtName thisMod name <> " b)"
    fmtType (Type name params) = mconcat
        [ "("
        , fmtName thisMod name
        , " b "
        , mintercalate " " (map fmtType params)
        , ")"
        ]
    fmtType (PrimType prim) = fmtPrimType prim
    fmtType (Untyped ty) = "(Maybe " <> fmtUntyped ty <> ")"
fmtDataDef _ _ = ""

fmtPrimType :: PrimType -> TB.Builder
-- TODO: most of this (except Text & Data) should probably be shared with FmtPure.
fmtPrimType PrimInt{isSigned=True,size}  = "Int" <> TB.fromString (show size)
fmtPrimType PrimInt{isSigned=False,size} = "Word" <> TB.fromString (show size)
fmtPrimType PrimFloat32                  = "Float"
fmtPrimType PrimFloat64                  = "Double"
fmtPrimType PrimBool                     = "Bool"
fmtPrimType PrimVoid                     = "()"
fmtPrimType PrimText                     = "(Data.Capnp.BuiltinTypes.Text b)"
fmtPrimType PrimData                     = "(Data.Capnp.BuiltinTypes.Data b)"

fmtUntyped :: Untyped -> TB.Builder
fmtUntyped Struct = "(Data.Capnp.Untyped.Struct b)"
fmtUntyped List   = "(Data.Capnp.Untyped.List b)"
fmtUntyped Cap    = "Word32"
fmtUntyped Ptr    = "(Data.Capnp.Untyped.Ptr b)"

fmtName :: Id -> Name -> TB.Builder
fmtName thisMod Name{nameModule, nameLocalNS=Namespace parts, nameUnqualified=localName} =
    modPrefix <> mintercalate "'" (map TB.fromText $ parts <> [localName])
  where
    modPrefix = case nameModule of
        ByCapnpId id                  | id == thisMod -> ""
        FullyQualified (Namespace []) -> ""
        _                             -> fmtModRef nameModule <> "."
