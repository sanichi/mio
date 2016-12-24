module Y16D24 exposing (answer)

import Dict exposing (Dict)
import Regex


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> .targets
            |> toString
    else
        input
            |> parse
            |> .nodes
            |> Dict.toList
            |> List.head
            |> toString


type alias State =
    { current : Location
    , nodes : Dict Location Node
    , targets : Int
    }


type alias Node =
    { x : Int
    , y : Int
    , v : Char
    , target : Bool
    , visited : Bool
    , distance : Int
    , targetsSeen : Int
    }


type alias Location =
    ( Int, Int )


parse : String -> State
parse input =
    input
        |> Regex.find Regex.All (Regex.regex "[#.0-9]+")
        |> List.map .match
        |> List.map String.toList
        |> List.indexedMap parseRow
        |> List.concat
        |> List.filter (\n -> n.v /= '#')
        |> toState


parseRow : Int -> List Char -> List Node
parseRow y chars =
    List.indexedMap (\x v -> toNode x y v) chars


toNode : Int -> Int -> Char -> Node
toNode x y v =
    let
        target =
            v >= '1' && v <= '9'

        visited =
            v == '0'
    in
        Node x y v target visited 0 0


toState : List Node -> State
toState list =
    let
        nodes =
            list
                |> List.map (\n -> ( ( n.x, n.y ), n ))
                |> Dict.fromList

        current =
            list
                |> List.filter (\n -> n.v == '0')
                |> List.map (\n -> ( n.x, n.y ))
                |> List.head
                |> Maybe.withDefault ( 1, 1 )

        targets =
            list
                |> List.filter (\n -> n.v /= '0' && n.v /= '.')
                |> List.length
    in
        State current nodes targets
