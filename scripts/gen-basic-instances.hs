{-# LANGUAGE RecordWildCards #-}
-- | Script that generates 'Internal.Gen.Instances', which is mostly a
-- bunch of tedious instances for basic types for our various type classes.
module Main where

header = unlines
    [ "{-# LANGUAGE TypeFamilies #-}"
    , "{-# LANGUAGE FlexibleInstances #-}"
    , "{-# LANGUAGE MultiParamTypeClasses #-}"
    , "module Internal.Gen.Instances where"
    , "-- This module is auto-generated by gen-builtintypes-lists.hs; DO NOT EDIT."
    , ""
    , "import Data.Int"
    , "import Data.ReinterpretCast"
    , "import Data.Word"
    , ""
    , "import Data.Capnp.Classes"
    , "    ( ListElem(..)"
    , "    , MutListElem(..)"
    , "    , IsPtr(..)"
    , "    )"
    , ""
    , "import qualified Data.Capnp.Untyped as U"
    , ""
    ]

data InstanceParams = P
    { to         :: String
    , from       :: String
    , typed      :: String
    , untyped    :: String
    , listSuffix :: String
    }


genInstance P{..} = concat
    [ "instance ListElem msg ", typed, " where\n"
    , "    newtype List msg ", typed, " = List", typed, " (U.ListOf msg ", untyped, ")\n"
    , "    length (List", typed, " l) = U.length l\n"
    , "    index i (List", typed, " l) = ", from, " <$> U.index i l\n"
    , "instance MutListElem s ", typed, " where\n"
    , "    setIndex elt i (", dataCon, " l) = U.setIndex (", to, " elt) i l\n"
    , "    newList msg size = List", typed, " <$> U.allocList", listSuffix, " msg size\n"
    , "instance IsPtr msg (List msg ", typed, ") where\n"
    , "    fromPtr msg ptr = List", typed, " <$> fromPtr msg ptr\n"
    , "    toPtr _ (List", typed, " list) = pure $ Just (U.PtrList (U.List", listSuffix, " list))\n"
    ]
  where
    dataCon = "List" ++ typed

sizes = [8, 16, 32, 64]

intInstance size = P
    { to = "fromIntegral"
    , from = "fromIntegral"
    , typed = "Int" ++ show size
    , untyped = "Word" ++ show size
    , listSuffix = show size
    }

wordInstance size = P
    { to = "id"
    , from = "id"
    , typed = "Word" ++ show size
    , untyped = "Word" ++ show size
    , listSuffix = show size
    }

instances =
    map intInstance sizes ++
    map wordInstance sizes ++
    [ P { to = "floatToWord"
        , from = "wordToFloat"
        , typed = "Float"
        , untyped = "Word32"
        , listSuffix = "32"
        }
    , P { to = "doubleToWord"
        , from = "wordToDouble"
        , typed = "Double"
        , untyped = "Word64"
        , listSuffix = "64"
        }
    , P { to = "id"
        , from = "id"
        , typed = "Bool"
        , untyped = "Bool"
        , listSuffix = "1"
        }
    ]

main = writeFile "lib/Internal/Gen/Instances.hs" $
    header ++ concatMap genInstance instances
