module Util where

import Char
import Html.Events as Events
import Html exposing (Attribute)
import Json.Decode as Decode
import String


formContentType : List (String, String)
formContentType =
  [ ("Content-Type", "application/x-www-form-urlencoded") ]


onEnter : Signal.Address a -> a -> Attribute
onEnter address value =
  Events.on "keydown"
    (Decode.customDecoder Events.keyCode is13)
    (\_ -> Signal.message address value)


nbsp : String
nbsp =
  String.fromList [ Char.fromCode 160 ]


is13 : Int -> Result String ()
is13 code =
  if code == 13 then Ok () else Err "not the right key code"
