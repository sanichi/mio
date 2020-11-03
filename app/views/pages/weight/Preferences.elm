module Preferences exposing (Preferences, decode)

import Json.Decode as D exposing (Decoder, Value)


type alias Preferences =
    { debug : Bool
    , kilos : List Float
    , months : Int
    , unit : String
    }


decode : Value -> Preferences
decode value =
    D.decodeValue flagsDecoder value |> Result.withDefault default


flagsDecoder : Decoder Preferences
flagsDecoder =
    D.map4 Preferences
        (D.field "debug" D.bool |> withDefault default.debug)
        (D.field "kilos" (D.list D.float) |> withDefault default.kilos)
        (D.field "months" D.int |> withDefault default.months)
        (D.field "unit" D.string |> withDefault default.unit)


default : Preferences
default =
    Preferences False [] 4 "kg"



-- from elm-community/json-extra


withDefault : a -> Decoder a -> Decoder a
withDefault fallback decoder =
    D.maybe decoder
        |> D.map (Maybe.withDefault fallback)
