module Y20D22 exposing (answer)

import Regex
import Set exposing (Set)
import Util


answer : Int -> String -> String
answer part input =
    let
        game =
            parse input

        recursive =
            part /= 1
    in
    game
        |> combat recursive
        |> score
        |> String.fromInt


type alias Game =
    { player1 : List Int
    , player2 : List Int
    , winner : Int
    , history : Set String
    }


combat : Bool -> Game -> Game
combat recursive game_ =
    let
        game =
            check game_
    in
    if game.winner /= 0 then
        game

    else
        case ( game.player1, game.player2 ) of
            ( c1 :: rest1, c2 :: rest2 ) ->
                let
                    winner =
                        if recursive && List.length rest1 >= c1 && List.length rest2 >= c2 then
                            Game (List.take c1 rest1) (List.take c2 rest2) 0 Set.empty
                                |> combat True
                                |> .winner

                        else if c1 > c2 then
                            1

                        else
                            2
                in
                if winner == 1 then
                    combat recursive { game | player1 = rest1 ++ [ c1, c2 ], player2 = rest2 }

                else
                    combat recursive { game | player2 = rest2 ++ [ c2, c1 ], player1 = rest1 }

            _ ->
                let
                    winner =
                        case ( List.isEmpty game.player1, List.isEmpty game.player2 ) of
                            ( False, True ) ->
                                1

                            ( True, False ) ->
                                2

                            _ ->
                                0
                in
                { game | winner = winner }


score : Game -> Int
score game =
    let
        cards =
            case game.winner of
                1 ->
                    game.player1

                2 ->
                    game.player2

                _ ->
                    []
    in
    cards
        |> List.reverse
        |> List.indexedMap (\i c -> (i + 1) * c)
        |> List.sum


check : Game -> Game
check game =
    let
        d1 =
            game.player1
                |> List.map String.fromInt
                |> String.join "|"

        d2 =
            game.player2
                |> List.map String.fromInt
                |> String.join "|"

        digest =
            d1 ++ "||" ++ d2
    in
    if Set.member digest game.history then
        { game | winner = 1 }

    else
        { game | history = Set.insert digest game.history }


parse : String -> Game
parse input =
    input
        |> Regex.split (Util.regex "\\n")
        |> parse_ (Game [] [] 0 Set.empty) 1


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
                        parse_ { game | player1 = game.player1 ++ [ num ] } player rest

                    else
                        parse_ { game | player2 = game.player2 ++ [ num ] } player rest

                else
                    parse_ game player rest

        _ ->
            game


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
