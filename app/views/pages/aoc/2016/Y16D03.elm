module Y16D03 exposing (answers)

import Regex
import Util


answers : String -> String
answers input =
    let
        horizontals =
            parse input

        verticals =
            rearrange [] [] [] horizontals

        a1 =
            List.map List.sort horizontals |> count |> toString

        a2 =
            List.map List.sort verticals |> count |> toString
    in
        Util.join a1 a2


count : List (List Int) -> Int
count triangles =
    case triangles of
        [] ->
            0

        triangle :: rest ->
            ok triangle + count rest


ok : List Int -> Int
ok triangle =
    case triangle of
        [ s1, s2, s3 ] ->
            if s1 + s2 > s3 then
                1
            else
                0

        _ ->
            0


rearrange : List Int -> List Int -> List Int -> List (List Int) -> List (List Int)
rearrange a1 a2 a3 horizontals =
    if List.length a1 >= 3 then
        [ a1, a2, a3 ] ++ rearrange [] [] [] horizontals
    else
        case horizontals of
            [] ->
                []

            [ s1, s2, s3 ] :: rest ->
                let
                    b1 =
                        s1 :: a1

                    b2 =
                        s2 :: a2

                    b3 =
                        s3 :: a3
                in
                    rearrange b1 b2 b3 rest

            _ :: rest ->
                rearrange a1 a2 a3 rest


parse : String -> List (List Int)
parse input =
    Regex.find (Regex.All) (Regex.regex "(\\d+) +(\\d+) +(\\d+)") input
        |> List.map .submatches
        |> List.map (List.map convertToInt)


convertToInt : Maybe String -> Int
convertToInt item =
    Maybe.withDefault "0" item
        |> String.toInt
        |> Result.toMaybe
        |> Maybe.withDefault 0
