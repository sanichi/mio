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
        , subscriptions = subscriptions
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

        ChangeStart start ->
            ( Model.changeStart start model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Platform.Sub.batch
        [ Ports.changeUnits ChangeUnits
        , Ports.changeStart ChangeStart
        ]
