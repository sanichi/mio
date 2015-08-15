module Counter where

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


-- MODEL

type alias Model = Int


-- UPDATE

type Action = Increment | Decrement

update : Action -> Model -> Model
update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  table [ class "table table-bordered table-striped" ]
    [ tbody [ ]
        [ tr [ ]
          [ td
              [ class "text-center col-md-1", onClick address Decrement ]
              [ span [ class "btn btn-danger btn-xs" ] [ text "-" ] ]
          , td
              [ class "text-center col-md-10"]
              [ span [ class "btn btn-info btn-xs" ] [ text (toString model) ] ]
          , td
              [ class "text-center col-md-1", onClick address Increment ]
              [ span [ class "btn btn-success btn-xs" ] [ text "+"] ]
          ]
        ]
    ]
