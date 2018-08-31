module Y16D24 exposing (answer)

import Dict exposing (Dict)
import Regex exposing (find)
import Util exposing (combinations, permutations, regex)


answer : Int -> String -> String
answer part input =
    let
        state =
            parse input

        costs =
            getDistances state

        paths =
            state.targets
                |> Util.permutations
                |> List.map ((::) '0')
    in
    if part == 1 then
        paths
            |> List.map (pathCost costs 0)
            |> List.minimum
            |> Maybe.withDefault 0
            |> String.fromInt

    else
        paths
            |> List.map (\path -> path ++ [ '0' ])
            |> List.map (pathCost costs 0)
            |> List.minimum
            |> Maybe.withDefault 0
            |> String.fromInt


pathCost : Costs -> Int -> Path -> Int
pathCost costs cst path =
    case path of
        [] ->
            cst

        [ _ ] ->
            cst

        v1 :: v2 :: rest ->
            let
                newCost =
                    costs
                        |> Dict.get ( v1, v2 )
                        |> Maybe.withDefault 0
                        |> (+) cst
            in
            pathCost costs newCost (v2 :: rest)


getDistances : State -> Costs
getDistances state =
    let
        toPair list =
            case list of
                [ v1, v2 ] ->
                    ( v1, v2 )

                _ ->
                    ( '_', '_' )

        pairs =
            '0'
                :: state.targets
                |> Util.combinations 2
                |> List.map toPair
    in
    getDistances_ pairs state Dict.empty


getDistances_ : List Pair -> State -> Costs -> Costs
getDistances_ pairs state distances =
    case pairs of
        [] ->
            distances

        pair :: rest ->
            let
                newCost =
                    cost pair state

                newDistances =
                    distances
                        |> Dict.insert pair newCost
                        |> Dict.insert (swap pair) newCost
            in
            getDistances_ rest state newDistances


cost : Pair -> State -> Int
cost ( source, target ) state =
    if source == target then
        0

    else
        let
            newCurrent =
                state
                    |> .nodes
                    |> Dict.values
                    |> List.filter (\n -> n.v == source)
                    |> List.head

            newNodes =
                case newCurrent of
                    Just node ->
                        Dict.remove ( node.x, node.y ) state.nodes

                    Nothing ->
                        state.nodes

            newState =
                { state | current = newCurrent, nodes = newNodes }
        in
        cost_ target newState


cost_ : Char -> State -> Int
cost_ target state =
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
                    cost_ target newState


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


type alias Pair =
    ( Char, Char )


type alias Costs =
    Dict Pair Int


type alias Path =
    List Char


parse : String -> State
parse input =
    let
        parseYthRow y row =
            List.indexedMap (\x v -> Node x y v 0) row

        nodeList =
            input
                |> find (regex "[#.0-9]+")
                |> List.map .match
                |> List.map String.toList
                |> List.indexedMap parseYthRow
                |> List.concat
                |> List.filter (\n -> n.v /= '#')

        nodes =
            nodeList
                |> List.map toEntry
                |> Dict.fromList

        current =
            Nothing

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


swap : Pair -> Pair
swap ( v1, v2 ) =
    ( v2, v1 )
