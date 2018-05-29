-- Generate low-level accessors from type types in IR.
{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
module FmtRaw
    ( fmtModule
    ) where

import IR

import Data.Capnp.Core.Schema (Id)
import Data.List              (sortOn)
import Data.Monoid            ((<>))
import Text.Printf            (printf)
import Util                   (mintercalate)

import qualified Data.Text.Lazy.Builder as TB

fmtModule :: Module -> TB.Builder
fmtModule Module{..} = mintercalate "\n"
    [ "{-# OPTIONS_GHC -Wno-unused-imports #-}"
    , "{-# LANGUAGE FlexibleInstances #-}"
    , "{-# LANGUAGE MultiParamTypeClasses #-}"
    , "{-# LANGUAGE KindSignatures #-}"
    , "module " <> fmtModRef (ByCapnpId modId) <> " where"
    , ""
    , "-- Code generated by capnpc-haskell. DO NOT EDIT."
    , "-- Generated from schema file: " <> TB.fromText modFile
    , ""
    , "import Data.Int"
    , "import Data.Word"
    , "import qualified Data.Bits"
    , "import qualified Data.Maybe"
    , "import qualified Codec.Capnp"
    , "import qualified Data.Capnp.BuiltinTypes"
    , "import qualified Data.Capnp.TraversalLimit"
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

-- | format the IsPtr instance for a list of the struct type with
-- the given name.
fmtStructListIsPtr :: TB.Builder -> TB.Builder
fmtStructListIsPtr nameText = mconcat
    [ "instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (", nameText, " m b)) b where\n"
    , "    fromPtr = Codec.Capnp.structListPtr\n"
    ]

fmtNewtypeStruct :: Id -> Name -> TB.Builder
fmtNewtypeStruct thisMod name =
    let nameText = fmtName thisMod name
    in mconcat
        [ "newtype "
        , nameText
        , " (m :: * -> *) b = "
        , nameText
        , " (Data.Capnp.Untyped.Struct m b)\n\n"
        , "instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (", nameText, " m b) b where\n"
        , "    fromStruct = pure . ", nameText, "\n"
        , "instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (", nameText, " m b) b where\n"
        , "    fromPtr = Codec.Capnp.structPtr\n"
        , "\n"
        , fmtStructListIsPtr nameText
        ]


-- | Generate a call to 'Codec.Capnp.getWordField' based on a 'DataLoc'.
-- The first argument is an expression for the struct.
fmtGetWordField :: TB.Builder -> DataLoc -> TB.Builder
fmtGetWordField struct DataLoc{..} = mintercalate " "
    [ " Codec.Capnp.getWordField"
    , struct
    , TB.fromString (show dataIdx)
    , TB.fromString (show dataOff)
    , TB.fromString (show dataDef)
    ]

fmtFieldAccessor :: Id -> Name -> Name -> Field -> TB.Builder
fmtFieldAccessor thisMod typeName variantName Field{..} =
    let nameSuffix = fmtName thisMod (subName variantName fieldName)
        getName = "get_" <> nameSuffix
        hasName = "has_" <> nameSuffix
    in mconcat
        [ getName, " :: Data.Capnp.Untyped.ReadCtx m b => "
        , fmtName thisMod typeName, " m b -> m ", fmtType thisMod fieldType, "\n"
        , getName
        , " (", fmtName thisMod typeName, " struct) =", case fieldLoc of
            DataField loc -> fmtGetWordField "struct" loc
            PtrField idx -> mconcat
                [ "\n    Data.Capnp.Untyped.getPtr ", TB.fromString (show idx), " struct"
                , "\n    >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct)"
                , "\n"
                ]
            HereField -> " Codec.Capnp.fromStruct struct"
            VoidField -> " Data.Capnp.TraversalLimit.invoice 1 >> pure ()"
        , "\n\n"
        , hasName, " :: Data.Capnp.Untyped.ReadCtx m b => ", fmtName thisMod typeName, " m b -> m Bool\n"
        , hasName, "(", fmtName thisMod typeName, " struct) = "
        , case fieldLoc of
            DataField DataLoc{dataIdx} ->
                "pure $ " <> TB.fromString (show dataIdx) <> " < Data.Capnp.Untyped.length (Data.Capnp.Untyped.dataSection struct)"
            PtrField idx ->
                "Data.Maybe.isJust <$> Data.Capnp.Untyped.getPtr " <> TB.fromString (show idx) <> " struct"
            HereField -> "pure True"
            VoidField -> "pure True"
        ]

fmtDataDef :: Id -> DataDef -> TB.Builder
fmtDataDef thisMod DataDef{dataVariants=[Variant{..}], dataCerialType=CTyStruct, ..} =
    fmtNewtypeStruct thisMod dataName <>
    case variantParams of
        Record fields ->
            mintercalate "\n" $ map (fmtFieldAccessor thisMod dataName variantName) fields
        _ -> ""
fmtDataDef thisMod DataDef{dataCerialType=CTyStruct,dataTagLoc=Just tagLoc,dataName,dataVariants} =
    let nameText = fmtName thisMod dataName
    in mconcat
        [ "data ", nameText, " (m :: * -> *) b"
        , "\n    = "
        , mintercalate "\n    | " (map fmtDataVariant dataVariants)
        -- Generate auxiliary newtype definitions for group fields:
        , "\n"
        , mintercalate "\n" (map fmtVariantAuxNewtype dataVariants)
        , "\ninstance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsStruct m (", nameText, " m b) b where"
        , "\n    fromStruct struct = do"
        , "\n        tag <- ", fmtGetWordField "struct" tagLoc
        , "\n        case tag of"
        , mconcat $ map fmtVariantCase $ reverse $ sortOn variantTag dataVariants
        , "\n"
        , "\ninstance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (", nameText, " m b) b where"
        , "\n    fromPtr = Codec.Capnp.structPtr"
        , "\n"
        , fmtStructListIsPtr nameText
        ]
  where
    fmtDataVariant Variant{..} = fmtName thisMod variantName <>
        case variantParams of
            Record _   -> " (" <> fmtName thisMod (subName variantName "group'") <> " m b)"
            NoParams   -> ""
            Unnamed ty _ -> " " <> fmtType thisMod ty
    fmtVariantCase Variant{..} =
        let nameText = fmtName thisMod variantName
        in "\n            " <>
            case variantTag of
                Just tag ->
                    mconcat
                        [ TB.fromString (show tag), " -> "
                        , case variantParams of
                            Record _  -> nameText <> " <$> Codec.Capnp.fromStruct struct"
                            NoParams  -> "pure " <> nameText
                            Unnamed _ HereField -> nameText <> " <$> Codec.Capnp.fromStruct struct"
                            Unnamed _ VoidField -> error
                                "Shouldn't happen; this should be NoParams."
                                -- TODO: rule this out statically if possible.
                            Unnamed _ (DataField loc) ->
                                nameText <> " <$> " <> fmtGetWordField "struct" loc
                            Unnamed _ (PtrField idx) -> mconcat
                                [ nameText <> " <$> "
                                , " (Data.Capnp.Untyped.getPtr ", TB.fromString (show idx), " struct"
                                , " >>= Codec.Capnp.fromPtr (Data.Capnp.Untyped.message struct))"
                                ]
                        ]
                Nothing ->
                    "_ -> pure $ " <> nameText <> " tag"
    fmtVariantAuxNewtype Variant{variantName, variantParams=Record fields} =
        let typeName = subName variantName "group'"
        in fmtNewtypeStruct thisMod typeName <>
            mintercalate "\n" (map (fmtFieldAccessor thisMod typeName variantName) fields)
    fmtVariantAuxNewtype _ = ""
-- Assume this is an enum, for now:
fmtDataDef thisMod DataDef{dataCerialType=CTyWord 16,..} =
    let typeName = fmtName thisMod dataName
    in mconcat
        [ "data ", typeName, " (m :: * -> *) b"
        , "\n    = "
        , mintercalate "\n    | " (map fmtEnumVariant dataVariants)
        , "\n"
        -- Generate an Enum instance. This is a trivial wrapper around the
        -- IsWord instance, below.
        , "instance Enum (", typeName, " m b) where\n"
        , "    toEnum = Codec.Capnp.fromWord . fromIntegral\n"
        , "    fromEnum = fromIntegral . Codec.Capnp.toWord\n"
        , "\n\n"
        -- Generate an IsWord instance.
        , "instance Codec.Capnp.IsWord (", typeName, " m b) where"
        , "\n    fromWord "
        , mintercalate "\n    fromWord " $
            map fmtEnumFromWordCase $ reverse $ sortOn variantTag dataVariants
        , "\n    toWord "
        , mintercalate "\n    toWord " $
            map fmtEnumToWordCase   $ reverse $ sortOn variantTag dataVariants
        , "\n"
        , "instance Data.Capnp.Untyped.ReadCtx m b => Codec.Capnp.IsPtr m (Data.Capnp.Untyped.ListOf m b (", typeName, " m b)) b where"
        , "\n    fromPtr msg ptr = fmap"
        , "\n       (fmap (toEnum . (fromIntegral :: Word16 -> Int)))"
        , "\n       (Codec.Capnp.fromPtr msg ptr)"
        , "\n"
        ]
  where
    -- | Format a data constructor in the definition of a data type for an enum.
    fmtEnumVariant Variant{variantName,variantParams=NoParams,variantTag=Just _} =
        fmtName thisMod variantName
    fmtEnumVariant Variant{variantName,variantParams=Unnamed ty _, variantTag=Nothing} =
        fmtName thisMod variantName <> " " <> fmtType thisMod ty
    fmtEnumVariant variant =
        error $ "Unexpected variant for enum: " ++ show variant
    -- | Format an equation in an enum's IsWord.fromWord implementation.
    fmtEnumFromWordCase Variant{variantTag=Just tag,variantName} =
        -- For the tags we know about:
        TB.fromString (show tag) <> " = " <> fmtName thisMod variantName
    fmtEnumFromWordCase Variant{variantTag=Nothing,variantName} =
        -- For other tags:
        "tag = " <> fmtName thisMod variantName <> " (fromIntegral tag)"
    -- | Format an equation in an enum's IsWord.toWord implementation.
    fmtEnumToWordCase Variant{variantTag=Just tag,variantName} =
        fmtName thisMod variantName <> " = " <> TB.fromString (show tag)
    fmtEnumToWordCase Variant{variantTag=Nothing,variantName} =
        "(" <> fmtName thisMod variantName <> " tag) = fromIntegral tag"
fmtDataDef _ dataDef =
    error $ "Unexpected data definition: " ++ show dataDef

fmtType :: Id -> Type -> TB.Builder
fmtType thisMod = \case
    ListOf eltType ->
        "(Data.Capnp.Untyped.ListOf m b " <> fmtType thisMod eltType <> ")"
    Type name [] ->
        "(" <> fmtName thisMod name <> " m b)"
    Type name params -> mconcat
        [ "("
        , fmtName thisMod name
        , " m b "
        , mintercalate " " $ map (fmtType thisMod) params
        , ")"
        ]
    PrimType prim -> fmtPrimType prim
    Untyped ty -> "(Maybe " <> fmtUntyped ty <> ")"

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
fmtUntyped Struct = "(Data.Capnp.Untyped.Struct m b)"
fmtUntyped List   = "(Data.Capnp.Untyped.List m b)"
fmtUntyped Cap    = "Word32"
fmtUntyped Ptr    = "(Data.Capnp.Untyped.Ptr m b)"

fmtName :: Id -> Name -> TB.Builder
fmtName thisMod Name{nameModule, nameLocalNS=Namespace parts, nameUnqualified=localName} =
    modPrefix <> mintercalate "'" (map TB.fromText $ parts <> [localName])
  where
    modPrefix = case nameModule of
        ByCapnpId id                  | id == thisMod -> ""
        FullyQualified (Namespace []) -> ""
        _                             -> fmtModRef nameModule <> "."
