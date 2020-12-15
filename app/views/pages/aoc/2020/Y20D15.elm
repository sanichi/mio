module Y20D15 exposing (answer)

import Dict exposing (Dict)
import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        start =
            parse input

        upto =
            if part == 1 then
                2020

            else
                30000000
    in
    start
        |> init
        |> play upto
        |> String.fromInt


type alias Game =
    { turn : Int
    , last : Int
    , before : Dict Int Int
    }


init : List Int -> Game
init numbers =
    init_ numbers (Game 0 0 Dict.empty)


init_ : List Int -> Game -> Game
init_ numbers game =
    case numbers of
        num :: rest ->
            let
                turn =
                    game.turn + 1

                before =
                    if List.isEmpty rest then
                        game.before

                    else
                        Dict.insert num turn game.before
            in
            init_ rest (Game turn num before)

        _ ->
            game


play : Int -> Game -> Int
play upto game =
    if game.turn == upto then
        game.last

    else
        let
            turn =
                game.turn + 1

            before =
                Dict.insert game.last game.turn game.before
        in
        case Dict.get game.last game.before of
            Nothing ->
                play upto (Game turn 0 before)

            Just previous ->
                let
                    last =
                        game.turn - previous
                in
                play upto (Game turn last before)


parse : String -> List Int
parse input =
    input
        |> Regex.find (Util.regex "\\d+")
        |> List.map .match
        |> List.map String.toInt
        |> List.map (Maybe.withDefault 0)
