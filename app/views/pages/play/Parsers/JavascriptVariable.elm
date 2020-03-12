module Parsers.JavascriptVariable exposing (parse)

import Parser as P exposing ((|.), (|=), Parser)


type alias Pair =
    ( Int, Int )


parser : Parser String
parser =
    P.getChompedString <|
        P.succeed ()
            |. P.chompIf isStartChar
            |. P.chompWhile isInnerChar


isStartChar : Char -> Bool
isStartChar char =
    Char.isAlpha char || char == '_' || char == '$'


isInnerChar : Char -> Bool
isInnerChar char =
    isStartChar char || Char.isDigit char


parse : String -> String
parse input =
    case P.run parser input of
        Ok good ->
            Debug.toString good

        Err list ->
            Debug.toString list
