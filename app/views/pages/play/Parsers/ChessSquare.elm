module Parsers.ChessSquare exposing (parse, title)

import Parser exposing (..)


title : String
title =
    "chess square"


parser : Parser Square
parser =
    succeed identity
        |= square
        |. end


square : Parser Square
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


type alias Square =
    { file : Int
    , rank : Int
    }


fromString : String -> Square
fromString str =
    case String.toList str of
        f :: (r :: []) ->
            Square (Char.toCode f - 96) (Char.toCode r - 48)

        _ ->
            Square 0 0
