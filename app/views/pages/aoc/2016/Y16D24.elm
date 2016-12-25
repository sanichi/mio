module Y16D24 exposing (answer)

import Dict exposing (Dict)
import Regex


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> bfs '3'
            |> toString
    else
        input
            |> parse
            |> .targets
            |> toString


bfs : Char -> State -> Int
bfs target state =
    case state.current of
        Nothing ->
            0

        Just current ->
            let
                update node =
                    if node.distance == 0 || node.distance > current.distance + 1 then
                        { node | distance = current.distance + 1 }
                    else
                        node

                updatedNeighboursList =
                    state.nodes
                        |> neighbours current.x current.y
                        |> List.map update

                maybeTarget =
                    updatedNeighboursList
                        |> List.filter (\n -> n.v == target)
                        |> List.head
            in
                case maybeTarget of
                    Just node ->
                        node.distance

                    Nothing ->
                        let
                            newUpdatedNodes =
                                updatedNeighboursList
                                    |> List.map toEntry
                                    |> Dict.fromList

                            tmpNodes =
                                Dict.union newUpdatedNodes state.nodes

                            newCurrent =
                                tmpNodes
                                    |> Dict.values
                                    |> List.filter (\n -> n.distance > 0)
                                    |> List.map (\n -> ( n.distance, n ))
                                    |> List.sortBy Tuple.first
                                    |> List.map Tuple.second
                                    |> List.head

                            newNodes =
                                case newCurrent of
                                    Nothing ->
                                        tmpNodes

                                    Just node ->
                                        Dict.remove ( node.x, node.y ) tmpNodes

                            newState =
                                { state | current = newCurrent, nodes = newNodes }
                        in
                            bfs target newState


neighbours : Int -> Int -> Dict Location Node -> List Node
neighbours x y nodes =
    let
        r =
            ( x + 1, y )

        d =
            ( x, y + 1 )

        l =
            ( x - 1, y )

        u =
            ( x, y - 1 )
    in
        [ r, d, l, u ]
            |> List.map (\loc -> Dict.get loc nodes)
            |> List.filterMap identity


type alias State =
    { current : Maybe Node
    , nodes : Dict Location Node
    , targets : List Char
    }


type alias Node =
    { x : Int
    , y : Int
    , v : Char
    , distance : Int
    }


type alias Location =
    ( Int, Int )


parse : String -> State
parse input =
    let
        parseYthRow y row =
            List.indexedMap (\x v -> Node x y v 0) row

        nodeList =
            input
                |> Regex.find Regex.All (Regex.regex "[#.0-9]+")
                |> List.map .match
                |> List.map String.toList
                |> List.indexedMap parseYthRow
                |> List.concat
                |> List.filter (\n -> n.v /= '#')

        nodes =
            nodeList
                |> List.filter (\n -> n.v /= '0')
                |> List.map toEntry
                |> Dict.fromList

        current =
            nodeList
                |> List.filter (\n -> n.v == '0')
                |> List.head

        targets =
            nodeList
                |> List.map .v
                |> List.filter (\v -> v > '0' && v <= '9')
                |> List.sort
    in
        State current nodes targets


toEntry : Node -> ( Location, Node )
toEntry node =
    ( ( node.x, node.y ), node )
