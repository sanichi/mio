module Y20D12 exposing (answer)

import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        instructions =
            parse input
    in
    if part == 1 then
        instructions
            |> navigate1 initFerry
            |> distance
            |> String.fromInt

    else
        instructions
            |> navigate2 initCombo
            |> Tuple.first
            |> distance
            |> String.fromInt


type Action
    = N
    | S
    | E
    | W
    | R
    | L
    | F


type alias Instruction =
    ( Action, Int )


type Direction
    = North
    | South
    | East
    | West


type alias Ferry =
    { x : Int
    , y : Int
    , d : Direction
    }


type alias Waypoint =
    { x : Int
    , y : Int
    }


type alias Combo =
    ( Ferry, Waypoint )


initFerry : Ferry
initFerry =
    Ferry 0 0 East


initWaypoint : Waypoint
initWaypoint =
    Waypoint 10 1


initCombo : Combo
initCombo =
    ( initFerry, initWaypoint )


navigate1 : Ferry -> List Instruction -> Ferry
navigate1 ferry instructions =
    case instructions of
        instruction :: rest ->
            let
                update =
                    case instruction of
                        ( N, n ) ->
                            { ferry | y = ferry.y + n }

                        ( S, n ) ->
                            { ferry | y = ferry.y - n }

                        ( E, n ) ->
                            { ferry | x = ferry.x + n }

                        ( W, n ) ->
                            { ferry | x = ferry.x - n }

                        ( L, n ) ->
                            rotateFerry ferry L n

                        ( R, n ) ->
                            rotateFerry ferry R n

                        ( F, n ) ->
                            case ferry.d of
                                North ->
                                    { ferry | y = ferry.y + n }

                                South ->
                                    { ferry | y = ferry.y - n }

                                East ->
                                    { ferry | x = ferry.x + n }

                                West ->
                                    { ferry | x = ferry.x - n }
            in
            navigate1 update rest

        _ ->
            ferry


navigate2 : Combo -> List Instruction -> Combo
navigate2 combo instructions =
    case instructions of
        instruction :: rest ->
            let
                ( f, w ) =
                    combo

                ferry =
                    case instruction of
                        ( F, n ) ->
                            { f | x = f.x + n * w.x, y = f.y + n * w.y }

                        _ ->
                            f

                waypoint =
                    case instruction of
                        ( N, n ) ->
                            { w | y = w.y + n }

                        ( S, n ) ->
                            { w | y = w.y - n }

                        ( E, n ) ->
                            { w | x = w.x + n }

                        ( W, n ) ->
                            { w | x = w.x - n }

                        ( L, n ) ->
                            rotateWaypoint w L n

                        ( R, n ) ->
                            rotateWaypoint w R n

                        _ ->
                            w
            in
            navigate2 ( ferry, waypoint ) rest

        _ ->
            combo


rotateFerry : Ferry -> Action -> Int -> Ferry
rotateFerry ferry a n =
    let
        direction =
            if n == 180 then
                case ferry.d of
                    North ->
                        South

                    South ->
                        North

                    East ->
                        West

                    West ->
                        East

            else if (a == L && n == 90) || (a == R && n == 270) then
                case ferry.d of
                    North ->
                        West

                    South ->
                        East

                    East ->
                        North

                    West ->
                        South

            else if (a == R && n == 90) || (a == L && n == 270) then
                case ferry.d of
                    North ->
                        East

                    South ->
                        West

                    East ->
                        South

                    West ->
                        North

            else
                ferry.d
    in
    { ferry | d = direction }


rotateWaypoint : Waypoint -> Action -> Int -> Waypoint
rotateWaypoint w a n =
    if n == 180 then
        Waypoint -w.x -w.y

    else if (a == L && n == 90) || (a == R && n == 270) then
        Waypoint -w.y w.x

    else if (a == R && n == 90) || (a == L && n == 270) then
        Waypoint w.y -w.x

    else
        w


distance : Ferry -> Int
distance ferry =
    abs ferry.x + abs ferry.y


parse : String -> List Instruction
parse input =
    input
        |> Regex.find (Util.regex "([NSEWLRF])([1-9]\\d*)")
        |> List.map .submatches
        |> List.filterMap
            (\m ->
                case m of
                    [ Just act, Just num ] ->
                        let
                            a =
                                case act of
                                    "N" ->
                                        N

                                    "S" ->
                                        S

                                    "E" ->
                                        E

                                    "W" ->
                                        W

                                    "L" ->
                                        L

                                    "R" ->
                                        R

                                    _ ->
                                        F

                            n =
                                Maybe.withDefault 0 <| String.toInt num
                        in
                        Just ( a, n )

                    _ ->
                        Nothing
            )


example : String
example =
    "F10 N3 F7 R90 F11"
