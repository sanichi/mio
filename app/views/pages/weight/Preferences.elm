module Preferences exposing (Preferences, decode)

import Json.Decode as D exposing (Decoder, Value)
import BeginEnd exposing (beginDefault, endDefault)


type alias Preferences =
    { debug : Bool
    , dates : List String
    , kilos : List Float
    , beginEnd : List Int
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
    D.map8 Preferences
        (D.field "debug" D.bool |> withDefault default.debug)
        (D.field "dates" (D.list D.string) |> withDefault default.dates)
        (D.field "kilos" (D.list D.float) |> withDefault default.kilos)
        (D.field "beginEnd" (D.list D.int) |> withDefault default.beginEnd)
        (D.field "units" D.string |> withDefault default.units)
        (D.field "eventNames" (D.list D.string) |> withDefault default.eventNames)
        (D.field "eventDates" (D.list D.string) |> withDefault default.eventDates)
        (D.field "eventSpans" (D.list D.int) |> withDefault default.eventSpans)

default : Preferences
default =
    Preferences False [] [] [beginDefault, endDefault] "kg" [] [] []



-- from elm-community/json-extra


withDefault : a -> Decoder a -> Decoder a
withDefault fallback decoder =
    D.maybe decoder
        |> D.map (Maybe.withDefault fallback)
