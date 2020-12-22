module Y20D22 exposing (answer)

import Dict exposing (Dict)
import Regex
import Set exposing (Set)
import Util


answer : Int -> String -> String
answer part input =
    let
        game =
            parse input
    in
    if part == 1 then
        game
            |> play
            |> score
            |> String.fromInt

    else
        example
            |> parse
            |> play
            |> score
            |> String.fromInt


type alias Game =
    { p1 : List Int
    , p2 : List Int
    }


play : Game -> Game
play game =
    case ( game.p1, game.p2 ) of
        ( c1 :: rest1, c2 :: rest2 ) ->
            if c1 > c2 then
                play { game | p1 = add c2 (add c1 rest1), p2 = rest2 }

            else
                play { game | p2 = add c1 (add c2 rest2), p1 = rest1 }

        _ ->
            game


score : Game -> Int
score game =
    let
        s1 =
            game.p1
                |> List.reverse
                |> List.indexedMap (\i c -> (i + 1) * c)
                |> List.sum

        s2 =
            game.p2
                |> List.reverse
                |> List.indexedMap (\i c -> (i + 1) * c)
                |> List.sum
    in
    s1 + s2


parse : String -> Game
parse input =
    input
        |> Regex.split (Util.regex "\\n")
        |> parse_ (Game [] []) 1


parse_ : Game -> Int -> List String -> Game
parse_ game player lines =
    case lines of
        line :: rest ->
            if String.contains "Player 2" line then
                parse_ game 2 rest

            else
                let
                    num =
                        line
                            |> Regex.find (Util.regex "^([1-9]\\d*)")
                            |> List.map .submatches
                            |> List.head
                            |> Maybe.withDefault []
                            |> List.filterMap identity
                            |> List.filterMap String.toInt
                            |> List.head
                            |> Maybe.withDefault 0
                in
                if num > 0 then
                    if player == 1 then
                        parse_ { game | p1 = add num game.p1 } player rest

                    else
                        parse_ { game | p2 = add num game.p2 } player rest

                else
                    parse_ game player rest

        _ ->
            game


add : Int -> List Int -> List Int
add num list =
    List.reverse (num :: List.reverse list)


example : String
example =
    """
Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10
"""
