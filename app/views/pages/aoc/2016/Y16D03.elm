module Y16D03 exposing (answer)

import Regex exposing (find)
import Util exposing (regex)


answer : Int -> String -> String
answer part input =
    let
        horizontals =
            parse input
    in
    if part == 1 then
        process horizontals

    else
        let
            verticals =
                rearrange [] [] [] horizontals
        in
        process verticals


process : List Triangle -> String
process triangles =
    triangles
        |> List.map List.sort
        |> count
        |> String.fromInt


count : List Triangle -> Int
count triangles =
    case triangles of
        [] ->
            0

        triangle :: rest ->
            ok triangle + count rest


ok : Triangle -> Int
ok triangle =
    case triangle of
        [ s1, s2, s3 ] ->
            if s1 + s2 > s3 then
                1

            else
                0

        _ ->
            0


rearrange : Triangle -> Triangle -> Triangle -> List Triangle -> List Triangle
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


type alias Triangle =
    List Int


parse : String -> List Triangle
parse input =
    input
        |> find (regex "(\\d+) +(\\d+) +(\\d+)")
        |> List.map .submatches
        |> List.map (List.map convertToInt)


convertToInt : Maybe String -> Int
convertToInt item =
    Maybe.withDefault "0" item
        |> String.toInt
        |> Maybe.withDefault 0
