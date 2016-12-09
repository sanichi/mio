module Y16D09 exposing (answers)

import Regex
import Util


answers : String -> String
answers input =
    let
        file =
            parse input

        a1 =
            file
                |> decompress
                |> String.length
                |> toString

        a2 =
            file
                |> decompressedLength
                |> toString
    in
        Util.join a1 a2


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
