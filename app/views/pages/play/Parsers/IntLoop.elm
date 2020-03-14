module Parsers.IntLoop exposing (parse, title)

import Parser exposing (..)


title : String
title =
    "list of space separated ints"


parser : Parser (List Int)
parser =
    loop [] helper


helper : List Int -> Parser (Step (List Int) (List Int))
helper revInts =
    oneOf
        [ succeed (\int -> Loop (int :: revInts))
            |. spaces
            |= (int |> andThen (check revInts))
            |. spaces
        , succeed ()
            |> map (\_ -> Done (List.reverse revInts))
        ]


check : List Int -> Int -> Parser Int
check prev next =
    case prev of
        [] ->
            succeed next

        last :: rest ->
            if next == last + 1 then
                succeed next

            else
                problem ("I expected " ++ String.fromInt (last + 1) ++ " but got " ++ String.fromInt next)


parse : String -> String
parse input =
    case run parser input of
        Ok good ->
            Debug.toString good

        Err list ->
            Debug.toString list
