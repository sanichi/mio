module Preferences exposing (Preferences, decode)

import Json.Decode as D exposing (Decoder, Value)


type alias Preferences =
    { unit : String
    }


decode : Value -> Preferences
decode value =
    D.decodeValue flagsDecoder value |> Result.withDefault default


flagsDecoder : Decoder Preferences
flagsDecoder =
    D.map Preferences
        (D.field "unit" D.string |> withDefault default.unit)


default : Preferences
default =
    Preferences "kg"



-- from elm-community/json-extra


withDefault : a -> Decoder a -> Decoder a
withDefault fallback decoder =
    D.maybe decoder
        |> D.map (Maybe.withDefault fallback)
