module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


-- local modules

import Messages exposing (Msg(..))
import Counter
import Checker
import Randoms


-- main program


main : Program Never Model Msg
main =
    Html.program
        { init = ( initModel, initTasks )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initTasks : Cmd Msg
initTasks =
    Cmd.batch
        [ Checker.check
        , Randoms.request
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Randoms.respond ]



-- model


type alias Model =
    { counter : Counter.Model
    , checker : Checker.Model
    , randoms : Randoms.Model
    }


initModel : Model
initModel =
    { counter = Counter.init
    , checker = Checker.init
    , randoms = Randoms.init
    }



-- view


view : Model -> Html Msg
view model =
    div []
        [ panel "Counter" (Counter.view model.counter)
        , panel "Randoms" (Randoms.view model.randoms)
        , panel "Checker" (Checker.view model.checker)
        ]


panel : String -> Html Msg -> Html Msg
panel title body =
    div [ class "card mt-3" ]
        [ div [ class "card-header" ] [ text title ]
        , div [ class "card-body" ] [ body ]
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

        RandomRequest ->
            ( model, Randoms.request )

        RandomResponse num ->
            ( { model | randoms = Randoms.reset num }, Cmd.none )
