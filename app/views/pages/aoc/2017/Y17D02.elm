module Y17D02 exposing (answer)

import Regex
import Util exposing (combinations)


answer : Int -> String -> String
answer part input =
    let
        list =
            parse input
    in
        if part == 1 then
            list
                |> List.map diff
                |> List.sum
                |> toString
        else
            list
                |> List.map even
                |> List.sum
                |> toString


diff : List Int -> Int
diff list =
    let
        min =
            List.minimum list

        max =
            List.maximum list
    in
        case ( min, max ) of
            ( Just a, Just b ) ->
                b - a

            _ ->
                0


even : List Int -> Int
even list =
    list
        |> combinations 2
        |> List.map List.sort
        |> List.map pair
        |> List.sum


pair : List Int -> Int
pair list =
    case list of
        [ min, max ] ->
            let
                qot =
                    max // min
            in
                if min * qot == max then
                    qot
                else
                    0

        _ ->
            0


parse : String -> List (List Int)
parse input =
    input
        |> String.split "\n"
        |> List.map toNumbers


toNumbers : String -> List Int
toNumbers string =
    string
        |> Regex.find Regex.All (Regex.regex "[1-9]\\d*")
        |> List.map .match
        |> List.map String.toInt
        |> List.map (Result.withDefault 0)
