module Preferences exposing (Preferences, decode)

import Json.Decode as D exposing (Decoder, Value, bool, float, int, list, string)
import Json.Decode.Pipeline exposing (required)


type alias Preferences =
    { debug : Bool
    , dates : List String
    , kilos : List Float
    , begin : Int
    , end : Int
    , units : String
    , eventNames : List String
    , eventDates : List String
    , eventSpans : List Int
    }


decode : Value -> Preferences
decode value =
    D.decodeValue flagsDecoder value |> Result.withDefault default


flagsDecoder : Decoder Preferences
flagsDecoder =
    D.succeed Preferences
        |> required "debug" bool
        |> required "dates" (list string)
        |> required "kilos" (list float)
        |> required "begin" int
        |> required "end" int
        |> required "units" string
        |> required "eventNames" (list string)
        |> required "eventDates" (list string)
        |> required "eventSpans" (list int)


default : Preferences
default =
    Preferences False [] [] 2 0 "kg" [] [] []


-- from elm-community/json-extra


withDefault : a -> Decoder a -> Decoder a
withDefault fallback decoder =
    D.maybe decoder
        |> D.map (Maybe.withDefault fallback)
