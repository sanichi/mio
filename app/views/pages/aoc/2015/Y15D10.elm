module Y15D10 exposing (answer)

import Regex exposing (HowMany(All, AtMost), Match, find, regex, replace)


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
                |> toString
        else
            digits
                |> conway 10
                |> String.length
                |> toString


parse : String -> String
parse input =
    find (AtMost 1) (regex "\\d+") input
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
                replace All (regex "(\\d)\\1*") mapper digits
        in
            conway (count - 1) digits_


mapper : Match -> String
mapper match =
    let
        length =
            String.length match.match |> toString

        char =
            String.left 1 match.match
    in
        length ++ char
