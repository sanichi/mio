module Main exposing (..)

import Html exposing (..)
import Html.App exposing (program)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


main : Program Never
main =
    program
        { init = ( init, Cmd.none )
        , view = view
        , update = update
        , subscriptions = (\model -> Sub.none)
        }


type alias Model =
    { counter : Int }


init : Model
init =
    { counter = 0 }


view : Model -> Html Msg
view model =
    let
        counter =
            div [ class "row" ]
                [ div [ class "col-xs-4 text-center" ] [ button [ class "btn btn-danger btn-sm", onClick Increment ] [ text "+" ] ]
                , div [ class "col-xs-4 text-center" ] [ button [ class "btn btn-success btn-lg" ] [ text (toString model.counter) ] ]
                , div [ class "col-xs-4 text-center" ] [ button [ class "btn btn-warning btn-sm", onClick Reset ] [ text "↩︎" ] ]
                ]
    in
        div []
            [ panel "Counter" counter ]


panel : String -> Html Msg -> Html Msg
panel title body =
    div [ class "panel panel-default" ]
        [ div [ class "panel-heading" ] [ div [ class "panel-title" ] [ text title ] ]
        , div [ class "panel-body" ] [ body ]
        ]


type Msg
    = Increment
    | Reset


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }, Cmd.none )

        Reset ->
            ( { model | counter = 0 }, Cmd.none )
