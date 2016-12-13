module Y16 exposing (answer)

import Y16D01
import Y16D02
import Y16D03
import Y16D04
import Y16D05
import Y16D06
import Y16D07
import Y16D08
import Y16D09
import Y16D10
import Y16D11
import Y16D12
import Y16D13
import Y16D14
import Y16D15
import Y16D16
import Y16D17
import Y16D18
import Y16D19
import Y16D20
import Y16D21
import Y16D22
import Y16D23
import Y16D24
import Y16D25


answer : Int -> Int -> String -> String
answer day part input =
    case day of
        1 ->
            Y16D01.answer part input

        2 ->
            Y16D02.answer part input

        3 ->
            Y16D03.answer part input

        4 ->
            Y16D04.answer part input

        5 ->
            Y16D05.answer part input

        6 ->
            Y16D06.answer part input

        7 ->
            Y16D07.answer part input

        8 ->
            Y16D08.answer part input

        9 ->
            Y16D09.answer part input

        10 ->
            Y16D10.answer part input

        11 ->
            Y16D11.answer part input

        12 ->
            Y16D12.answer part input

        13 ->
            Y16D13.answer part input

        14 ->
            Y16D14.answer part input

        15 ->
            Y16D15.answer part input

        16 ->
            Y16D16.answer part input

        17 ->
            Y16D17.answer part input

        18 ->
            Y16D18.answer part input

        19 ->
            Y16D19.answer part input

        20 ->
            Y16D20.answer part input

        21 ->
            Y16D21.answer part input

        22 ->
            Y16D22.answer part input

        23 ->
            Y16D23.answer part input

        24 ->
            Y16D24.answer part input

        25 ->
            Y16D25.answer part input

        _ ->
            "year 2016, day " ++ (toString day) ++ ": not available"
