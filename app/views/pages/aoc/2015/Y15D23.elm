module Y15D23 where

import Array exposing (Array)
import Regex
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    model = parseInput input
    p1 = Array.length model |> toString
    p2 = model |> toString
  in
    join p1 p2


parseInput : String -> Model
parseInput input =
  String.split "\n" input
    |> List.filter (\l -> l /= "")
    |> List.foldl parseLine Array.empty


parseLine : String -> Model -> Model
parseLine line model =
  let
    rx = "^(hlf|inc|jie|jio|jmp|tpl)\\s+(a|b)?,?\\s*\\+?(-?\\d*)?"
    ms = Regex.find (Regex.AtMost 1) (Regex.regex rx) line |> List.map .submatches
  in
    case ms of
      [ [ n, r, a ] ] ->
        let
          n' =
            case n of
              Just n'' -> n''
              Nothing  -> ""
          r' =
            case r of
              Just r'' -> r''
              Nothing  -> ""
          a' =
            case a of
              Just a'' -> String.toInt a'' |> Result.withDefault 0
              Nothing  -> 0
        in
          Array.push (Instruction n' r' a') model
      _ -> model


type alias Model = Array Instruction


type alias Instruction =
  { name : String
  , reg  : String
  , arg  : Int
  }
