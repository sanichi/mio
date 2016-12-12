module Y15D16 exposing (answers)

import Dict exposing (Dict)
import Regex
import Util


answers : String -> String
answers input =
    let
        model =
            parseInput input

        p1 =
            sue match1 model

        p2 =
            sue match2 model
    in
        Util.join p1 p2


sue : (String -> Int -> Bool -> Bool) -> Model -> String
sue hit model =
    let
        sues =
            List.filter (\s -> Dict.foldl hit True s.props) model
    in
        case List.length sues of
            0 ->
                "none"

            1 ->
                List.map .number sues |> List.head |> Maybe.withDefault 0 |> toString

            _ ->
                "too many"


match1 : String -> Int -> Bool -> Bool
match1 prop val prevProp =
    if not prevProp then
        False
    else
        case prop of
            "akitas" ->
                val == 0

            "cars" ->
                val == 2

            "cats" ->
                val == 7

            "children" ->
                val == 3

            "goldfish" ->
                val == 5

            "perfumes" ->
                val == 1

            "pomeranians" ->
                val == 3

            "samoyeds" ->
                val == 2

            "trees" ->
                val == 3

            "vizslas" ->
                val == 0

            _ ->
                False


match2 : String -> Int -> Bool -> Bool
match2 prop val prevProp =
    if not prevProp then
        False
    else
        case prop of
            "akitas" ->
                val == 0

            "cars" ->
                val == 2

            "cats" ->
                val > 7

            "children" ->
                val == 3

            "goldfish" ->
                val < 5

            "perfumes" ->
                val == 1

            "pomeranians" ->
                val < 3

            "samoyeds" ->
                val == 2

            "trees" ->
                val > 3

            "vizslas" ->
                val == 0

            _ ->
                False


parseInput : String -> Model
parseInput input =
    String.split "\n" input
        |> List.filter (\l -> l /= "")
        |> List.foldl parseLine []


parseLine : String -> Model -> Model
parseLine line model =
    let
        cs =
            "(akitas|cars|cats|children|goldfish|perfumes|pomeranians|samoyeds|trees|vizslas): (\\d+)"

        rx =
            "Sue ([1-9]\\d*): " ++ (List.repeat 3 cs |> String.join ", ")

        ms =
            Regex.find (Regex.AtMost 1) (Regex.regex rx) line |> List.map .submatches
    in
        case ms of
            [ [ Just n, Just p1, Just n1, Just p2, Just n2, Just p3, Just n3 ] ] ->
                let
                    i =
                        parseInt n

                    d =
                        Dict.empty
                            |> Dict.insert p1 (parseInt n1)
                            |> Dict.insert p2 (parseInt n2)
                            |> Dict.insert p3 (parseInt n3)
                in
                    Sue i d :: model

            _ ->
                model


parseInt : String -> Int
parseInt s =
    String.toInt s |> Result.withDefault 0


type alias Model =
    List Sue


type alias Sue =
    { number : Int
    , props : Dict String Int
    }
