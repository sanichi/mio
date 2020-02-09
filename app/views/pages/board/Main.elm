module Main exposing (Model)

-- local modules

import Browser
import Html exposing (Html)
import Messages exposing (Msg(..))
import Svg exposing (..)
import Svg.Attributes exposing (..)



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initModel, initTasks )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initTasks : Cmd Msg
initTasks =
    Cmd.none


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MODEL


type alias Model =
    String


initModel : Model
initModel =
    "Board"



-- VIEW


view : Model -> Html Msg
view model =
    let
        background =
            rect [ fill "red", width "1000", height "1000" ] []
    in
    svg [ id "board", version "1.1", viewBox "0 0 1000 1000" ] [ background ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
