module Dni exposing (Model, cycle, decrement, increment, init, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))


type alias Model =
    { counter : Int
    , increment : Int
    }


init : Model
init =
    Model 0 1


increment : Model -> Model
increment m =
    { m | counter = m.counter + m.increment }


decrement : Model -> Model
decrement m =
    let
        update =
            if m.counter >= m.increment then
                m.counter - m.increment

            else
                0
    in
    { m | counter = update }


cycle : Model -> Model
cycle m =
    let
        update =
            case m.increment of
                1 ->
                    5

                5 ->
                    10

                10 ->
                    25

                25 ->
                    100

                100 ->
                    625

                625 ->
                    1000

                _ ->
                    1
    in
    { m | increment = update }


view : Model -> Html Msg
view m =
    div []
        [ button [ class "btn btn-success btn-sm" ] [ text (String.fromInt m.counter) ]
        , div [ class "float-right" ]
            [ button [ class "btn btn-primary btn-sm ml-1", onClick DniIncrement ] [ text "+" ]
            , button [ class "btn btn-warning btn-sm ml-1", onClick DniCycle ] [ text (String.fromInt m.increment) ]
            , button [ class "btn btn-danger btn-sm ml-1", onClick DniDecrement ] [ text "-" ]
            ]
        ]
