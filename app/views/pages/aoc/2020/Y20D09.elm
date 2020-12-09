module Y20D09 exposing (answer)

import Regex
import Set
import Util


answer : Int -> String -> String
answer part input =
    let
        numbers =
            parse input

        first =
            numbers
                |> findFirst 25 []
                |> Maybe.withDefault 0
    in
    if part == 1 then
        String.fromInt first

    else
        numbers
            |> findSum first 2
            |> Maybe.withDefault 0
            |> String.fromInt


findFirst : Int -> List Int -> List Int -> Maybe Int
findFirst len preamble numbers =
    case numbers of
        num :: rest ->
            if List.length preamble < len then
                findFirst len (num :: preamble) rest

            else if valid num preamble then
                let
                    preamble_ =
                        preamble
                            |> List.reverse
                            |> List.drop 1
                            |> List.reverse
                in
                findFirst len (num :: preamble_) rest

            else
                Just num

        _ ->
            Nothing


valid : Int -> List Int -> Bool
valid num preamble =
    preamble
        |> Util.combinations 2
        |> List.map Set.fromList
        |> List.filter (\s -> Set.size s == 2)
        |> List.map Set.toList
        |> List.map List.sum
        |> List.member num


findSum : Int -> Int -> List Int -> Maybe Int
findSum target len numbers =
    if List.length numbers < len then
        Nothing

    else
        case numbers of
            num :: rest ->
                let
                    chunk =
                        List.take len numbers

                    total =
                        List.sum chunk
                in
                if total < target then
                    findSum target (len + 1) numbers

                else if total > target then
                    if len > 2 then
                        findSum target (len - 1) rest

                    else
                        findSum target 2 rest

                else
                    let
                        min =
                            chunk
                                |> List.minimum
                                |> Maybe.withDefault 0

                        max =
                            chunk
                                |> List.maximum
                                |> Maybe.withDefault 0
                    in
                    Just (min + max)

            _ ->
                Nothing


parse : String -> List Int
parse input =
    input
        |> Regex.find (Util.regex "[1-9]\\d*")
        |> List.map .match
        |> List.filterMap String.toInt


example : String
example =
    """
        35
        20
        15
        25
        47
        40
        62
        55
        65
        95
        102
        117
        150
        182
        127
        219
        299
        277
        309
        576
    """
