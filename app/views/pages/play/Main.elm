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
        { init = ( init, Cmd.none )
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
        [ panel "Counter" (view_counter model)
        , panel "Checker" (view_checker model)
        ]


view_counter : Model -> Html Msg
view_counter model =
    div [ class "row" ]
        [ div [ class "col-xs-4 text-center" ] [ button [ class "btn btn-danger btn-sm", onClick CounterIncrement ] [ text "+" ] ]
        , div [ class "col-xs-4 text-center" ] [ button [ class "btn btn-success btn-lg" ] [ text (Counter.text model.counter) ] ]
        , div [ class "col-xs-4 text-center" ] [ button [ class "btn btn-warning btn-sm", onClick CounterReset ] [ text "↩︎" ] ]
        ]


view_checker : Model -> Html Msg
view_checker model =
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CounterIncrement ->
            ( { model | counter = Counter.increment model.counter }, Cmd.none )

        CounterReset ->
            ( { model | counter = Counter.init }, Cmd.none )

        CheckRequest ->
            ( model, Task.perform CheckFail CheckSucceed Checker.check )

        CheckFail err ->
            ( { model | checker = (Checker.error err) }, Cmd.none )

        CheckSucceed ( ok, message ) ->
            ( { model | checker = (Checker.format ok message) }, Cmd.none )
