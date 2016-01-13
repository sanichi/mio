import Y15

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
      case year of
        2015 -> Y15.answers day input
        _ -> "year " ++ (toString year) ++ ": not available yet"

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
