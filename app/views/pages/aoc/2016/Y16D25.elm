module Y16D25 exposing (answer)

import Regex exposing (findAtMost)
import Util exposing (onlyOnePart, regex)


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> List.product
            |> (-) 2730
            |> String.fromInt

    else
        onlyOnePart


parse : String -> List Int
parse input =
    input
        |> findAtMost 2 (regex "cpy (\\d+) [abcd]")
        |> List.map .submatches
        |> List.map (List.map (Maybe.withDefault ""))
        |> List.map List.head
        |> List.map (Maybe.withDefault "")
        |> List.map String.toInt
        |> List.map (Maybe.withDefault 0)
