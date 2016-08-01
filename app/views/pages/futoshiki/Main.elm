module Main exposing (..)

import Html exposing (Html)
import Html.App exposing (beginnerProgram)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Model exposing (Model, init)
import XY


main : Program Never
main =
    beginnerProgram { model = init, view = view, update = update }


view : Model -> Html msg
view model =
    let
        attributes =
            [ id "futoshiki", version "1.1", viewBox XY.viewBox ]

        r =
            toString XY.bg_radius

        common =
            [ Svg.title [] [ text "Futoshiki" ]
            , desc [] [ text "Interactive Futoshiki solver" ]
            , rect [ width "100%", height "100%", rx r, ry r, class "background" ] []
            ]

        elements =
            common ++ Model.render model
    in
        svg attributes elements


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model

        Decrement ->
            model
