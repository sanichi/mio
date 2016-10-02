module Main exposing (..)

import Html exposing (..)
import Html.App exposing (programWithFlags)
import Html.Attributes exposing (..)


-- local modules

import Types exposing (Model, Flags, Focus, initModel)
import Messages exposing (Msg(..))


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
    div [] [ text (toString model) ]



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
