import Y15D01
import Y15D02
import Y15D03
import Y15D04
import Y15D05
import Y15D06
import Y15D07
import Y15D08
import Y15D09
import Y15D10
import Y15D11
import Y15D12
import Y15D13
import Y15D19
import Y15D25

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
        (2015,  1) -> Y15D01.answers input
        (2015,  2) -> Y15D02.answers input
        (2015,  3) -> Y15D03.answers input
        (2015,  4) -> Y15D04.answers input
        (2015,  5) -> Y15D05.answers input
        (2015,  6) -> Y15D06.answers input
        (2015,  7) -> Y15D07.answers input
        (2015,  8) -> Y15D08.answers input
        (2015,  9) -> Y15D09.answers input
        (2015, 10) -> Y15D10.answers input
        (2015, 11) -> Y15D11.answers input
        (2015, 12) -> Y15D12.answers input
        (2015, 13) -> Y15D13.answers input
        (2015, 19) -> Y15D19.answers input
        (2015, 25) -> Y15D25.answer  input
        _ -> "year " ++ (toString year) ++ ", day " ++ (toString day) ++ ": not implemented yet"

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
