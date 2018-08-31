module Y15D12 exposing (answer)

import Regex
import Util exposing (failed, regex)


answer : Int -> String -> String
answer part input =
    if part == 1 then
        count input

    else
        failed


count : String -> String
count json =
    Regex.find (regex "-?[1-9]\\d*") json
        |> List.map .match
        |> List.map String.toInt
        |> List.map (Maybe.withDefault 0)
        |> List.sum
        |> String.fromInt
