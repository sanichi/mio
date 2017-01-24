module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


-- model


type alias Model =
    Int


initModel : Model
initModel =
    1



-- main program


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init =
    ( initModel, initTasks )


initTasks : Cmd Msg
initTasks =
    Cmd.none


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- messages


type Msg
    = NoOp



-- view


view : Model -> Html Msg
view model =
    div []
        [ text (toString model) ]



-- update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []
