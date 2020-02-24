module Preferences exposing (decode)

import Json.Decode as D exposing (Decoder, Value)


type alias Preferences =
    { orientation : String
    , fen : String
    , dots : List String
    }


defaultOrientation : String
defaultOrientation =
    "white"


defaultFen : String
defaultFen =
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"


defaultDots : List String
defaultDots =
    []


defaultPreferences =
    Preferences defaultOrientation defaultFen defaultDots


flagsDecoder : Decoder Preferences
flagsDecoder =
    D.map3 Preferences
        (D.field "orientation" D.string |> withDefault defaultOrientation |> D.map String.toLower)
        (D.field "fen" D.string |> withDefault defaultFen)
        (D.field "dots" (D.list D.string) |> withDefault defaultDots)


decode : Value -> Preferences
decode flags =
    D.decodeValue flagsDecoder flags |> Result.withDefault defaultPreferences



-- from elm-community/json-extra


withDefault : a -> Decoder a -> Decoder a
withDefault fallback decoder =
    D.maybe decoder
        |> D.map (Maybe.withDefault fallback)
