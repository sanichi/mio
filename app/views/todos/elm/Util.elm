module Util exposing (enter, nbsp, httpErr, postRequest, onKeyDown)

import Char
import Html.Events as Events
import Html exposing (Attribute)
import Http exposing (Error(..))
import Json.Decode as Decode
import String


enter : Int
enter =
    13


nbsp : String
nbsp =
    String.fromList [ Char.fromCode 160 ]


httpErr : Http.Error -> String
httpErr err =
    case err of
        Timeout ->
            "timeout"

        NetworkError ->
            "network"

        UnexpectedPayload str ->
            "payload: " ++ str

        BadResponse int str ->
            "bad response (" ++ (toString int) ++ "): " ++ str


postRequest : String -> Http.Body -> Http.Request
postRequest url body =
    { verb = "POST"
    , headers = formContentType
    , url = url
    , body = body
    }


formContentType : List ( String, String )
formContentType =
    [ ( "Content-Type", "application/x-www-form-urlencoded" ) ]


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    Events.on "keydown" (Decode.map tagger Events.keyCode)



-- onEnter address value =
--     Events.on "keydown"
--         (Decode.customDecoder Events.keyCode is13)
--         (\_ -> Signal.message address value)
--
--
