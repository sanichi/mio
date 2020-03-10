module Board exposing (main)

import Browser
import Html exposing (Html)
import Image
import Json.Decode exposing (Value)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Ports
import Preferences
import Svg exposing (svg)
import Svg.Attributes exposing (id, version, viewBox)



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

        cmd =
            case model.position.error of
                Nothing ->
                    Cmd.none

                Just msg ->
                    Ports.error msg
    in
    ( model, cmd )



-- VIEW


view : Model -> Html Msg
view model =
    svg [ id "board", version "1.1", viewBox "0 0 360 360" ] <| Image.fromModel model



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FlipOrientation ->
            ( Model.flipOrientation model, Cmd.none )

        ToggleNotation ->
            ( Model.toggleNotation model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
