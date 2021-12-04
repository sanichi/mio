module Y21D03 exposing (answer)

import Arithmetic
import List.Extra
import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        numbers =
            parse input
    in
    if part == 1 then
        powerConsumption numbers

    else
        lifeSupport numbers


powerConsumption : List (List Int) -> String
powerConsumption numbers =
    let
        gamma =
            common True numbers

        epsilon =
            common False numbers
    in
    multiply gamma epsilon |> String.fromInt


lifeSupport : List (List Int) -> String
lifeSupport numbers =
    let
        oxygen =
            filter True 0 numbers

        co2 =
            filter False 0 numbers
    in
    multiply oxygen co2 |> String.fromInt


common : Bool -> List (List Int) -> List Int
common most numbers =
    let
        sum =
            List.foldr add [] numbers

        half =
            numbers
                |> List.length
                |> toFloat
                |> (\t -> t / 2.0)
    in
    List.map
        (\n ->
            if (most && toFloat n >= half) || (not most && toFloat n < half) then
                1

            else
                0
        )
        sum


filter : Bool -> Int -> List (List Int) -> List Int
filter most index numbers =
    if List.length numbers <= 1 then
        numbers
            |> List.head
            |> Maybe.withDefault []

    else
        let
            scan =
                common most numbers
        in
        if index >= List.length scan then
            numbers
                |> List.head
                |> Maybe.withDefault []

        else
            let
                bit =
                    getAt index scan

                matches =
                    List.filter (\b -> getAt index b == bit) numbers
            in
            filter most (index + 1) matches


add : List Int -> List Int -> List Int
add n1 n2 =
    let
        diff =
            List.length n2 - List.length n1

        n1_ =
            if diff > 0 then
                List.append n1 (List.repeat diff 0)

            else
                n1

        n2_ =
            if diff < 0 then
                List.append n2 (List.repeat -diff 0)

            else
                n2
    in
    List.map2 (+) n1_ n2_


multiply : List Int -> List Int -> Int
multiply n1 n2 =
    [ n1, n2 ]
        |> List.map (Arithmetic.fromBase 2)
        |> List.product


getAt : Int -> List Int -> Int
getAt index number =
    number
        |> List.Extra.getAt index
        |> Maybe.withDefault 0


parse : String -> List (List Int)
parse input =
    input
        |> Regex.find (Util.regex "[01]+")
        |> List.map .match
        |> List.map String.toList
        |> List.map
            (\chars ->
                List.map
                    (\char ->
                        if char == '0' then
                            0

                        else
                            1
                    )
                    chars
            )



-- example : String
-- example =
--     """
-- 00100
-- 11110
-- 10110
-- 10111
-- 10101
-- 01111
-- 00111
-- 11100
-- 10000
-- 11001
-- 00010
-- 01010
--   """
