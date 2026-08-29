module Preferences exposing (Preferences, decode)

import Json.Decode as D exposing (Decoder, Value, bool, float, int, list, string)
import Json.Decode.Pipeline exposing (required)


type alias Preferences =
    { debug : Bool
    , begin : Int
    , stationNames : List String
    , stationColours : List String
    , stations : List Int
    , dates : List String
    , prices : List Float
    }


decode : Value -> Preferences
decode value =
    D.decodeValue flagsDecoder value |> Result.withDefault default


flagsDecoder : Decoder Preferences
flagsDecoder =
    D.succeed Preferences
        |> required "debug" bool
        |> required "begin" int
        |> required "stationNames" (list string)
        |> required "stationColours" (list string)
        |> required "stations" (list int)
        |> required "dates" (list string)
        |> required "prices" (list float)


default : Preferences
default =
    Preferences False 2 [] [] [] [] []
