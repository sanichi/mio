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
    div [ class "offset-1 col-10" ]
        [ Html.form [ class "crud" ]
            [ textarea [ rows 5, placeholder "input", value model.input, onInput ParserUpdate ] []
            , textarea [ rows 5, placeholder "output", value model.output ] []
            ]
        ]


update : String -> Model
update input =
    { input = input, output = parse input }


type alias Pair =
    ( Int, Int )


parser : Parser Pair
parser =
    P.succeed Tuple.pair
        |. P.spaces
        |= P.int
        |. P.spaces
        |. P.symbol ","
        |. P.spaces
        |= P.int
        |. P.spaces
        |. P.end


parse : String -> String
parse input =
    case P.run parser input of
        Ok good ->
            Debug.toString good

        Err list ->
            Debug.toString list
