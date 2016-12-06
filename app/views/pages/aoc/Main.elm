module Main exposing (..)

import Ports exposing (answers, problem)
import Y15
import Y16
import Html


-- Main


main : Program Never Model Msg
main =
    Platform.program
        { init = init
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
                ( newModel, answers newModel )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    problem Problem
