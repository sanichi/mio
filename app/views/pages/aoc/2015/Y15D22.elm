module Y15D22 where

import Regex
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    data = parseInput input
    p1 = data |> toString
    p2 = data |> toString
  in
    join p1 p2


parseInput : String -> List Int
parseInput input =
  Regex.find (Regex.All) (Regex.regex "\\d+") input
    |> List.map .match
    |> List.map String.toInt
    |> List.map (Result.withDefault 0)
