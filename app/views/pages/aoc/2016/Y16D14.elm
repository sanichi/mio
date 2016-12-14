module Y16D14 exposing (answer)

import Regex


answer : Int -> String -> String
answer part input =
    let
        salt =
            parse input
    in
        if part == 1 then
            salt
        else
            salt


parse : String -> String
parse input =
    input
        |> Regex.find (Regex.AtMost 1) (Regex.regex "[a-z]+")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault ""
