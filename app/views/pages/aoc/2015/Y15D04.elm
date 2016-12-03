module Y15D04 exposing (answers)

import Regex
import MD5
import Util exposing (join)


answers : String -> String
answers input =
    let
        key =
            parse input

        a1 =
            find 1 "00000" key

        a2 =
            find a1 "000000" key
    in
        join (toString a1) (toString a2)


parse : String -> String
parse input =
    Regex.find (Regex.AtMost 1) (Regex.regex "[a-z]+") input
        |> List.map .match
        |> List.head
        |> Maybe.withDefault "no secret key found"


find : Int -> String -> String -> Int
find step start key =
    let
        hash =
            MD5.hex (key ++ (toString step))
    in
        if String.startsWith start hash then
            step
        else
            find (step + 1) start key
