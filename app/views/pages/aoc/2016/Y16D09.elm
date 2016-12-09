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
                |> decompress
                |> String.length
                |> toString
    in
        Util.join a1 a2


decompress : String -> String
decompress file =
    let
        matches =
            file
                |> Regex.find (Regex.AtMost 1) (Regex.regex "^([A-Z]*)\\((\\d+)x(\\d+)\\)(.+)$")
                |> List.map .submatches
                |> List.head

        ( caps, len, num, rest ) =
            case matches of
                Just [ Just cp, Just ln, Just nm, Just rt ] ->
                    ( cp, toInt ln, toInt nm, rt )

                _ ->
                    ( "", 0, 0, "" )
    in
        if rest == "" then
            file
        else
            caps ++ (String.left len rest |> String.repeat num) ++ (String.dropLeft len rest |> decompress)


toInt : String -> Int
toInt string =
    string
        |> String.toInt
        |> Result.withDefault 0


parse : String -> String
parse input =
    Regex.replace Regex.All (Regex.regex "\\s") (\_ -> "") input
