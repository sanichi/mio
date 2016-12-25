module Y16D25 exposing (answer)

import Regex
import Util


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> List.product
            |> (-) 2730
            |> toString
    else
        Util.onlyOnePart


parse : String -> List Int
parse input =
    input
        |> Regex.find (Regex.AtMost 2) (Regex.regex "cpy (\\d+) [abcd]")
        |> List.map .submatches
        |> List.map (List.map (Maybe.withDefault ""))
        |> List.map List.head
        |> List.map (Maybe.withDefault "")
        |> List.map String.toInt
        |> List.map (Result.withDefault 0)
