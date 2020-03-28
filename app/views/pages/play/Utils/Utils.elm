module Utils.Utils exposing (detect, positiveInt, ternary)

import Parser exposing (..)


positiveInt : Parser Int
positiveInt =
    let
        str =
            getChompedString <|
                succeed ()
                    |. chompIf (\c -> c /= '0' && Char.isDigit c)
                    |. chompWhile (\c -> Char.isDigit c)

        may =
            map String.toInt str
    in
    map
        (\may_ ->
            case may_ of
                Just int ->
                    int

                Nothing ->
                    0
        )
        may


detect : Char -> a -> Parser a
detect chr a =
    map (\_ -> a) (chompIf (\c -> c == chr))


ternary : Bool -> a -> a -> a
ternary c a b =
    if c then
        a

    else
        b
