module Checker exposing (Model, check, fail, init, succeed, view)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (Error(..))
import Json.Decode as Json
import Messages exposing (Msg(..))


type alias History =
    Dict String Int


type alias Model =
    { lastMessage : String
    , history : History
    }


init : Model
init =
    { lastMessage = "No checks yet"
    , history = Dict.empty
    }


toText : Model -> String
toText checker =
    let
        count =
            case Dict.get checker.lastMessage checker.history of
                Nothing ->
                    ""

                Just n ->
                    " (" ++ (toString n) ++ ")"
    in
        checker.lastMessage ++ count


view : Model -> Html Msg
view checker =
    div []
        [ text (toText checker)
        , button [ class "btn btn-warning btn-xs pull-right", onClick CheckRequest ] [ text "↩︎" ]
        ]


check : Cmd Msg
check =
    Http.send testResponse checkRequest


checkRequest : Http.Request ( Bool, String )
checkRequest =
    Http.get "/check.json" decoder


testResponse : Result Http.Error ( Bool, String ) -> Msg
testResponse response =
    case response of
        Ok rsp ->
            CheckSucceed rsp

        Err err ->
            CheckFail err


decoder : Json.Decoder ( Bool, String )
decoder =
    Json.map2 (,)
        (Json.field "ok" Json.bool)
        (Json.field "message" Json.string)


succeed : Model -> Bool -> String -> Model
succeed checker ok message =
    let
        nextMessage =
            if ok then
                message
            else
                "Ruby request error: " ++ message
    in
        { checker
            | lastMessage = nextMessage
            , history = updateHistory nextMessage checker.history
        }


fail : Model -> Http.Error -> Model
fail checker err =
    let
        details =
            case err of
                BadUrl str ->
                    "(url) " ++ str

                Timeout ->
                    "timeout"

                NetworkError ->
                    "network"

                BadPayload str rsp ->
                    "(payload) " ++ str ++ " (" ++ toString rsp ++ ")"

                BadStatus rsp ->
                    "(response) " ++ toString rsp

        nextMessage =
            "Elm request error: " ++ details
    in
        { checker
            | lastMessage = nextMessage
            , history = updateHistory nextMessage checker.history
        }


updateHistory : String -> History -> History
updateHistory message history =
    let
        update count =
            case count of
                Nothing ->
                    Just 1

                Just n ->
                    Just (n + 1)
    in
        Dict.update message update history
