module Y20 exposing (answer)

import Y20D01
import Y20D02
import Y20D03
import Y20D04
import Y20D05
import Y20D06
import Y20D07
import Y20D08
import Y20D09
import Y20D10
import Y20D11
import Y20D12
import Y20D13
import Y20D14
import Y20D15
import Y20D16
import Y20D17
import Y20D18
import Y20D19
import Y20D20
import Y20D21
import Y20D22
import Y20D23
import Y20D24


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

        5 ->
            Y20D05.answer part input

        6 ->
            Y20D06.answer part input

        7 ->
            Y20D07.answer part input

        8 ->
            Y20D08.answer part input

        9 ->
            Y20D09.answer part input

        10 ->
            Y20D10.answer part input

        11 ->
            Y20D11.answer part input

        12 ->
            Y20D12.answer part input

        13 ->
            Y20D13.answer part input

        14 ->
            Y20D14.answer part input

        15 ->
            Y20D15.answer part input

        16 ->
            Y20D16.answer part input

        17 ->
            Y20D17.answer part input

        18 ->
            Y20D18.answer part input

        19 ->
            Y20D19.answer part input

        20 ->
            Y20D20.answer part input

        21 ->
            Y20D21.answer part input

        22 ->
            Y20D22.answer part input

        23 ->
            Y20D23.answer part input

        24 ->
            Y20D24.answer part input

        _ ->
            "year 2020, day " ++ String.fromInt day ++ ": not available"
