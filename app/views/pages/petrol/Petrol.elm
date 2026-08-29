module Petrol exposing (main)

import Browser
import Html as H exposing (Html)
import Json.Decode exposing (Value)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Platform.Sub
import Ports
import Preferences
import Svg exposing (svg)
import Svg.Attributes exposing (id, version, viewBox)
import View



-- MAIN


main : Program Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> subscriptions
        }



-- INIT


init : Value -> ( Model, Cmd Msg )
init flags =
    ( Model.init <| Preferences.decode flags, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    H.div []
        [ svg [ id "petrol-graph", version "1.1", viewBox View.box ] <| View.fromModel model
        , View.legend model
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeBegin begin ->
            ( Model.changeBegin begin model, Cmd.none )

        ChangeCross point ->
            ( Model.changeCross point model, Cmd.none )

        UpdateCross delta ->
            ( Model.updateCross delta model, Cmd.none )

        ToggleStation index ->
            ( Model.toggleStation index model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Sub Msg
subscriptions =
    Platform.Sub.batch
        [ Ports.changeBegin ChangeBegin
        , Ports.changeCross ChangeCross
        , Ports.updateCross UpdateCross
        ]
