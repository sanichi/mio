module Parsers.PawnLoop exposing (parse, title)

import Parser exposing (..)
import Utils.Utils exposing (positiveInt, ternary)


title : String
title =
    "list of numbered pawn moves"


parser : Parser Moves
parser =
    loop initial helper


helper : State -> Parser (Step State Moves)
helper state =
    oneOf
        [ succeed (\move -> Loop <| advance move state)
            |. moveNumber state
            |= san
            |. spaces
        , succeed (Done <| List.reverse state.moves)
            |. end
        ]


moveNumber : State -> Parser ()
moveNumber state =
    if state.toMove == White then
        succeed ()
            |. symbol (String.fromInt state.moveNumber)
            |. symbol "."
            |. spaces

    else
        oneOf
            [ succeed ()
                |. symbol (String.fromInt state.moveNumber)
                |. symbol "..."
                |. spaces
            , succeed ()
            ]


type alias State =
    { moves : List String
    , moveNumber : Int
    , toMove : Colour
    }


initial : State
initial =
    { moves = []
    , moveNumber = 1
    , toMove = White
    }


advance : String -> State -> State
advance move state =
    let
        list =
            move :: state.moves

        number =
            state.moveNumber + ternary (state.toMove == White) 0 1

        colour =
            ternary (state.toMove == White) Black White
    in
    { state | moves = list, moveNumber = number, toMove = colour }


type alias Moves =
    List String


type Colour
    = White
    | Black


san : Parser String
san =
    getChompedString <|
        succeed ()
            |. chompIf (\c -> c == 'a' || c == 'b' || c == 'c' || c == 'd' || c == 'e' || c == 'f' || c == 'g' || c == 'h')
            |. chompIf (\c -> c == '1' || c == '2' || c == '3' || c == '4' || c == '5' || c == '6' || c == '7' || c == '8')


parse : String -> String
parse input =
    case run parser input of
        Ok good ->
            Debug.toString good

        Err list ->
            Debug.toString list
