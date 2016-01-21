module Y15D21 where

import Regex
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    boss = parseInput input
    me = Fighter 8 5 5
    p1 = boss |> toString
    p2 = me |> toString
  in
    join p1 p2


parseInput : String -> Fighter
parseInput input =
  let
    ns =
      Regex.find (Regex.All) (Regex.regex "\\d+") input
        |> List.map .match
        |> List.map String.toInt
  in
    case ns of
      [ Ok h, Ok d, Ok a ] -> Fighter h d a
      _ -> Fighter 0 0 0


type alias Fighter =
  { hits   : Int
  , damage : Int
  , armor  : Int
  }
