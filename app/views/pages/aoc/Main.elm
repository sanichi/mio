module Main exposing (..)

import Html exposing (Html, text)
import Html.App as App
import Ports exposing (answer, problem)
import Y15
import Y16


-- Main


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Model


type alias Model =
    String


init : ( Model, Cmd Msg )
init =
    ( "no problem", Cmd.none )



-- Update


type Msg
    = Problem ( Int, Int, String )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Problem ( year, day, input ) ->
            let
                newModel =
                    case year of
                        2015 ->
                            Y15.answers day input

                        2016 ->
                            Y16.answers day input

                        _ ->
                            "year " ++ (toString year) ++ ": not available yet"
            in
                ( newModel, answer newModel )



-- View


view : Model -> Html Msg
view model =
    text model



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    problem Problem
