module Y21 exposing (answer)

import Y21D01


answer : Int -> Int -> String -> String
answer day part input =
    case day of
        1 ->
            Y21D01.answer part input

        _ ->
            "year 2021, day " ++ String.fromInt day ++ ": not available"
