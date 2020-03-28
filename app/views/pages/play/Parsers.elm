module Parsers exposing (Model, init, update, view)

import Advanced.JustInt as AJI exposing (parse, title)
import Html exposing (Html, div, form, textarea)
import Html.Attributes exposing (class, placeholder, rows, value)
import Html.Events exposing (onInput)
import Messages exposing (Msg(..))
import Parsers.ChessMovement as CM exposing (parse, title)
import Parsers.ChessSquare as CS exposing (parse, title)
import Parsers.IntLoop as IL exposing (parse, title)
import Parsers.JavascriptVariable as JV exposing (parse, title)
import Parsers.ListOfInts as LI exposing (parse, title)
import Parsers.PairOfInts as PI exposing (parse, title)
import Parsers.PawnLoop as PL exposing (parse, title)
import Parsers.PieceMove as PM exposing (parse, title)
import Parsers.SequenceOfInts as SI exposing (parse, title)


type alias Model =
    String


init : Model
init =
    ""


view : Model -> Html Msg
view model =
    div [ class "offset-1 col-10" ]
        [ form [ class "crud" ]
            [ textarea [ rows 5, placeholder CM.title, value model, onInput ParserUpdate ] []
            , textarea [ rows 5, placeholder "output", value (CM.parse model) ] []
            ]
        ]


update : String -> Model
update input =
    input
