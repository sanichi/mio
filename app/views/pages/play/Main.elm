module Main exposing (..)

import Html exposing (..)
import Html.App exposing (program)
import Html.Attributes exposing (..)


-- local modules

import Messages exposing (Msg(..))
import Counter
import Checker


-- main program


main : Program Never
main =
    program
        { init = ( init, Checker.check )
        , view = view
        , update = update
        , subscriptions = (\model -> Sub.none)
        }



-- model


type alias Model =
    { counter : Counter.Model
    , checker : Checker.Model
    }


init : Model
init =
    { counter = Counter.init
    , checker = Checker.init
    }



-- view


view : Model -> Html Msg
view model =
    div []
        [ panel "Counter" (Counter.view model.counter)
        , panel "Checker" (Checker.view model.checker)
        ]


panel : String -> Html Msg -> Html Msg
panel title body =
    div [ class "panel panel-default" ]
        [ div [ class "panel-heading" ] [ div [ class "panel-title" ] [ text title ] ]
        , div [ class "panel-body" ] [ body ]
        ]



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CounterIncrement ->
            ( { model | counter = Counter.increment model.counter }, Cmd.none )

        CounterReset ->
            ( { model | counter = Counter.init }, Cmd.none )

        CheckRequest ->
            ( model, Checker.check )

        CheckFail err ->
            ( { model | checker = (Checker.fail model.checker err) }, Cmd.none )

        CheckSucceed ( ok, message ) ->
            ( { model | checker = (Checker.succeed model.checker ok message) }, Cmd.none )
