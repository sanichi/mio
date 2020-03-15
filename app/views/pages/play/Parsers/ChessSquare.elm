module Parsers.ChessSquare exposing (parse, title)

import Parser exposing (..)
import Utils.Square exposing (Square, fromString)


title : String
title =
    "chess square"


parser : Parser (Maybe Square)
parser =
    succeed identity
        |= square
        |. end


square : Parser (Maybe Square)
square =
    map fromString <|
        succeed (++)
            |= file
            |= rank


file : Parser String
file =
    getChompedString <|
        chompIf (\c -> c == 'a' || c == 'b' || c == 'c' || c == 'd' || c == 'e' || c == 'f' || c == 'g' || c == 'h')


rank : Parser String
rank =
    getChompedString <|
        chompIf (\c -> c == '1' || c == '2' || c == '3' || c == '4' || c == '5' || c == '6' || c == '7' || c == '8')


parse : String -> String
parse input =
    case run parser input of
        Ok good ->
            Debug.toString good

        Err list ->
            Debug.toString list
