module Y16D09 exposing (answer)

import Regex


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
                |> toString
        else
            file
                |> decompressedLength
                |> toString


decompress : String -> String
decompress string =
    let
        ( caps, len, num, rest ) =
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
        ( caps, len, num, rest ) =
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


matches : String -> ( String, Int, Int, String )
matches string =
    let
        m =
            string
                |> Regex.find (Regex.AtMost 1) (Regex.regex "^([A-Z]*)\\((\\d+)x(\\d+)\\)(.+)$")
                |> List.map .submatches
                |> List.head
    in
        case m of
            Just [ Just c, Just l, Just n, Just r ] ->
                ( c, toInt l, toInt n, r )

            _ ->
                ( "", 0, 0, "" )


toInt : String -> Int
toInt string =
    string
        |> String.toInt
        |> Result.withDefault 0


parse : String -> String
parse input =
    Regex.replace Regex.All (Regex.regex "\\s") (\_ -> "") input
