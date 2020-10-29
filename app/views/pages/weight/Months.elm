module Months exposing (Months, fromInt)


type alias Months =
    Int


fromInt : Int -> Months
fromInt m =
    if m < 0 then
        0

    else
        m
