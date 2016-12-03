module Y15D01 exposing (answers)

import Util exposing (join)


answers : String -> String
answers input =
    let
        p1 =
            count 0 input |> toString

        p2 =
            position 0 0 input |> toString
    in
        join p1 p2


count : Int -> String -> Int
count floor instructions =
    let
        next =
            String.uncons instructions
    in
        case next of
            Just ( '(', remaining ) ->
                count (floor + 1) remaining

            Just ( ')', remaining ) ->
                count (floor - 1) remaining

            _ ->
                floor


position : Int -> Int -> String -> Int
position floor step instructions =
    if floor < 0 then
        step
    else
        let
            next =
                String.uncons instructions
        in
            case next of
                Just ( '(', remaining ) ->
                    position (floor + 1) (step + 1) remaining

                Just ( ')', remaining ) ->
                    position (floor - 1) (step + 1) remaining

                _ ->
                    step
