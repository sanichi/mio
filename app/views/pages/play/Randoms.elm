module Randoms exposing (Model, init, request, reset, respond, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))
import Ports


type alias Model =
    Int


init : Model
init =
    0


reset : Model -> Model
reset rand =
    rand


view : Model -> Html Msg
view rand =
    div []
        [ button [ class "btn btn-success btn-sm" ] [ text (String.fromInt rand) ]
        , button [ class "btn btn-warning btn-sm float-end", onClick RandomRequest ] [ text "R" ]
        ]


request : Cmd Msg
request =
    Ports.random_request ()


respond : Sub Msg
respond =
    Ports.random_response RandomResponse
