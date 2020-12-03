module Y20D01 exposing (answer)

import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        expenses =
            parse input
    in
    if part == 1 then
        expenses
            |> Util.combinations 2
            |> search

    else
        expenses
            |> Util.combinations 3
            |> search


search : List (List Int) -> String
search combos =
    case combos of
        numbers :: rest ->
            if List.sum numbers == 2020 then
                numbers
                    |> List.product
                    |> String.fromInt

            else
                search rest

        _ ->
            "none found"


parse : String -> List Int
parse input =
    input
        |> Regex.find (Util.regex "\\d+")
        |> List.map .match
        |> List.filterMap String.toInt


example : String
example =
    "1721 979 366 299 675 1456"
