module Y15 exposing (answer)

import Y15D01
import Y15D02
import Y15D03
import Y15D04
import Y15D05
import Y15D06
import Y15D07
import Y15D08
import Y15D09
import Y15D10
import Y15D11
import Y15D12
import Y15D13
import Y15D14
import Y15D15
import Y15D16
import Y15D17
import Y15D18
import Y15D19
import Y15D20
import Y15D21
import Y15D22
import Y15D23
import Y15D24
import Y15D25


answer : Int -> Int -> String -> String
answer day part input =
    case day of
        1 ->
            Y15D01.answer part input

        2 ->
            Y15D02.answer part input

        3 ->
            Y15D03.answer part input

        4 ->
            Y15D04.answer part input

        5 ->
            Y15D05.answer part input

        6 ->
            Y15D06.answer part input

        7 ->
            Y15D07.answer part input

        8 ->
            Y15D08.answer part input

        9 ->
            Y15D09.answer part input

        10 ->
            Y15D10.answer part input

        11 ->
            Y15D11.answer part input

        12 ->
            Y15D12.answer part input

        13 ->
            Y15D13.answer part input

        14 ->
            Y15D14.answer part input

        15 ->
            Y15D15.answer part input

        16 ->
            Y15D16.answer part input

        17 ->
            Y15D17.answer part input

        18 ->
            Y15D18.answer part input

        19 ->
            Y15D19.answer part input

        20 ->
            Y15D20.answer part input

        21 ->
            Y15D21.answer part input

        22 ->
            Y15D22.answer part input

        23 ->
            Y15D23.answer part input

        24 ->
            Y15D24.answer part input

        25 ->
            Y15D25.answer part input

        _ ->
            "year 2015, day " ++ (toString day) ++ ": not available"
