module Magic exposing (Model, decrement, increment, init, view)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))


type alias Model =
    { index : Int
    , magic : Array String
    }


init : Model
init =
    [ "0", "53", "371", "5141", "99481", "8520280" ]
        |> Array.fromList
        |> Model 0


increment : Model -> Model
increment model =
    if high model then
        model

    else
        { model | index = model.index + 1 }


decrement : Model -> Model
decrement model =
    if low model then
        model

    else
        { model | index = model.index - 1 }


view : Model -> Html Msg
view model =
    let
        upButton =
            if high model then
                [ class "btn btn-secondary btn-sm ml-1" ]

            else
                [ class "btn btn-primary btn-sm ml-1", onClick MagicIncrement ]

        downButton =
            if low model then
                [ class "btn btn-secondary btn-sm ml-1" ]

            else
                [ class "btn btn-danger btn-sm ml-1", onClick MagicDecrement ]

        magic =
            model.magic
                |> Array.get model.index
                |> Maybe.withDefault "0"

        pair =
            magic ++ " ↔︎ " ++ String.reverse magic
    in
    div []
        [ button [ class "btn btn-success btn-sm" ] [ text pair ]
        , div [ class "float-right" ]
            [ button upButton [ text "↑" ]
            , button downButton [ text "↓" ]
            ]
        ]


high : Model -> Bool
high m =
    m.index + 1 == Array.length m.magic


low : Model -> Bool
low m =
    m.index == 0
