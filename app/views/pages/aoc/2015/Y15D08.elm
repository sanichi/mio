module Y15D08 exposing (answer)

import Regex
import Util exposing (regex)


answer : Int -> String -> String
answer part input =
    let
        strings =
            parseInput input
    in
    if part == 1 then
        chrLength strings - memLength strings |> String.fromInt

    else
        escLength strings - chrLength strings |> String.fromInt


parseInput : String -> List String
parseInput input =
    String.split "\n" input
        |> List.filter (\l -> l /= "")


chrLength : List String -> Int
chrLength lines =
    lines
        |> List.map String.length
        |> List.sum


memLength : List String -> Int
memLength lines =
    List.map unescape lines
        |> List.map String.length
        |> List.sum


escLength : List String -> Int
escLength lines =
    List.map escape lines
        |> List.map String.length
        |> List.sum


unescape : String -> String
unescape line =
    let
        r1 =
            Regex.replace (regex "(^\"|\"$)") (\_ -> "") line

        r2 =
            Regex.replace (regex "\\\\\"") (\_ -> "_") r1

        r3 =
            Regex.replace (regex "\\\\\\\\") (\_ -> ".") r2

        r4 =
            Regex.replace (regex "\\\\x[0-9a-f]{2}") (\_ -> "-") r3
    in
    r4


escape : String -> String
escape line =
    let
        r1 =
            Regex.replace (regex "\\\\") (\_ -> "\\\\") line

        r2 =
            Regex.replace (regex "\"") (\_ -> "\\\"") r1

        r3 =
            "\"" ++ r2 ++ "\""
    in
    r3
