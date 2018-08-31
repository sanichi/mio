module Y16D22 exposing (answer)

import Dict exposing (Dict)
import Regex exposing (find)
import Util exposing (regex)


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> viable
            |> String.fromInt

    else
        input
            |> parse
            |> print


viable : Cluster -> Int
viable cluster =
    viable1 0 0 0 cluster


viable1 : Int -> Int -> Int -> Cluster -> Int
viable1 x y total cluster =
    if x >= cluster.width then
        total

    else if y >= cluster.height then
        viable1 (x + 1) 0 total cluster

    else
        viable2 x y x (y + 1) total cluster


viable2 : Int -> Int -> Int -> Int -> Int -> Cluster -> Int
viable2 x1 y1 x2 y2 total cluster =
    if x2 >= cluster.width then
        viable1 x1 (y1 + 1) total cluster

    else if y2 >= cluster.height then
        viable2 x1 y1 (x2 + 1) 0 total cluster

    else
        let
            node1 =
                cluster.nodes
                    |> Dict.get ( x1, y1 )
                    |> Maybe.withDefault invalidNode

            node2 =
                cluster.nodes
                    |> Dict.get ( x2, y2 )
                    |> Maybe.withDefault invalidNode

            add12 =
                if node1.used > 0 && node1.used <= node2.avail then
                    1

                else
                    0

            add21 =
                if node2.used > 0 && node2.used <= node1.avail then
                    1

                else
                    0

            newTotal =
                total + add12 + add21
        in
        viable2 x1 y1 x2 (y2 + 1) newTotal cluster


print : Cluster -> String
print cluster =
    cluster.height
        |> (+) -1
        |> List.range 0
        |> List.map (printRow cluster)
        |> String.join "\n"


printRow : Cluster -> Int -> String
printRow cluster y =
    cluster.width
        |> (+) -1
        |> List.range 0
        |> List.map (printNode cluster y)
        |> String.fromList


printNode : Cluster -> Int -> Int -> Char
printNode cluster y x =
    if y == 0 && x == 0 then
        '0'

    else if y == 0 && x == cluster.width - 1 then
        'G'

    else
        let
            node =
                cluster.nodes
                    |> Dict.get ( x, y )
                    |> Maybe.withDefault invalidNode
        in
        if node == invalidNode then
            ' '

        else if node.used == 0 then
            '_'

        else if node.size >= 500 then
            '#'

        else
            '.'


type alias Node =
    { x : Int
    , y : Int
    , size : Int
    , used : Int
    , avail : Int
    }


type alias Cluster =
    { width : Int
    , height : Int
    , nodes : Dict ( Int, Int ) Node
    }


invalidNode : Node
invalidNode =
    Node 0 0 0 0 0


emptyCluster : Cluster
emptyCluster =
    Cluster 0 0 Dict.empty


parse : String -> Cluster
parse input =
    input
        |> find (regex "/dev/grid/node-x(\\d+)-y(\\d+)\\s+(\\d+)T\\s+(\\d+)T\\s+(\\d+)T\\s+\\d+%")
        |> List.map .submatches
        |> List.map (List.map (Maybe.withDefault ""))
        |> List.map (List.map String.toInt)
        |> List.map (List.map (Maybe.withDefault 0))
        |> List.map toNode
        |> toCluster emptyCluster


toNode : List Int -> Node
toNode numbers =
    case numbers of
        [ x, y, size, used, avail ] ->
            Node x y size used avail

        _ ->
            invalidNode


toCluster : Cluster -> List Node -> Cluster
toCluster cluster nodes =
    case nodes of
        [] ->
            cluster

        node :: remainingNodes ->
            let
                newWidth =
                    if node.x + 1 > cluster.width then
                        node.x + 1

                    else
                        cluster.width

                newHeight =
                    if node.y + 1 > cluster.height then
                        node.y + 1

                    else
                        cluster.height

                newNodes =
                    Dict.insert ( node.x, node.y ) node cluster.nodes

                newCluster =
                    Cluster newWidth newHeight newNodes
            in
            toCluster newCluster remainingNodes
