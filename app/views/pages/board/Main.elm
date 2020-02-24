module Main exposing (main)

-- local modules

import Browser
import Html exposing (Html)
import Image
import Json.Decode exposing (Value)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Piece exposing (Colour(..))
import Position exposing (Position)
import Preferences
import Square exposing (Square)
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


init : Value -> ( Model, Cmd Msg )
init flags =
    let
        preferences =
            Preferences.decode flags

        orientation =
            if preferences.orientation == "black" then
                Black

            else
                White

        position =
            case Position.fromFen preferences.fen of
                Ok pos ->
                    pos

                Err ( current, consumed, remaining ) ->
                    current

        dots =
            Square.fromList preferences.dots

        model =
            { position = position, orientation = orientation, dots = dots }
    in
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    Image.fromModel model
        |> svg [ id "board", version "1.1", viewBox "0 0 360 360" ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Flip ->
            let
                orientation =
                    if model.orientation == White then
                        Black

                    else
                        White
            in
            ( { model | orientation = orientation }, Cmd.none )
