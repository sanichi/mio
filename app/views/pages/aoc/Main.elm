import Y15D01
import Y15D02
import Y15D03
import Y15D05
import Y15D19

-- Model

type alias Model = String

init : Model
init =
  "no problem"

-- Update

type Action
  = NoOp
  | Problem (Int, Int, String)

update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    Problem (year, day, input) ->
      case (year, day) of
        (2015,  1) -> join (Y15D01.part1 input) (Y15D01.part2 input)
        (2015,  2) -> join (Y15D02.part1 input) (Y15D02.part2 input)
        (2015,  3) -> join (Y15D03.part1 input) (Y15D03.part2 input)
        (2015,  5) -> join (Y15D05.part1 input) (Y15D05.part2 input)
        (2015, 19) -> join (Y15D19.part1 input) (Y15D19.part2 input)
        _ -> "year " ++ (toString year) ++ ", day " ++ (toString day) ++ ": not implemented yet"

join : String -> String -> String
join p1 p2 =
  p1 ++ " " ++ p2

-- Signals

model : Signal Model
model =
  Signal.foldp update init actions

actions : Signal Action
actions =
  Signal.map Problem problem

-- Ports

port problem : Signal (Int, Int, String)

port answer : Signal Model
port answer =
  model
