module Y21D02 exposing (answer)

import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        commands =
            parse input
    in
    if part == 1 then
        commands
            |> navigate1 start
            |> multiply

    else
        commands
            |> navigate2 start
            |> multiply


type alias Position =
    { depth : Int
    , horizontal : Int
    , aim : Int
    }


start : Position
start =
    Position 0 0 0


type alias Command =
    { direction : Direction
    , amount : Int
    }


type Direction
    = Down
    | Forward
    | Up


multiply : Position -> String
multiply p =
    String.fromInt (p.depth * p.horizontal)


navigate1 : Position -> List Command -> Position
navigate1 p list =
    case list of
        [] ->
            p

        c :: commands ->
            let
                position =
                    case c.direction of
                        Down ->
                            Position (p.depth + c.amount) p.horizontal 0

                        Up ->
                            Position (p.depth - c.amount) p.horizontal 0

                        Forward ->
                            Position p.depth (p.horizontal + c.amount) 0
            in
            navigate1 position commands


navigate2 : Position -> List Command -> Position
navigate2 p list =
    case list of
        [] ->
            p

        c :: commands ->
            let
                position =
                    case c.direction of
                        Down ->
                            Position p.depth p.horizontal (p.aim + c.amount)

                        Up ->
                            Position p.depth p.horizontal (p.aim - c.amount)

                        Forward ->
                            Position (p.depth + p.aim * c.amount) (p.horizontal + c.amount) p.aim
            in
            navigate2 position commands


parse : String -> List Command
parse input =
    input
        |> Regex.find (Util.regex "(down|forward|up) ([1-9])")
        |> List.map .submatches
        |> List.filterMap
            (\m ->
                case m of
                    [ Just d, Just a ] ->
                        let
                            direction =
                                case d of
                                    "down" ->
                                        Down

                                    "forward" ->
                                        Forward

                                    _ ->
                                        Up

                            amount =
                                String.toInt a |> Maybe.withDefault 0
                        in
                        Just (Command direction amount)

                    _ ->
                        Nothing
            )



-- example : String
-- example =
--     """
-- forward 5
-- down 5
-- forward 8
-- up 3
-- down 8
-- forward 2
--   """
