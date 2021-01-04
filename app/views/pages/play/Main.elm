module Main exposing (main)

-- local modules

import Browser
import Counter
import Dni
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Encode exposing (Value)
import Magic
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
    Randoms.request


subscriptions : Model -> Sub Msg
subscriptions model =
    Randoms.respond



-- model


type alias Model =
    { dni : Dni.Model
    , counter : Counter.Model
    , magic : Magic.Model
    , randoms : Randoms.Model
    }


initModel : Model
initModel =
    { dni = Dni.init
    , counter = Counter.init
    , magic = Magic.init
    , randoms = Randoms.init
    }



-- view


view : Model -> Html Msg
view model =
    div []
        [ panel "D‘ni" (Dni.view model.dni)
        , panel "Magic" (Magic.view model.magic)
        , panel "Randoms" (Randoms.view model.randoms)
        , panel "Counter" (Counter.view model.counter)
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

        CounterDecrement ->
            ( { model | counter = Counter.decrement model.counter }, Cmd.none )

        CounterReset ->
            ( { model | counter = Counter.init }, Cmd.none )

        DniIncrement ->
            ( { model | dni = Dni.increment model.dni }, Cmd.none )

        DniDecrement ->
            ( { model | dni = Dni.decrement model.dni }, Cmd.none )

        DniCycle ->
            ( { model | dni = Dni.cycle model.dni }, Cmd.none )

        MagicIncrement ->
            ( { model | magic = Magic.increment model.magic }, Cmd.none )

        MagicDecrement ->
            ( { model | magic = Magic.decrement model.magic }, Cmd.none )

        RandomRequest ->
            ( model, Randoms.request )

        RandomResponse num ->
            ( { model | randoms = Randoms.reset num }, Cmd.none )
