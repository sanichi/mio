module Parsers exposing (Model, init, update, view)

import Html exposing (Html, div, form, textarea)
import Html.Attributes exposing (class, placeholder, rows, value)
import Html.Events exposing (onInput)
import Messages exposing (Msg(..))
import Parsers.JavascriptVariable as JV exposing (parse, title)
import Parsers.ListOfInts as LI exposing (parse, title)
import Parsers.PairOfInts as PI exposing (parse, title)
import Parsers.RankAndFile as RF exposing (parse, title)


type alias Model =
    String


init : Model
init =
    ""


view : Model -> Html Msg
view model =
    div [ class "offset-1 col-10" ]
        [ form [ class "crud" ]
            [ textarea [ rows 5, placeholder LI.title, value model, onInput ParserUpdate ] []
            , textarea [ rows 5, placeholder "output", value (LI.parse model) ] []
            ]
        ]


update : String -> Model
update input =
    input
