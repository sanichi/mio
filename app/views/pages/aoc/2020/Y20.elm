module Y20 exposing (answer)

import Y20D01


answer : Int -> Int -> String -> String
answer day part input =
    case day of
        1 ->
            Y20D01.answer part input

        _ ->
            "year 2020, day " ++ String.fromInt day ++ ": not available"
