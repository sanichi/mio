module Parsers exposing (Model, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Messages exposing (Msg(..))


type alias Model =
    { input : String
    , output : String
    }


init : Model
init =
    { input = ""
    , output = ""
    }


view : Model -> Html Msg
view model =
    div []
        [ input [ placeholder "input", value model.input, size 7, onInput ParserUpdate ] []
        , span [] [ text " " ]
        , input [ placeholder "output", value model.output, size 40 ] []
        ]


update : String -> Model
update input =
    { input = input, output = String.reverse input }
