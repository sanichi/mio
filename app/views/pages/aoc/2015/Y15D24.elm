module Y15D24 exposing (..)

import Regex
import String
import Util exposing (combinations, join)


answers : String -> String
answers input =
  let
    weights = parseInput input
    p1 = bestQe 3 weights |> toString
    p2 = bestQe 4 weights |> toString
  in
    join p1 p2


bestQe : Int -> Weights -> Int
bestQe groups weights =
  let
    weight = List.sum weights // groups
    maxLen = List.length weights - groups + 1
  in
    searchLength 0 1 maxLen weight weights


searchLength : Int -> Int -> Int -> Int -> Weights -> Int
searchLength qe length maxLen weight weights =
  if length > maxLen
    then qe
    else
      let
        combos = combinations length weights
        qe' = searchCombo qe weight combos
      in
        if qe' > 0
          then qe'
          else searchLength qe (length + 1) maxLen weight weights


searchCombo : Int -> Int -> List Weights -> Int
searchCombo qe weight combos =
  case combos of
    [ ] -> qe
    weights :: rest ->
      let
        qe' =
          if List.sum weights /= weight
            then qe
            else
              let
                qe'' = List.product weights
              in
                if qe == 0 || qe'' < qe then qe'' else qe
      in
        searchCombo qe' weight rest


parseInput : String -> Weights
parseInput input =
  Regex.find (Regex.All) (Regex.regex "\\d+") input
    |> List.map .match
    |> List.map String.toInt
    |> List.map (Result.withDefault 0)
    |> List.filter (\w -> w /= 0)


type alias Weights =
  List Int
