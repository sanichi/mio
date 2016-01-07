module Y15D01 where

import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    p1 = part1 input
    p2 = part2 input
  in
    join p1 p2


part1 : String -> String
part1 input =
  count 0 input |> toString


part2 : String -> String
part2 input =
  position 0 0 input |> toString


count : Int -> String -> Int
count floor instructions =
  let
    next = String.uncons instructions
  in
    case next of
      Just ('(', remaining) ->
        count (floor + 1) remaining
      Just (')', remaining) ->
        count (floor - 1) remaining
      _ ->
        floor


position : Int -> Int -> String -> Int
position floor step instructions =
  if floor < 0
    then step
    else
      let
        next = String.uncons instructions
      in
        case next of
          Just ('(', remaining) ->
            position (floor + 1) (step + 1) remaining
          Just (')', remaining) ->
            position (floor - 1) (step + 1) remaining
          _ ->
            step
