module Y15D08 exposing (..)

import Regex exposing (HowMany(All), replace, regex)
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    strings = parseInput input
    p1 = (chrLength strings) - (memLength strings) |> toString
    p2 = (escLength strings) - (chrLength strings) |> toString
  in
    join p1 p2


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
    r1 = replace All (regex "(^\"|\"$)") (\_ -> "") line
    r2 = replace All (regex "\\\\\"") (\_ -> "_") r1
    r3 = replace All (regex "\\\\\\\\") (\_ -> ".") r2
    r4 = replace All (regex "\\\\x[0-9a-f]{2}") (\_ -> "-") r3
  in
    r4


escape : String -> String
escape line =
  let
    r1 = replace All (regex "\\\\") (\_ -> "\\\\") line
    r2 = replace All (regex "\"") (\_ -> "\\\"") r1
    r3 = "\"" ++ r2 ++ "\""
  in
    r3
