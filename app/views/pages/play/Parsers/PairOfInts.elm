module Parsers.PairOfInts exposing (parse, title)

import Parser as P exposing ((|.), (|=), Parser)


title : String
title =
    "pair of ints"


type alias Pair =
    ( Int, Int )


parser : Parser Pair
parser =
    P.succeed Tuple.pair
        |. P.spaces
        |. P.symbol "("
        |. P.spaces
        |= P.int
        |. P.spaces
        |. P.symbol ","
        |. P.spaces
        |= P.int
        |. P.spaces
        |. P.symbol ")"
        |. P.spaces
        |. P.end


parse : String -> String
parse input =
    case P.run parser input of
        Ok good ->
            Debug.toString good

        Err list ->
            Debug.toString list
