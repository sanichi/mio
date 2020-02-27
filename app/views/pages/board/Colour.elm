module Colour exposing (Colour(..), fromString, not)


type Colour
    = Black
    | White


not : Colour -> Colour
not colour =
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
