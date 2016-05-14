import Y15
import Ports exposing (answer, problem)

-- Model

type alias Model = String

init : (Model, Cmd Msg)
init =
  ("no problem", Cmd.none)

-- Update

type Msg
  = Problem (Int, Int, String)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Problem (year, day, input) ->
      let
        newModel =
          case year of
            2015 -> Y15.answers day input
            _ -> "year " ++ (toString year) ++ ": not available yet"
      in
        (newModel, answer newModel)

-- Subscriptions

subscriptions: Model -> Sub Msg
subscriptions model =
  problem Problem
