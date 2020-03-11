module Parsers exposing (Model, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Messages exposing (Msg(..))
import Parser as P exposing ((|.), (|=), Parser)


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
        [ input [ placeholder "input", value model.input, size 7, class "mb-2", onInput ParserUpdate ] []
        , span [] [ text " " ]
        , input [ placeholder "output", value model.output, size 30 ] []
        ]


update : String -> Model
update input =
    { input = input, output = parse input }


parser : Parser Int
parser =
    P.succeed identity
        |= P.int
        |. P.end


parse : String -> String
parse input =
    case P.run parser input of
        Ok num ->
            String.fromInt num

        Err list ->
            Debug.toString list
