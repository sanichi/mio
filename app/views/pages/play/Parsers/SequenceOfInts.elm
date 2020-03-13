module Parsers.SequenceOfInts exposing (parse, title)

import Parser exposing (..)


title : String
title =
    "sequence of ints"



{- Here the errors come too late. E.g. "1 3 4" ->
   - [{ col = 6, problem = Problem "consecutive numbers should be in sequence", row = 1 }]
-}


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
                |> andThen checkList
            ]


checkList : List Int -> Parser (List Int)
checkList list =
    case list of
        [] ->
            succeed list

        [ a ] ->
            succeed list

        a :: b :: c ->
            if a + 1 == b then
                succeed list

            else
                problem "consecutive numbers should be in sequence"


parse : String -> String
parse input =
    case run parser input of
        Ok good ->
            Debug.toString good

        Err list ->
            Debug.toString list
