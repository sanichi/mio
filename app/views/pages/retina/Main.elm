module Main exposing (..)

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)


-- local modules

import Config
import Messages exposing (Msg(..))
import Retina exposing (Retina)


-- main program


main : Program Never Retina Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init =
    ( Retina.init, initTasks )


initTasks : Cmd Msg
initTasks =
    Config.getRandomVals


subscriptions : Retina -> Sub Msg
subscriptions model =
    Sub.none



-- view


view : Retina -> Html Msg
view retina =
    let
        background =
            rect [ class "background", width (toString Config.width), height (toString Config.height) ] []

        cells =
            Retina.view retina
    in
        svg [ id "retina", version "1.1", viewBox Config.viewBox ] (background :: cells)



-- update


update : Msg -> Retina -> ( Retina, Cmd Msg )
update msg retina =
    case msg of
        NoOp ->
            retina ! []

        NewValues vals ->
            Retina.update vals retina ! []
