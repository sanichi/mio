module Y15D23 where

import Array exposing (Array)
import Regex
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    model1 = parseInput input
    model2 = { model1 | a = 1 }
    p1 = run model1 |> .b |> toString
    p2 = run model2 |> .b |> toString
  in
    join p1 p2


run : Model -> Model
run model =
  let
    instruction = Array.get model.i model.instructions
  in
    case instruction of
      Nothing -> model
      Just inst ->
        let
          model' =
            case inst.name of
              "inc" ->
                { model
                | i = model.i + 1
                , a = if inst.reg == "a" then model.a + 1 else model.a
                , b = if inst.reg == "b" then model.b + 1 else model.b
                }
              "hlf" ->
                { model
                | i = model.i + 1
                , a = if inst.reg == "a" then model.a // 2 else model.a
                , b = if inst.reg == "b" then model.b // 2 else model.b
                }
              "tpl" ->
                { model
                | i = model.i + 1
                , a = if inst.reg == "a" then model.a * 3 else model.a
                , b = if inst.reg == "b" then model.b * 3 else model.b
              }
              "jmp" ->
                { model
                | i = model.i + inst.arg
                }
              "jie" ->
                { model
                | i = model.i + if (inst.reg == "a" && model.a `rem` 2 == 0) || (inst.reg == "b" && model.b `rem` 2 == 0) then inst.arg else 1
                }
              "jio" ->
                { model
                | i = model.i + if (inst.reg == "a" && model.a == 1) || (inst.reg == "b" && model.b == 1) then inst.arg else 1
                }
              _     ->
                model
        in
          run model'


parseInput : String -> Model
parseInput input =
  String.split "\n" input
    |> List.filter (\l -> l /= "")
    |> List.foldl parseLine initModel


parseLine : String -> Model -> Model
parseLine line model =
  let
    rx = "^(hlf|inc|jie|jio|jmp|tpl)\\s+(a|b)?,?\\s*\\+?(-?\\d*)?"
    sm = Regex.find (Regex.AtMost 1) (Regex.regex rx) line |> List.map .submatches
  in
    case sm of
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
          { model | instructions = Array.push (Instruction n' r' a') model.instructions }
      _ -> model


initModel : Model
initModel =
  { instructions = Array.empty
  , a = 0
  , b = 0
  , i = 0
  }


type alias Model =
  { instructions: Array Instruction
  , a : Int
  , b : Int
  , i : Int
  }


type alias Instruction =
  { name : String
  , reg  : String
  , arg  : Int
  }
