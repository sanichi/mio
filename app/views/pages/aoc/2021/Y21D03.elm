module Y21D03 exposing (answer)

import Arithmetic
import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        numbers =
            parse input
    in
    if part == 1 then
        multiply numbers

    else
        "not done yet"


multiply : List (List Int) -> String
multiply numbers =
    let
        gamma =
            common numbers

        epsilon =
            gamma
                |> List.map
                    (\b ->
                        if b == 1 then
                            0

                        else
                            1
                    )
    in
    [ gamma, epsilon ]
        |> List.map (Arithmetic.fromBase 2)
        |> List.product
        |> String.fromInt


common : List (List Int) -> List Int
common numbers =
    let
        sum =
            List.foldr add [] numbers

        half =
            List.length numbers // 2
    in
    List.map
        (\n ->
            if n > half then
                1

            else
                0
        )
        sum


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


example : String
example =
    """
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
  """
