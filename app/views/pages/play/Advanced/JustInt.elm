module Advanced.JustInt exposing (parse, title)

import Parser.Advanced exposing (..)


title : String
title =
    "advanced int"


type Context
    = Start
    | Middle
    | Finish


type Problem
    = ExpectingInt
    | InvalidInt
    | EndOfInput


parser : Parser Context Problem Int
parser =
    succeed identity
        |. inContext Start spaces
        |= inContext Middle (int ExpectingInt InvalidInt)
        |. inContext Finish (end EndOfInput)


parse : String -> String
parse input =
    case run parser input of
        Ok good ->
            Debug.toString good

        Err list ->
            Debug.toString list
