module Y20 exposing (answer)

import Y20D01
import Y20D02
import Y20D03
import Y20D04


answer : Int -> Int -> String -> String
answer day part input =
    case day of
        1 ->
            Y20D01.answer part input

        2 ->
            Y20D02.answer part input

        3 ->
            Y20D03.answer part input

        4 ->
            Y20D04.answer part input

        _ ->
            "year 2020, day " ++ String.fromInt day ++ ": not available"
