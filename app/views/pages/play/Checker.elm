module Checker exposing (message)

import Http
import Json.Decode as Json exposing ((:=))


message : String
message =
    let
        result =
            Json.decodeString decoder "{ \"status\" : true, \"message\" : \"Still no tickets\" }"
    in
        case result of
            Ok ( True, message ) ->
                message

            Ok ( False, error ) ->
                "Check error: " ++ error

            Err error ->
                "Elm error: " ++ error


decoder : Json.Decoder ( Bool, String )
decoder =
    Json.object2 (,)
        ("status" := Json.bool)
        ("message" := Json.string)
