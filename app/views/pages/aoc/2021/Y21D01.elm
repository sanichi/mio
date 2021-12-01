module Y21D01 exposing (answer)

import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        depths =
            parse input
    in
    if part == 1 then
        depths
            |> sweeps 0
            |> String.fromInt

    else
        depths
            |> sliders 0
            |> String.fromInt


sweeps : Int -> List Int -> Int
sweeps count list =
    case list of
        d1 :: d2 :: rest ->
            let
                count_ =
                    if d2 > d1 then
                        count + 1

                    else
                        count
            in
            sweeps count_ (d2 :: rest)

        _ ->
            count


sliders : Int -> List Int -> Int
sliders count list =
    case list of
        d1 :: d2 :: d3 :: d4 :: rest ->
            let
                s1 =
                    d1 + d2 + d3

                s2 =
                    d2 + d3 + d4

                count_ =
                    if s2 > s1 then
                        count + 1

                    else
                        count
            in
            sliders count_ (d2 :: d3 :: d4 :: rest)

        _ ->
            count


parse : String -> List Int
parse input =
    input
        |> Regex.find (Util.regex "\\d+")
        |> List.map .match
        |> List.filterMap String.toInt



-- example : String
-- example =
--     """
-- 199
-- 200
-- 208
-- 210
-- 200
-- 207
-- 240
-- 269
-- 260
-- 263
--     """
