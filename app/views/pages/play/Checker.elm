module Checker exposing (Model, check, error, format, init, text)

import Http exposing (Error(..))
import Json.Decode as Json exposing ((:=))
import Task exposing (Task)


type alias Model =
    String


init : Model
init =
    "No checks yet"


text : Model -> String
text checker =
    checker


check : Task Http.Error ( Bool, String )
check =
    Http.get decoder "/check.json"


decoder : Json.Decoder ( Bool, String )
decoder =
    Json.object2 (,)
        ("ok" := Json.bool)
        ("message" := Json.string)


format : Bool -> String -> String
format ok message =
    if ok then
        message
    else
        "Ruby request error: " ++ message


error : Http.Error -> String
error err =
    let
        details =
            case err of
                Timeout ->
                    "timeout"

                NetworkError ->
                    "network"

                UnexpectedPayload str ->
                    "(payload) " ++ str

                BadResponse int str ->
                    "(bad response " ++ (toString int) ++ ") " ++ str
    in
        "Elm request error: " ++ details
