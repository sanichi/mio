module Checker exposing (Model, check, fail, init, succeed, text)

import Dict exposing (Dict)
import Http exposing (Error(..))
import Json.Decode as Json exposing ((:=))
import Task exposing (Task)


type alias Model =
    { last_message : String
    , history : Dict String Int
    }


init : Model
init =
    { last_message = "No checks yet"
    , history = Dict.empty
    }


text : Model -> String
text checker =
    let
        count =
            case Dict.get checker.last_message checker.history of
                Nothing ->
                    ""

                Just n ->
                    " (" ++ (toString n) ++ ")"
    in
        checker.last_message ++ count


check : Task Http.Error ( Bool, String )
check =
    Http.get decoder "/check.json"


decoder : Json.Decoder ( Bool, String )
decoder =
    Json.object2 (,)
        ("ok" := Json.bool)
        ("message" := Json.string)


succeed : Model -> Bool -> String -> Model
succeed checker ok message =
    let
        next_message =
            if ok then
                message
            else
                "Ruby request error: " ++ message

        updateHistory count =
            case count of
                Nothing ->
                    Just 1

                Just n ->
                    Just (n + 1)
    in
        { checker
            | last_message = next_message
            , history = Dict.update next_message updateHistory checker.history
        }


fail : Model -> Http.Error -> Model
fail checker err =
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
        { checker | last_message = "Elm request error: " ++ details }
