module Parsers.RankAndFile exposing (parse, title)

import Parser exposing (..)


title : String
title =
    "rank and file"


parser : Parser String
parser =
    oneOf
        [ succeed (++)
            |= rank
            |= file
            |. end
        , succeed (++)
            |= file
            |= rank
            |. end
        ]


rank : Parser String
rank =
    getChompedString <|
        chompIf (\c -> c == 'a' || c == 'b' || c == 'c' || c == 'd' || c == 'e' || c == 'f' || c == 'g' || c == 'h')


file : Parser String
file =
    getChompedString <|
        chompIf (\c -> c == '1' || c == '2' || c == '3' || c == '4' || c == '5' || c == '6' || c == '7' || c == '8')


parse : String -> String
parse input =
    case run parser input of
        Ok good ->
            Debug.toString good

        Err list ->
            Debug.toString list
