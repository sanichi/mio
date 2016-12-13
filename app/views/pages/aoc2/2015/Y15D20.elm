module Y15D20 exposing (answer)

import Dict
import Regex


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> house1 1
            |> toString
    else
        input
            |> parse
            |> house2 1
            |> toString


house1 : Int -> Int -> Int
house1 house goal =
    let
        presents =
            factors house
                |> List.map ((*) 10)
                |> List.sum
    in
        if presents >= goal then
            house
        else
            house1 (house + 1) goal


house2 : Int -> Int -> Int
house2 house goal =
    let
        presents =
            factors house
                |> List.filter (\elf -> house // elf <= 50)
                |> List.map ((*) 11)
                |> List.sum
    in
        if presents >= goal then
            house
        else
            house2 (house + 1) goal


factors : Int -> List Int
factors n =
    fac n 1 (toFloat n |> sqrt) []


fac : Int -> Int -> Float -> List Int -> List Int
fac n i l fs =
    if (toFloat i) > l then
        fs
    else
        let
            fs1 =
                if rem n i /= 0 then
                    fs
                else
                    let
                        fs2 =
                            i :: fs

                        j =
                            n // i
                    in
                        if j == i then
                            fs2
                        else
                            j :: fs2
        in
            fs1 ++ fac n (i + 1) l fs


parse : String -> Int
parse input =
    Regex.find (Regex.AtMost 1) (Regex.regex "\\d+") input
        |> List.map .match
        |> List.head
        |> Maybe.withDefault "0"
        |> String.toInt
        |> Result.withDefault 0
