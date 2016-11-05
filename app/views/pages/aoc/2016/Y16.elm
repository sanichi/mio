module Y16 exposing (..)

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


answers : Int -> String -> String
answers day input =
    case day of
        1 ->
            Y16D01.answers input

        2 ->
            Y16D02.answers input

        3 ->
            Y16D03.answers input

        4 ->
            Y16D04.answers input

        5 ->
            Y16D05.answers input

        6 ->
            Y16D06.answers input

        7 ->
            Y16D07.answers input

        8 ->
            Y16D08.answers input

        9 ->
            Y16D09.answers input

        10 ->
            Y16D10.answers input

        11 ->
            Y16D11.answers input

        12 ->
            Y16D12.answers input

        13 ->
            Y16D13.answers input

        14 ->
            Y16D14.answers input

        15 ->
            Y16D15.answers input

        16 ->
            Y16D16.answers input

        17 ->
            Y16D17.answers input

        18 ->
            Y16D18.answers input

        19 ->
            Y16D19.answers input

        20 ->
            Y16D20.answers input

        21 ->
            Y16D21.answers input

        22 ->
            Y16D22.answers input

        23 ->
            Y16D23.answers input

        24 ->
            Y16D24.answers input

        25 ->
            Y16D25.answer input

        _ ->
            "year 2016, day " ++ (toString day) ++ ": not available"
