module Y15D12 exposing (answers)

import Regex
import Util


answers : String -> String
answers input =
    let
        p1 =
            count input

        p2 =
            "couldn't do the second part in Elm"
    in
        Util.join p1 p2


count : String -> String
count json =
    Regex.find Regex.All (Regex.regex "-?[1-9]\\d*") json
        |> List.map .match
        |> List.map String.toInt
        |> List.map (Result.withDefault 0)
        |> List.sum
        |> toString
