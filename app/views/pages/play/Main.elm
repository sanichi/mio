module Main exposing (Model, initModel, initTasks, main, panel, subscriptions, update, view)

-- local modules

import Browser
import Counter
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Encode exposing (Value)
import Messages exposing (Msg(..))
import Randoms



-- main program


main : Program Value Model Msg
main =
    Browser.element
        { init = \_ -> ( initModel, initTasks )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initTasks : Cmd Msg
initTasks =
    Cmd.batch
        [ Randoms.request ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Randoms.respond ]



-- model


type alias Model =
    { counter : Counter.Model
    , randoms : Randoms.Model
    }


initModel : Model
initModel =
    { counter = Counter.init
    , randoms = Randoms.init
    }



-- view


view : Model -> Html Msg
view model =
    div []
        [ panel "Counter" (Counter.view model.counter)
        , panel "Randoms" (Randoms.view model.randoms)
        ]


panel : String -> Html Msg -> Html Msg
panel title body =
    section [ class "card mt-3" ]
        [ div [ class "header" ] [ text title ]
        , div [ class "body" ] [ body ]
        ]



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CounterIncrement ->
            ( { model | counter = Counter.increment model.counter }, Cmd.none )

        CounterReset ->
            ( { model | counter = Counter.init }, Cmd.none )

        RandomRequest ->
            ( model, Randoms.request )

        RandomResponse num ->
            ( { model | randoms = Randoms.reset num }, Cmd.none )
