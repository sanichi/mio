module Main exposing (..)

import Html exposing (Html)
import Html.App exposing (programWithFlags)
import Svg exposing (..)
import Svg.Attributes exposing (..)


-- local modules

import Types exposing (Model, Flags, Focus, initModel)
import Messages exposing (Msg(..))
import Config


-- main program


main : Program Flags
main =
    programWithFlags
        { init = (\flags -> ( initModel flags, initTasks ))
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initTasks : Cmd Msg
initTasks =
    Cmd.none


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- view


view : Model -> Html Msg
view model =
    Html.div []
        [ svg
            [ id "family-tree", version "1.1", viewBox Config.viewBox ]
            [ rect [ class "background", width (toString Config.width), height (toString Config.height) ] [] ]
        , Html.div [] [ Html.text (toString model) ]
        ]



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
