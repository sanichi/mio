import Html exposing (Html)
import Signal exposing (Address)
import Todo exposing (Todo)
import Todos exposing (Todos)

-- MODEL

type alias Model = Todos

model : Model
model =
  [ { description = "Fix water pipe", priority = 0, priority_ = "Urgent", done = True }
  , { description = "Do washing-up", priority = 2, priority_ = "Medium", done = False }
  , { description = "Paint ceiling", priority = 2, priority_ = "Medium", done = False }
  , { description = "Clean car", priority = 3, priority_ = "Low", done = False }
  ]

-- UPDATE

type Action = NoOp


update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model

-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  Todos.view model

-- WIRING

main : Signal Html
main =
  start { model = model, update = update, view = view }


type alias Config model action =
  { model : model
  , view : Address action -> model -> Html
  , update : action -> model -> model
  }


start : Config model action -> Signal Html
start config =
  let
    actions =
      Signal.mailbox Nothing

    address =
      Signal.forwardTo actions.address Just

    model' =
      Signal.foldp
        (\(Just action) model'' -> config.update action model'')
        config.model
        actions.signal
  in
    Signal.map (config.view address) model'
