module Y16D09 exposing (answer)

import Regex exposing (findAtMost, replace)
import Util exposing (regex)


answer : Int -> String -> String
answer part input =
    let
        file =
            parse input
    in
    if part == 1 then
        file
            |> decompress
            |> String.length
            |> String.fromInt

    else
        file
            |> decompressedLength
            |> String.fromInt


decompress : String -> String
decompress string =
    let
        ( ( caps, rest ), ( len, num ) ) =
            matches string
    in
    if rest == "" then
        string

    else
        let
            p1 =
                caps

            p2 =
                rest
                    |> String.left len
                    |> String.repeat num

            p3 =
                rest
                    |> String.dropLeft len
                    |> decompress
        in
        p1 ++ p2 ++ p3


decompressedLength : String -> Int
decompressedLength string =
    let
        ( ( caps, rest ), ( len, num ) ) =
            matches string
    in
    if rest == "" then
        String.length string

    else
        let
            p1 =
                String.length caps

            p2 =
                rest
                    |> String.left len
                    |> String.repeat num
                    |> decompressedLength

            p3 =
                rest
                    |> String.dropLeft len
                    |> decompressedLength
        in
        p1 + p2 + p3


matches : String -> ( ( String, String ), ( Int, Int ) )
matches string =
    let
        m =
            string
                |> findAtMost 1 (regex "^([A-Z]*)\\((\\d+)x(\\d+)\\)(.+)$")
                |> List.map .submatches
                |> List.head
    in
    case m of
        Just [ Just c, Just l, Just n, Just r ] ->
            ( ( c, r ), ( toInt l, toInt n ) )

        _ ->
            ( ( "", "" ), ( 0, 0 ) )


toInt : String -> Int
toInt string =
    string
        |> String.toInt
        |> Maybe.withDefault 0


parse : String -> String
parse input =
    replace (regex "\\s") (\_ -> "") input
