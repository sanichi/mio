module Checker exposing (Model, check, fail, init, succeed, text)

import Dict exposing (Dict)
import Http exposing (Error(..))
import Json.Decode as Json exposing ((:=))
import Task exposing (Task)


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


text : Model -> String
text checker =
    let
        count =
            case Dict.get checker.lastMessage checker.history of
                Nothing ->
                    ""

                Just n ->
                    " (" ++ (toString n) ++ ")"
    in
        checker.lastMessage ++ count


check : Task Http.Error ( Bool, String )
check =
    Http.get decoder "/check.json"


decoder : Json.Decoder ( Bool, String )
decoder =
    Json.object2 (,)
        ("ok" := Json.bool)
        ("message" := Json.string)


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
                Timeout ->
                    "timeout"

                NetworkError ->
                    "network"

                UnexpectedPayload str ->
                    "(payload) " ++ str

                BadResponse int str ->
                    "(bad response " ++ (toString int) ++ ") " ++ str

        nextMessage =
            "Elm request error: " ++ details
    in
        { checker
            | lastMessage = nextMessage
            , history = updateHistory nextMessage checker.history
        }
