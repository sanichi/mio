import Y15D01

-- Model

type alias Model = String

init : Model
init =
  "no problem yet"

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
        (2015,  1) -> Y15D01.answer(input)
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
