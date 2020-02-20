module Main exposing (Model)

-- local modules

import Browser
import Html exposing (Html)
import Image exposing (fromPosition)
import Json.Decode exposing (Value, decodeValue)
import Messages exposing (Msg(..))
import Piece exposing (Colour(..))
import Position exposing (Position, initialPosition)
import Preferences exposing (defaultPreferences, flagsDecoder)
import Svg exposing (svg)
import Svg.Attributes exposing (id, version, viewBox)



-- MODEL


type alias Model =
    { position : Position
    , orientation : Colour
    }



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
            decodeValue flagsDecoder flags |> Result.withDefault defaultPreferences

        model =
            { position = initialPosition
            , orientation =
                if preferences.orientation == "black" then
                    Black

                else
                    White
            }
    in
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    svg [ id "board", version "1.1", viewBox "0 0 360 360" ] (fromPosition model.orientation model.position)



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
