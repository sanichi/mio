import Y15

-- Model

type alias Model = String

init : (Model, Cmd Msg)
init =
  ("no problem", Cmd.none)

-- Update

type Msg
  = Problem (Int, Int, String)
  | Answer

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

-- Subscriptions and ports

port problem : ((Int, Int, String) -> msg) -> Sub msg

subscriptions: Model -> Sub Msg
subscriptions model =
  problem Problem

port answer : String -> Cmd msg
