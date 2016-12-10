module Y16D10 exposing (answers)

import Dict exposing (Dict)
import Regex
import Util


answers : String -> String
answers input =
    let
        matches =
            parse input

        state =
            process matches init

        a1 =
            state
                |> Dict.toList
                |> lookfor "17-61"

        a2 =
            [ 0, 1, 2 ]
                |> multiply 1 state
                |> toString
    in
        Util.join a1 a2


lookfor : String -> List ( String, List Int ) -> String
lookfor match idLists =
    case idLists of
        [] ->
            "none"

        ( id, list ) :: rest ->
            if String.join "-" (List.map toString list) == match && String.startsWith "bot " id then
                id
            else
                lookfor match rest


multiply : Int -> State -> List Int -> Int
multiply num state ids =
    case ids of
        [] ->
            num

        id :: rest ->
            let
                output =
                    id
                        |> toString
                        |> (++) "output "

                chips =
                    state
                        |> Dict.get output
                        |> Maybe.withDefault []
            in
                let
                    newNum =
                        chips
                            |> List.product
                            |> (*) num
                in
                    multiply newNum state rest


type alias Instruction =
    List (Maybe String)


type alias State =
    Dict String (List Int)


init : State
init =
    Dict.empty


process : List Instruction -> State -> State
process matches state =
    case matches of
        [] ->
            state

        match :: rest ->
            case match of
                [ Just bot, Just lowTarget, Just highTarget, Nothing, Nothing ] ->
                    let
                        chips =
                            state
                                |> Dict.get bot
                                |> Maybe.withDefault []

                        newState =
                            case chips of
                                [ low, high ] ->
                                    let
                                        lowChips =
                                            state
                                                |> Dict.get lowTarget
                                                |> Maybe.withDefault []

                                        highChips =
                                            state
                                                |> Dict.get highTarget
                                                |> Maybe.withDefault []
                                    in
                                        state
                                            |> Dict.insert lowTarget (List.sort (low :: lowChips))
                                            |> Dict.insert highTarget (List.sort (high :: highChips))

                                _ ->
                                    state

                        newMatches =
                            case chips of
                                [ low, high ] ->
                                    rest

                                _ ->
                                    rest
                                        |> List.reverse
                                        |> (::) match
                                        |> List.reverse
                    in
                        process newMatches newState

                [ Nothing, Nothing, Nothing, Just value, Just target ] ->
                    let
                        chips =
                            state
                                |> Dict.get target
                                |> Maybe.withDefault []

                        newChips =
                            value
                                |> toInt
                                |> (\i -> i :: chips)
                                |> List.sort

                        newState =
                            state
                                |> Dict.insert target newChips
                    in
                        process rest newState

                _ ->
                    process rest state


parse : String -> List Instruction
parse input =
    let
        highLow =
            "(bot \\d+) gives low to ((?:bot|output) \\d+) and high to ((?:bot|output) \\d+)"

        specific =
            "value (\\d+) goes to ((?:bot|output) \\d+)"

        pattern =
            highLow ++ "|" ++ specific
    in
        input
            |> Regex.find Regex.All (Regex.regex pattern)
            |> List.map .submatches


toInt : String -> Int
toInt s =
    String.toInt s |> Result.withDefault 0
