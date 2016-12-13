module Y16D13 exposing (answer)

import Regex


answer : Int -> String -> String
answer part input =
    let
        number =
            parse input
    in
        if part == 1 then
            toString number
        else
            "TODO"


parse : String -> Int
parse input =
    input
        |> Regex.find (Regex.AtMost 1) (Regex.regex "[1-9]\\d*")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault ""
        |> String.toInt
        |> Result.withDefault 0
