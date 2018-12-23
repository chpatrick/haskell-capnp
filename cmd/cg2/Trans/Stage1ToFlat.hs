{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns        #-}
-- Translate from the 'Stage1' IR to the 'Flat' IR.
--
-- As the name of the latter suggests, this involves flattening the namepace.
module Trans.Stage1ToFlat (fileToFile) where

import qualified IR.Flat   as Flat
import qualified IR.Name   as Name
import qualified IR.Stage1 as Stage1

fileToFile :: Stage1.File -> Flat.File
fileToFile Stage1.File{fileNodes, fileName, fileId} =
    Flat.File
        { nodes = concatMap (nodeToNodes Name.emptyNS) fileNodes
        , fileName
        , fileId
        }

nodeToNodes :: Name.NS -> (Name.UnQ, Stage1.Node) -> [Flat.Node]
nodeToNodes ns (unQ, Stage1.Node{nodeId, nodeNested, nodeUnion}) =
    let name = Name.mkLocal ns unQ
        kids = concatMap (nodeToNodes (Name.localQToNS name)) nodeNested

        mine = case nodeUnion of
            Stage1.NodeEnum enumerants ->
                [ Flat.Node
                    { name
                    , nodeId
                    , union_ = Flat.Enum enumerants
                    }
                ]
            Stage1.NodeStruct Stage1.Struct{fields}  ->
                [ Flat.Node
                    { name
                    , nodeId
                    , union_ = Flat.Struct
                        { fields =
                            [ Flat.Field
                                { fieldName = name
                                , fieldLocType = locType
                                }
                            | Stage1.Field{name, locType, tag} <- fields
                            , tag == Nothing
                            ]
                        }
                    }
                ]
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
