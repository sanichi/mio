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
        |= capture
        |= square
        |= check
        |. spaces
        |. end


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
    oneOf
        [ detect 'K' King
        , detect 'Q' Queen
        , detect 'R' Rook
        , detect 'B' Bishop
        , detect 'N' Knight
        ]


capture : Parser Bool
capture =
    oneOf
        [ detect 'x' True
        , succeed False
        ]


square : Parser ( Int, Int )
square =
    succeed Tuple.pair
        |= file
        |= rank


check : Parser (Maybe Check)
check =
    oneOf
        [ detect '+' (Just Check)
        , detect '#' (Just Mate)
        , succeed Nothing
        ]


file : Parser Int
file =
    oneOf
        [ detect 'a' 1
        , detect 'b' 2
        , detect 'c' 3
        , detect 'd' 4
        , detect 'e' 5
        , detect 'f' 6
        , detect 'g' 7
        , detect 'h' 8
        ]


rank : Parser Int
rank =
    oneOf
        [ detect '1' 1
        , detect '2' 2
        , detect '3' 3
        , detect '4' 4
        , detect '5' 5
        , detect '6' 6
        , detect '7' 7
        , detect '8' 8
        ]


detect : Char -> a -> Parser a
detect chr a =
    map (\_ -> a) (chompIf (\c -> c == chr))


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


type Check
    = Check
    | Mate


type alias Move =
    { number : Int
    , colour : Colour
    , category : Category
    , capture : Bool
    , square : ( Int, Int )
    , check : Maybe Check
    }
