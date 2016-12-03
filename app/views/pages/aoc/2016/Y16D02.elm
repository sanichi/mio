module Y16D02 exposing (answers)

import Regex
import Util


answers : String -> String
answers input =
    let
        instructions =
            parse input

        a1 =
            List.length instructions

        a2 =
            0
    in
        Util.join (toString a1) (toString a2)


parse : String -> List String
parse input =
    Regex.find (Regex.All) (Regex.regex "([RLUD]+)") input
        |> List.map .match
