module Y15D04 exposing (answer)

import MD5
import Regex
import Util exposing (regex)


answer : Int -> String -> String
answer part input =
    let
        key =
            parse input

        a1 =
            find 1 "00000" key
    in
    if part == 1 then
        a1 |> String.fromInt

    else
        find a1 "000000" key |> String.fromInt


parse : String -> String
parse input =
    Regex.findAtMost 1 (regex "[a-z]+") input
        |> List.map .match
        |> List.head
        |> Maybe.withDefault "no secret key found"


find : Int -> String -> String -> Int
find step start key =
    let
        hash =
            MD5.hex (key ++ String.fromInt step)
    in
    if String.startsWith start hash then
        step

    else
        find (step + 1) start key
