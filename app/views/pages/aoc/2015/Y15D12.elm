module Y15D12 exposing (answer)

import Regex
import Util


answer : Int -> String -> String
answer part input =
    if part == 1 then
        count input
    else
        Util.failed


count : String -> String
count json =
    Regex.find Regex.All (Regex.regex "-?[1-9]\\d*") json
        |> List.map .match
        |> List.map String.toInt
        |> List.map (Result.withDefault 0)
        |> List.sum
        |> toString
