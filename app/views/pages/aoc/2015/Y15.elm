module Y15 where

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

answers : Int -> String -> String
answers day input =
  case day of
    1  -> Y15D01.answers input
    2  -> Y15D02.answers input
    3  -> Y15D03.answers input
    4  -> Y15D04.answers input
    5  -> Y15D05.answers input
    6  -> Y15D06.answers input
    7  -> Y15D07.answers input
    8  -> Y15D08.answers input
    9  -> Y15D09.answers input
    10 -> Y15D10.answers input
    11 -> Y15D11.answers input
    12 -> Y15D12.answers input
    13 -> Y15D13.answers input
    14 -> Y15D14.answers input
    15 -> Y15D15.answers input
    16 -> Y15D16.answers input
    17 -> Y15D17.answers input
    18 -> Y15D18.answers input
    19 -> Y15D19.answers input
    20 -> Y15D20.answers input
    21 -> Y15D21.answers input
    22 -> Y15D22.answers input
    23 -> Y15D23.answers input
    24 -> Y15D24.answers input
    25 -> Y15D25.answer  input
    _ -> "year 2015, day " ++ (toString day) ++ ": not implemented yet"
