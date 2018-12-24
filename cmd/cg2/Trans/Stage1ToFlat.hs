{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns        #-}
-- Translate from the 'Stage1' IR to the 'Flat' IR.
--
-- As the name of the latter suggests, this involves flattening the namepace.
module Trans.Stage1ToFlat (filesToFiles) where

import Data.Word

import Data.Maybe (isNothing)

import qualified Data.Map as M

import qualified IR.Common as C
import qualified IR.Flat   as Flat
import qualified IR.Name   as Name
import qualified IR.Stage1 as Stage1

type NodeMap = M.Map Word64 Flat.Node

filesToFiles :: [Stage1.File] -> [Flat.File]
filesToFiles inFiles = outFiles
  where
    outFiles = map (fileToFile nodeMap) inFiles
    allNodes = concat [nodes | Flat.File{nodes} <- outFiles]
    nodeMap = M.fromList [(nodeId, node) | node@Flat.Node{nodeId} <- allNodes]

fileToFile :: NodeMap -> Stage1.File -> Flat.File
fileToFile nodeMap Stage1.File{fileNodes, fileName, fileId} =
    Flat.File
        { nodes = nodesToNodes nodeMap fileId fileNodes
        , fileName
        , fileId
        }

nodesToNodes :: NodeMap -> Word64 -> [(Name.UnQ, Stage1.Node)] -> [Flat.Node]
nodesToNodes nodeMap thisMod = concatMap (go Name.emptyNS)
  where
    go ns (unQName, Stage1.Node{nodeId, nodeNested, nodeUnion}) =
        let localName = Name.mkLocal ns unQName
            kidsNS = Name.localQToNS localName
            kids = concatMap (go kidsNS) nodeNested
            name = Name.CapnpQ
                { local = localName
                , fileId = thisMod
                }
            mine = case nodeUnion of
                Stage1.NodeEnum enumerants ->
                    [ Flat.Node
                        { name
                        , nodeId
                        , union_ = Flat.Enum enumerants
                        }
                    ]
                Stage1.NodeStruct Stage1.Struct
                        { fields
                        , isGroup
                        , dataWordCount
                        , pointerCount
                        } ->
                    let fieldNodes =
                            concatMap (fieldToNodes kidsNS) fields
                    in
                    Flat.Node
                        { name
                        , nodeId
                        , union_ = Flat.Struct
                            { fields =
                                [ Flat.Field
                                    { fieldName = Name.mkSub name fieldUnQ
                                    , fieldLocType = fmap
                                        (\Stage1.Node{nodeId} -> nodeMap M.! nodeId)
                                        locType
                                    }
                                | Stage1.Field{name=fieldUnQ, locType, tag} <- fields
                                , isNothing tag
                                ]
                            , isGroup
                            , dataWordCount
                            , pointerCount
                            }
                        }
                    : fieldNodes
                Stage1.NodeInterface ->
                    [ Flat.Node
                        { name
                        , nodeId
                        , union_ = Flat.Interface
                        }
                    ]

                Stage1.NodeOther ->
                    []
        in mine ++ kids
    fieldToNodes ns Stage1.Field{name, locType} = case locType of
        C.HereField
            (C.StructType
                struct@Stage1.Node
                    { nodeUnion = Stage1.NodeStruct Stage1.Struct{isGroup=True}
                    }
            ) -> go ns (name, struct)
        _ ->
            []