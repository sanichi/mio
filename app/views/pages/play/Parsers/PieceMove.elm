module Parsers.PieceMove exposing (parse, title)

import Parser exposing (..)
import Utils.Utils exposing (positiveInt)


title : String
title =
    "piece move"


parser : Parser Move
parser =
    succeed Move
        |= number
        |= colour
        |= piece
        |= square


number : Parser Int
number =
    succeed identity
        |= positiveInt
        |. spaces


colour : Parser Colour
colour =
    succeed identity
        |. symbol "."
        |= oneOf
            [ map (\_ -> Black) (symbol "..")
            , succeed White
            ]
        |. spaces


piece : Parser Category
piece =
    map pieceFromString pieceString


pieceString : Parser String
pieceString =
    getChompedString <|
        chompIf (\c -> c == 'K' || c == 'Q' || c == 'R' || c == 'B' || c == 'N')


square : Parser String
square =
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


type Category
    = King
    | Queen
    | Rook
    | Bishop
    | Knight
    | Pawn


type Colour
    = Black
    | White


type alias Move =
    { number : Int
    , colour : Colour
    , category : Category
    , square : String
    }


pieceFromString : String -> Category
pieceFromString letter =
    case letter of
        "K" ->
            King

        "Q" ->
            Queen

        "R" ->
            Rook

        "B" ->
            Bishop

        "N" ->
            Knight

        _ ->
            Pawn
