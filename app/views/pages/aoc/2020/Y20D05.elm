module Y20D05 exposing (answer)

import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        ids =
            parse input
    in
    if part == 1 then
        ids
            |> List.maximum
            |> Maybe.withDefault 0
            |> String.fromInt

    else
        ids
            |> List.sort
            |> search
            |> String.fromInt


search : List Int -> Int
search ids =
    case ids of
        c1 :: c2 :: rest ->
            if c2 == c1 + 2 then
                c1 + 1

            else
                search (c2 :: rest)

        _ ->
            0


type alias Pass =
    { row : Int
    , col : Int
    }


id : Pass -> Int
id p =
    8 * p.row + p.col


parse : String -> List Int
parse input =
    input
        |> Regex.find (Util.regex "([FB]{7})([LR]{3})")
        |> List.map .submatches
        |> List.filterMap
            (\m ->
                case m of
                    [ Just row, Just col ] ->
                        Just (Pass (convert row) (convert col))

                    _ ->
                        Nothing
            )
        |> List.map id


convert : String -> Int
convert code =
    code
        |> String.toList
        |> List.reverse
        |> convert_ 0 1


convert_ : Int -> Int -> List Char -> Int
convert_ n f chars =
    case chars of
        c :: rest ->
            let
                d =
                    if c == 'B' || c == 'R' then
                        f

                    else
                        0
            in
            convert_ (n + d) (2 * f) rest

        _ ->
            n


example : String
example =
    "BFFFBBFRRR FFFBBBFRRR BBFFBBFRLL"
