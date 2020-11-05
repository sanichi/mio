module Start exposing (Start, fromInt)


type alias Start =
    Int


fromInt : Int -> Start
fromInt months =
    if months < 0 then
        0

    else
        months
