module Parsers.ListOfInts exposing (parse, title)

import Parser exposing (..)


title : String
title =
    "list of ints"


parser : Parser (List Int)
parser =
    succeed identity
        |. spaces
        |= oneOf
            [ succeed []
                |. end
            , succeed (::)
                |= int
                |. spaces
                |= lazy (\_ -> parser)
            ]



-- Doesn't works with "1 2 3" but not with " 1 2 3"; why not?
-- parser : Parser (List Int)
-- parser =
--     oneOf
--         [ succeed []
--             |. spaces
--             |. end
--         , succeed (::)
--             |. spaces
--             |= int
--             |. spaces
--             |= lazy (\_ -> parser)
--         ]


parse : String -> String
parse input =
    case run parser input of
        Ok good ->
            Debug.toString good

        Err list ->
            Debug.toString list
