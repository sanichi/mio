module Y16D16 exposing (answer)

import Regex


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> generateAndChecksum 272
    else
        input
            |> parse
            |> generateAndChecksum 35651584


generateAndChecksum : Int -> String -> String
generateAndChecksum len init =
    init
        |> generate len
        |> checksum len


generate : Int -> String -> String
generate len data =
    if String.length data >= len then
        data
    else
        let
            copy =
                data
                    |> String.reverse
                    |> String.toList
                    |> List.map swap
                    |> String.fromList

            newData =
                data
                    ++ "0"
                    ++ copy
        in
            generate len newData


checksum : Int -> String -> String
checksum len data =
    checksum_ (String.left len data)


checksum_ : String -> String
checksum_ data =
    if (String.length data) % 2 == 1 then
        data
    else
        data
            |> Regex.find Regex.All (Regex.regex "..")
            |> List.map .match
            |> List.map twoToOne
            |> String.concat
            |> checksum_


swap : Char -> Char
swap c =
    if c == '0' then
        '1'
    else
        '0'


twoToOne : String -> String
twoToOne pair =
    case pair of
        "11" ->
            "1"

        "00" ->
            "1"

        "10" ->
            "0"

        _ ->
            "0"


parse : String -> String
parse input =
    input
        |> Regex.find (Regex.AtMost 1) (Regex.regex "[01]+")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault ""
