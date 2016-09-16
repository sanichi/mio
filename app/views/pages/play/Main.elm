module Main exposing (..)

import Html exposing (..)
import Html.App exposing (program)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Task
import Counter
import Checker


main : Program Never
main =
    program
        { init = ( init, checkRequest )
        , view = view
        , update = update
        , subscriptions = (\model -> Sub.none)
        }


type alias Model =
    { counter : Counter.Model
    , checker : Checker.Model
    }


init : Model
init =
    { counter = Counter.init
    , checker = Checker.init
    }


view : Model -> Html Msg
view model =
    div []
        [ panel "Counter" (viewCounter model)
        , panel "Checker" (viewChecker model)
        ]


viewCounter : Model -> Html Msg
viewCounter model =
    div [ class "row" ]
        [ div [ class "col-xs-4 text-center" ] [ button [ class "btn btn-danger btn-sm", onClick CounterIncrement ] [ text "+" ] ]
        , div [ class "col-xs-4 text-center" ] [ button [ class "btn btn-success btn-lg" ] [ text (Counter.text model.counter) ] ]
        , div [ class "col-xs-4 text-center" ] [ button [ class "btn btn-warning btn-sm", onClick CounterReset ] [ text "↩︎" ] ]
        ]


viewChecker : Model -> Html Msg
viewChecker model =
    p []
        [ text (Checker.text model.checker)
        , button [ class "btn btn-warning btn-xs pull-right", onClick CheckRequest ] [ text "↩︎" ]
        ]


panel : String -> Html Msg -> Html Msg
panel title body =
    div [ class "panel panel-default" ]
        [ div [ class "panel-heading" ] [ div [ class "panel-title" ] [ text title ] ]
        , div [ class "panel-body" ] [ body ]
        ]


type Msg
    = CounterIncrement
    | CounterReset
    | CheckRequest
    | CheckFail Http.Error
    | CheckSucceed ( Bool, String )


checkRequest : Cmd Msg
checkRequest =
    Task.perform CheckFail CheckSucceed Checker.check


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CounterIncrement ->
            ( { model | counter = Counter.increment model.counter }, Cmd.none )

        CounterReset ->
            ( { model | counter = Counter.init }, Cmd.none )

        CheckRequest ->
            ( model, checkRequest )

        CheckFail err ->
            ( { model | checker = (Checker.fail model.checker err) }, Cmd.none )

        CheckSucceed ( ok, message ) ->
            ( { model | checker = (Checker.succeed model.checker ok message) }, Cmd.none )
