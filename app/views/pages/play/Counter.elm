module Counter exposing (Model, increment, init, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))


type alias Model =
    Int


init : Model
init =
    0


increment : Model -> Model
increment counter =
    counter + 1


view : Model -> Html Msg
view counter =
    div []
        [ button [ class "btn btn-success btn-sm" ] [ text (String.fromInt counter) ]
        , div [ class "float-right" ]
            [ button [ class "btn btn-danger btn-sm", onClick CounterIncrement ] [ text "+" ]
            , span [] [ text " " ]
            , button [ class "btn btn-warning btn-sm", onClick CounterReset ] [ text "↩︎" ]
            ]
        ]
