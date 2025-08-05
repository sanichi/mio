module Weight exposing (main)

import Browser
import Html exposing (Html)
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
    let
        model =
            Model.init <| Preferences.decode flags
    in
    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    svg [ id "weight", version "1.1", viewBox View.box ] <| View.fromModel model



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeUnits units ->
            ( Model.changeUnits units model, Cmd.none )

        ChangeBegin start ->
            ( Model.changeBegin start model, Cmd.none )

        ChangeEnd end ->
            let
                newModel =
                    Model.changeEnd end model
            in
            ( newModel, Ports.adjustBegin newModel.begin )

        UpdateCross delta ->
            ( Model.updateCross delta model, Cmd.none )

        ChangeCross point ->
            ( Model.changeCross point model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Sub Msg
subscriptions =
    Platform.Sub.batch
        [ Ports.changeUnits ChangeUnits
        , Ports.changeBegin ChangeBegin
        , Ports.changeEnd ChangeEnd
        , Ports.updateCross UpdateCross
        , Ports.changeCross ChangeCross
        ]
