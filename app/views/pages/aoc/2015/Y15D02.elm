module Y15D02 exposing (..)

import Regex
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    p1 = sumInput wrapping input |> toString
    p2 = sumInput ribbon input |> toString
  in
    join p1 p2


sumInput : (Int -> Int -> Int -> Int) -> String -> Int
sumInput counter input =
  let
    lines = Regex.split Regex.All (Regex.regex "\n") input
  in
    List.foldl (sumLine counter) 0 lines


sumLine : (Int -> Int -> Int -> Int) -> String -> Int -> Int
sumLine counter line count =
  let
    dimensions =
      Regex.find Regex.All (Regex.regex "[1-9]\\d*") line
        |> List.map .match
        |> List.map String.toInt
        |> List.map (Result.withDefault 0)
    extra =
      case dimensions of
        [l, w, h] -> counter l w h
        _ -> 0
  in
    count + extra


wrapping : Int -> Int -> Int -> Int
wrapping l w h =
  let
    sides = [l * w, w * h, h * l]
    paper = 2 * List.sum sides
    slack = List.minimum sides |> Maybe.withDefault 0
  in
    paper + slack


ribbon : Int -> Int -> Int -> Int
ribbon l w h =
  let
    perimeters = [l + w, w + h, h + l]
    perimeter = List.minimum perimeters |> Maybe.withDefault 0
    volume = l * w * h
  in
    2 * perimeter + volume
