module Main exposing (..)

import Html exposing (..)
import Html.App exposing (program)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


main : Program Never
main =
    program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = (\model -> Sub.none)
        }


type alias Model =
    Int


initialModel : Model
initialModel =
    0


view : Model -> Html Msg
view model =
    div [ class "panel panel-default" ]
        [ div [ class "panel-heading" ] [ div [ class "panel-title" ] [ text "Counter" ] ]
        , div [ class "panel-body" ]
            [ div [ class "row" ]
                [ div [ class "col-xs-4 text-center" ] [ button [ class "btn btn-danger btn-sm", onClick Increment ] [ text "+" ] ]
                , div [ class "col-xs-4 text-center" ] [ button [ class "btn btn-success btn-lg" ] [ text (toString model) ] ]
                , div [ class "col-xs-4 text-center" ] [ button [ class "btn btn-warning btn-sm", onClick Reset ] [ text "↩︎" ] ]
                ]
            ]
        ]


type Msg
    = Increment
    | Reset


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( model + 1, Cmd.none )

        Reset ->
            ( 0, Cmd.none )
