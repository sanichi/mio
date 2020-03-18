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
    let
        detect chr cat =
            map (\_ -> cat) (chompIf (\c -> c == chr))
    in
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
        [ map (\_ -> True) (chompIf (\c -> c == 'x'))
        , succeed False
        ]


square : Parser ( Int, Int )
square =
    succeed Tuple.pair
        |= file
        |= rank


file : Parser Int
file =
    let
        detect chr int =
            map (\_ -> int) (chompIf (\c -> c == chr))
    in
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
    let
        detect chr int =
            map (\_ -> int) (chompIf (\c -> c == chr))
    in
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
    , capture : Bool
    , square : ( Int, Int )
    }
