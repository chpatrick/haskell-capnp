{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedLists   #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
-- Generate idiomatic haskell data types from the types in IR.
module Backends.Pure
    ( fmtModule
    ) where

import IR
import Util

import Data.Monoid (mconcat, (<>))
import GHC.Exts    (IsList(..))
import Text.Printf (printf)

import qualified Data.Text              as T
import qualified Data.Text.Lazy.Builder as TB

-- | If a module reference refers to a generated module, does it
-- refer to the raw, low-level module or the *.Pure variant (which
-- this module generates)?
data ModRefType = Pure | Raw
    deriving(Show, Read, Eq)

fmtName :: ModRefType -> Id -> Name -> TB.Builder
fmtName refTy thisMod Name{..} = modPrefix <> localName
  where
    localName = mintercalate "'" $
        map TB.fromText $ fromList $ toList nameLocalNS ++ [nameUnqualified]
    modPrefix
        | null nsParts = ""
        | refTy == Pure && modRefToNS refTy (ByCapnpId thisMod) == ns = ""
        | otherwise = fmtModRef refTy nameModule <> "."
    ns@(Namespace nsParts) = modRefToNS refTy nameModule

modRefToNS :: ModRefType -> ModuleRef -> Namespace
modRefToNS _ (FullyQualified ns) = ns
modRefToNS ty (ByCapnpId id) = Namespace $ case ty of
    Pure -> ["Capnp", "ById", T.pack (printf "X%x" id), "Pure"]
    Raw  -> ["Capnp", "ById", T.pack (printf "X%x" id)]

fmtModule :: Module -> [(FilePath, TB.Builder)]
fmtModule Module{modName=Namespace modNameParts,..} =
    [ ( T.unpack $ mintercalate "/" humanParts <> ".hs"
      , mainContent
      )
    , ( printf "Capnp/ById/X%x/Pure.hs" modId
      , mconcat
            [ "{-# OPTIONS_GHC -Wno-unused-imports #-}\n"
            , "module ", fmtModRef Pure (ByCapnpId modId), "(module ", humanMod, ") where\n"
            , "\n"
            , "import ", humanMod, "\n"
            ]
      )
    ]
 where
  humanMod = fmtModRef Pure $ FullyQualified $ Namespace humanParts
  humanParts = "Capnp":modNameParts
  mainContent = mintercalate "\n"
    [ "{-# LANGUAGE DuplicateRecordFields #-}"
    , "{-# LANGUAGE FlexibleInstances #-}"
    , "{-# LANGUAGE FlexibleContexts #-}"
    , "{-# LANGUAGE MultiParamTypeClasses #-}"
    , "{-# LANGUAGE ScopedTypeVariables #-}"
    , "{-# OPTIONS_GHC -Wno-unused-imports #-}"
    , "module " <> humanMod <> " where"
    , ""
    , "-- Code generated by capnpc-haskell. DO NOT EDIT."
    , "-- Generated from schema file: " <> TB.fromText modFile
    , ""
    , "import Data.Int"
    , "import Data.Word"
    , ""
    , "import Data.Capnp.Untyped.Pure (List)"
    , "import Data.Capnp.BuiltinTypes.Pure (Data, Text)"
    , "import Control.Monad.Catch (MonadThrow)"
    , "import Data.Capnp.TraversalLimit (MonadLimit)"
    , ""
    , "import qualified Data.Capnp.Untyped.Pure"
    , "import qualified Data.Capnp.Untyped"
    , "import qualified Codec.Capnp"
    , ""
    , fmtImport Raw $ Import (ByCapnpId modId)
    , mintercalate "\n" $ map (fmtImport Pure) modImports
    , mintercalate "\n" $ map (fmtImport Raw) modImports
    , ""
    , mconcat $ map (fmtDecl modId) modDecls
    ]

fmtImport :: ModRefType -> Import -> TB.Builder
fmtImport ty (Import ref) = "import qualified " <> fmtModRef ty ref

fmtModRef :: ModRefType -> ModuleRef -> TB.Builder
fmtModRef ty ref = mintercalate "." (map TB.fromText $ toList $ modRefToNS ty ref)

fmtType :: Id -> Type -> TB.Builder
fmtType thisMod (Type name params) =
    fmtName Pure thisMod name
    <> mconcat [" (" <> fmtType thisMod ty <> ")" | ty <- params]
fmtType thisMod (ListOf eltType) = "List (" <> fmtType thisMod eltType <> ")"
fmtType thisMod (PrimType prim)  = fmtPrimType prim
fmtType thisMod (Untyped ty)     = "Maybe (" <> fmtUntyped ty <> ")"

fmtPrimType :: PrimType -> TB.Builder
fmtPrimType PrimInt{isSigned=True,size}  = "Int" <> TB.fromString (show size)
fmtPrimType PrimInt{isSigned=False,size} = "Word" <> TB.fromString (show size)
fmtPrimType PrimFloat32                  = "Float"
fmtPrimType PrimFloat64                  = "Double"
fmtPrimType PrimBool                     = "Bool"
fmtPrimType PrimText                     = "Text"
fmtPrimType PrimData                     = "Data"
fmtPrimType PrimVoid                     = "()"

fmtUntyped :: Untyped -> TB.Builder
fmtUntyped Struct = "Data.Capnp.Untyped.Pure.Struct"
fmtUntyped List   = "Data.Capnp.Untyped.Pure.List'"
fmtUntyped Cap    = "Data.Capnp.Untyped.Pure.Cap"
fmtUntyped Ptr    = "Data.Capnp.Untyped.Pure.PtrType"

fmtVariant :: Id -> Variant -> TB.Builder
fmtVariant thisMod Variant{variantName,variantParams} =
    fmtName Pure thisMod variantName
    <> case variantParams of
        NoParams -> ""
        Unnamed ty _ -> " (" <> fmtType thisMod ty <> ")"
        Record [] -> ""
        Record fields -> mconcat
            [ "\n        { "
            , mintercalate "\n        , " $ map (fmtField thisMod) fields
            ,  "\n        }"
            ]

fmtField :: Id -> Field -> TB.Builder
fmtField thisMod Field{fieldName,fieldType} =
    TB.fromText fieldName <> " :: " <> fmtType thisMod fieldType

fmtDecl :: Id -> (Name, Decl) -> TB.Builder
fmtDecl thisMod (name, DeclDef d)   = fmtDataDef thisMod name d
-- TODO: this is copypasta from the Raw backend. We should factor this out.
fmtDecl thisMod (name, DeclConst WordConst{wordType,wordValue}) =
    let nameText = fmtName Pure thisMod (valueName name)
    in mconcat
        [ nameText, " :: ", fmtType thisMod wordType, "\n"
        , nameText, " = Codec.Capnp.fromWord ", TB.fromString (show wordValue), "\n"
        ]

fmtDataDef ::  Id -> Name -> DataDef -> TB.Builder
fmtDataDef thisMod dataName DataDef{dataVariants,dataCerialType} =
    let rawName = fmtName Raw thisMod dataName
        pureName = fmtName Pure thisMod dataName
    in mconcat
        [ "data ", fmtName Pure thisMod dataName, "\n    = "
        , mintercalate "\n    | " $ map (fmtVariant thisMod) dataVariants
        , "\n    deriving(Show, Read, Eq)"
        , "\n\n"
        , "instance Codec.Capnp.Decerialize "
        , rawName
        , " "
        , pureName
        , " where\n"
        , "    decerialize raw = "
        , case dataVariants of
            [Variant{variantName,variantParams=Record fields}] ->
                fmtDecerializeArgs variantName fields
            _ -> mconcat
                [ "case raw of\n"
                , "\n        "
                , mintercalate "\n        " (map fmtDecerializeVariant dataVariants)
                ]
        , "\n\n"
        , case dataCerialType of
            CTyStruct -> mconcat
                [ "instance Codec.Capnp.IsStruct "
                , pureName, " where\n"
                , "    fromStruct struct = do\n"
                , "        raw <- Codec.Capnp.fromStruct struct\n"
                , "        Codec.Capnp.decerialize (raw :: ", rawName, ")\n"
                , "\n"
                ]
            _ ->
                ""
        ]
  where
    fmtDecerializeArgs variantName fields = mconcat
        [ fmtName Pure thisMod variantName
        , "\n            <$> "
        , mintercalate "\n            <*> " $
            flip map fields $ \Field{fieldName} -> mconcat
                [ "(", fmtName Raw thisMod $ prefixName "get_" (subName variantName fieldName)
                , " raw >>= Codec.Capnp.decerialize)"
                ]
        ]
    fmtDecerializeVariant Variant{variantName,variantParams} =
        fmtName Raw thisMod variantName <>
        case variantParams of
            NoParams -> " -> pure " <> fmtName Pure thisMod variantName
            Record fields ->
              " raw -> " <> fmtDecerializeArgs variantName fields
            _ -> mconcat
                [ " val -> "
                , fmtName Pure thisMod variantName
                , " <$> Codec.Capnp.decerialize val"
                ]
