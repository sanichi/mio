module Y16D08 exposing (answers)

import Regex
import Util


answers : String -> String
answers input =
    let
        instructions =
            parse input

        a1 =
            instructions
                |> List.length
                |> toString

        a2 =
            instructions
                |> List.filter (\i -> i == Invalid)
                |> List.length
                |> toString
    in
        Util.join a1 a2


type Instruction
    = Rect Int Int
    | Row Int Int
    | Col Int Int
    | Invalid


parse : String -> List Instruction
parse input =
    input
        |> Regex.find Regex.All (Regex.regex "(rect |rotate (?:row y|column x)=)(\\d+)(?:x| by )(\\d+)")
        |> List.map .submatches
        |> List.map parseInstruction


parseInstruction : List (Maybe String) -> Instruction
parseInstruction submatches =
    let
        ( string, x, y ) =
            case submatches of
                [ Just s, Just i, Just j ] ->
                    ( s, (String.toInt i |> Result.withDefault 0), (String.toInt j |> Result.withDefault 0) )

                _ ->
                    ( "", 0, 0 )
    in
        case string of
            "rect " ->
                Rect x y

            "rotate row y=" ->
                Row x y

            "rotate column x=" ->
                Col x y

            _ ->
                Invalid
