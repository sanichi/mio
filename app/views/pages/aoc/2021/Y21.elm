module Y21 exposing (answer)

import Y21D01
import Y21D02


answer : Int -> Int -> String -> String
answer day part input =
    case day of
        1 ->
            Y21D01.answer part input

        2 ->
            Y21D02.answer part input

        _ ->
            "year 2021, day " ++ String.fromInt day ++ ": not available"
