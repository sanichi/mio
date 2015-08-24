import Html exposing (Html)
import Signal exposing (Address)
import Todo exposing (update, view)


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

    model =
      Signal.foldp
        (\(Just action) model -> config.update action model)
        config.model
        actions.signal
  in
    Signal.map (config.view address) model


model =
  [ { description = "Fix water pipe", priority = 0, priority_desc = "Urgent", done = True }
  , { description = "Do washing-up", priority = 2, priority_desc = "Medium", done = False }
  , { description = "Paint ceiling", priority = 2, priority_desc = "Medium", done = False }
  , { description = "Clean car", priority = 3, priority_desc = "Low", done = False }
  ]


main =
  start { model = model, update = update, view = view }
