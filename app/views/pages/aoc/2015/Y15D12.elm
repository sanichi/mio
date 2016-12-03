module Y15D12 exposing (..)

import Regex
import Util exposing (join)


answers : String -> String
answers input =
    let
        p1 =
            count input

        p2 =
            "no red filter"
    in
        join p1 p2


count : String -> String
count json =
    Regex.find Regex.All (Regex.regex "-?[1-9]\\d*") json
        |> List.map .match
        |> List.map String.toInt
        |> List.map (Result.withDefault 0)
        |> List.sum
        |> toString
