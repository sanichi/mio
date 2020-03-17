module Utils.Utils exposing (positiveInt)

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
