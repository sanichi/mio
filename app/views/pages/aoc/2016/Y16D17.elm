module Y16D17 exposing (answer)

import MD5
import Regex


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
    else
        input
            |> parse


parse : String -> String
parse input =
    input
        |> Regex.find (Regex.AtMost 1) (Regex.regex "\\S+")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault ""
