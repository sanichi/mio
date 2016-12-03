module Y15D20 exposing (answers)

import Dict
import Regex
import Util exposing (join)


answers : String -> String
answers input =
    let
        goal =
            parseInput input

        p1 =
            house1 goal 1 |> toString

        p2 =
            house2 goal 1 |> toString
    in
        join p1 p2


house1 : Int -> Int -> Int
house1 goal house =
    let
        presents =
            factors house
                |> List.map ((*) 10)
                |> List.sum
    in
        if presents >= goal then
            house
        else
            house1 goal (house + 1)


house2 : Int -> Int -> Int
house2 goal house =
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
            house2 goal (house + 1)


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


parseInput : String -> Int
parseInput input =
    Regex.find (Regex.AtMost 1) (Regex.regex "\\d+") input
        |> List.map .match
        |> List.head
        |> Maybe.withDefault "0"
        |> String.toInt
        |> Result.withDefault 0
