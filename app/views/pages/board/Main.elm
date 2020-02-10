module Main exposing (Model)

-- local modules

import Browser
import Html exposing (Html)
import Image exposing (Orientation(..), fromPosition)
import Messages exposing (Msg(..))
import Position exposing (Position, initialPosition)
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
    { pos : Position
    , ori : Orientation
    }


initModel : Model
initModel =
    { pos = initialPosition
    , ori = Up
    }



-- VIEW


view : Model -> Html Msg
view model =
    svg [ id "board", version "1.1", viewBox "0 0 360 360" ] (fromPosition model.ori model.pos)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
