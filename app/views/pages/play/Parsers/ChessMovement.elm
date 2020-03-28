module Parsers.ChessMovement exposing (parse, title)

import Parser exposing (..)
import Utils.Utils exposing (detect)


title : String
title =
    "piece movement"


parser : Parser Movement
parser =
    oneOf
        [ backtrackable ambiguousSquare
        , backtrackable ambiguousFile
        , ambiguousRank
        , unambiguous
        ]


ambiguousSquare : Parser Movement
ambiguousSquare =
    succeed Movement
        |= map Just file
        |= map Just rank
        |= square
        |. end


ambiguousFile : Parser Movement
ambiguousFile =
    succeed Movement
        |= map Just file
        |= succeed Nothing
        |= square
        |. end


ambiguousRank : Parser Movement
ambiguousRank =
    succeed (Movement Nothing)
        |= map Just rank
        |= square
        |. end


unambiguous : Parser Movement
unambiguous =
    succeed (Movement Nothing Nothing)
        |= square
        |. end


square : Parser Square
square =
    succeed Tuple.pair
        |= file
        |= rank


file : Parser File
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


rank : Parser Rank
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


parse : String -> String
parse input =
    case run parser input of
        Ok good ->
            Debug.toString good

        Err list ->
            Debug.toString list


type alias File =
    Int


type alias Rank =
    Int


type alias Square =
    ( File, Rank )


type alias Movement =
    { file : Maybe File
    , rank : Maybe Rank
    , square : Square
    }
