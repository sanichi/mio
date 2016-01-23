module Y15D23 where

import Dict exposing (Dict)
import Regex
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    model = parseInput input
    p1 = List.length model |> toString
    p2 = model |> toString
  in
    join p1 p2


parseInput : String -> Model
parseInput input =
  String.split "\n" input
    |> List.filter (\l -> l /= "")
    |> List.foldl parseLine [ ]


parseLine : String -> Model -> Model
parseLine line model =
  let
    rx = "^(hlf|inc|jie|jio|jmp|tpl)\\s+(a|b)?,?\\s*\\+?(-?\\d*)?"
    ms = Regex.find (Regex.AtMost 1) (Regex.regex rx) line |> List.map .submatches
  in
    case ms of
      [ [ Just n, Just r, Just a ] ] ->
        let
          i = String.toInt a |> Result.withDefault 0
        in
          Instruction n r i :: model
      [ [ Just n, Just r, Nothing ] ] ->
        Instruction n r 0 :: model
      [ [ Just n, Nothing, Just a ] ] ->
        let
          i = String.toInt a |> Result.withDefault 0
        in
          Instruction n "x" i :: model
      _ -> model


type alias Model = List Instruction


type alias Instruction =
  { name : String
  , reg  : String
  , arg  : Int
  }
