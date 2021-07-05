module Main exposing (initTasks, main, subscriptions, update, view)

-- local modules

import Browser
import Config
import Html exposing (Html)
import Messages exposing (Msg(..))
import Platform.Sub
import Ports
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time
import Tree
import Types exposing (Flags, Focus, Model, initModel)



-- main program


main : Program Flags Model Msg
main =
    Browser.element
        { init = \flags -> ( initModel flags, initTasks )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


initTasks : Cmd Msg
initTasks =
    Cmd.none


subscriptions : Model -> Sub Msg
subscriptions model =
    Platform.Sub.batch
        [ Ports.gotFocus GotFocus
        , Time.every Config.changePicture Tick
        ]



-- view


view : Model -> Html Msg
view model =
    let
        background =
            rect [ class "background", width (String.fromInt Config.width), height (String.fromInt Config.height) ] []

        tree =
            Tree.tree model
    in
    svg [ id "family-tree", version "1.1", viewBox Config.viewBox ] (background :: tree)



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetFocus id ->
            ( model, Ports.getFocus id )

        GotFocus focus ->
            ( { model | focus = focus, shift = 0, family = 0 }, Cmd.none )

        DisplayPerson id ->
            ( model, Ports.displayPerson id )

        Tick _ ->
            ( { model | picture = model.picture + 1 }, Cmd.none )

        ShiftLeft ->
            ( { model | shift = model.shift + Config.deltaShift }, Cmd.none )

        ShiftRight ->
            ( { model | shift = model.shift - Config.deltaShift }, Cmd.none )

        SwitchFamily index ->
            ( { model | family = index }, Cmd.none )
