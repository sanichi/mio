module Colour exposing (Colour(..), flip, fromString)


type Colour
    = Black
    | White


flip : Colour -> Colour
flip colour =
    if colour == White then
        Black

    else
        White


fromString : String -> Colour
fromString str =
    let
        low =
            String.toLower str
    in
    if low == "black" || low == "b" then
        Black

    else
        White
