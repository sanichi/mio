module Y17 exposing (answer)

import Y17D01
import Y17D02


answer : Int -> Int -> String -> String
answer day part input =
    case day of
        1 ->
            Y17D01.answer part input

        2 ->
            Y17D02.answer part input

        _ ->
            "year 2017, day " ++ (toString day) ++ ": not available"
