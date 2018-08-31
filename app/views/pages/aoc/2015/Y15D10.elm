module Y15D10 exposing (answer)

import Regex exposing (Match, findAtMost, replace)
import Util exposing (regex)


answer : Int -> String -> String
answer part input =
    let
        digits =
            input
                |> parse
                |> conway 40
    in
    if part == 1 then
        digits
            |> String.length
            |> String.fromInt

    else
        digits
            |> conway 10
            |> String.length
            |> String.fromInt


parse : String -> String
parse input =
    findAtMost 1 (regex "\\d+") input
        |> List.map .match
        |> List.head
        |> Maybe.withDefault "no digits found"


conway : Int -> String -> String
conway count digits =
    if count <= 0 then
        digits

    else
        let
            digits_ =
                replace (regex "(\\d)\\1*") mapper digits
        in
        conway (count - 1) digits_


mapper : Match -> String
mapper match =
    let
        length =
            String.length match.match |> String.fromInt

        char =
            String.left 1 match.match
    in
    length ++ char
