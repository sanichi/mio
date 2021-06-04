module Counter exposing (Model, decrement, increment, init, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))


type alias Model =
    Int


init : Model
init =
    0


increment : Model -> Model
increment counter =
    counter + 1


decrement : Model -> Model
decrement counter =
    counter - 1


view : Model -> Html Msg
view counter =
    div []
        [ button [ class "btn btn-success btn-sm" ] [ text (String.fromInt counter) ]
        , div [ class "float-end" ]
            [ button [ class "btn btn-primary btn-sm ms-1", onClick CounterIncrement ] [ text "+" ]
            , button [ class "btn btn-warning btn-sm ms-1", onClick CounterReset ] [ text "0" ]
            , button [ class "btn btn-danger btn-sm ms-1", onClick CounterDecrement ] [ text "-" ]
            ]
        ]
