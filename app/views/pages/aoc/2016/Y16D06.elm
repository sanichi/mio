module Y16D06 exposing (answers)

import Array exposing (Array)
import Dict exposing (Dict)
import Regex
import Util


answers : String -> String
answers input =
    let
        messages =
            parse input

        a1 =
            decrypt messages Most

        a2 =
            decrypt messages Least
    in
        Util.join a1 a2


type Frequency
    = Most
    | Least


decrypt : List String -> Frequency -> String
decrypt messages frequency =
    let
        width =
            messages
                |> List.head
                |> Maybe.withDefault ""
                |> String.length

        dicts =
            Array.repeat width Dict.empty
    in
        decrypt_ messages frequency dicts


decrypt_ : List String -> Frequency -> Array (Dict Char Int) -> String
decrypt_ messages frequency dicts =
    case messages of
        [] ->
            dicts
                |> Array.toList
                |> List.map (pick frequency)
                |> String.join ""

        message :: rest ->
            let
                newDicts =
                    addToDicts message 0 dicts
            in
                decrypt_ rest frequency newDicts


pick : Frequency -> Dict Char Int -> String
pick frequency dict =
    dict
        |> Dict.toList
        |> List.sortBy Tuple.second
        |> choose frequency
        |> List.head
        |> Maybe.withDefault ( '-', 0 )
        |> Tuple.first
        |> String.fromChar


choose : Frequency -> List ( Char, Int ) -> List ( Char, Int )
choose frequency sortedList =
    case frequency of
        Most ->
            List.reverse sortedList

        Least ->
            sortedList


addToDicts : String -> Int -> Array (Dict Char Int) -> Array (Dict Char Int)
addToDicts message index dicts =
    if message == "" then
        dicts
    else
        let
            ( char, rest ) =
                String.uncons message |> Maybe.withDefault ( '-', "" )

            maybeDict =
                Array.get index dicts

            newDicts =
                case maybeDict of
                    Nothing ->
                        dicts

                    Just dict ->
                        let
                            newDict =
                                case Dict.get char dict of
                                    Nothing ->
                                        Dict.insert char 1 dict

                                    Just n ->
                                        Dict.insert char (n + 1) dict
                        in
                            Array.set index newDict dicts
        in
            addToDicts rest (index + 1) newDicts


parse : String -> List String
parse input =
    Regex.find Regex.All (Regex.regex "[a-z]+") input |> List.map .match
