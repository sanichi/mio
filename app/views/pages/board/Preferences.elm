module Preferences exposing (defaultFen, defaultPreferences, flagsDecoder)

import Json.Decode exposing (Decoder, field, map, map2, maybe, string, succeed)


type alias Preferences =
    { orientation : String
    , fen : String
    }


defaultOrientation : String
defaultOrientation =
    "white"


defaultFen : String
defaultFen =
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"


defaultPreferences =
    Preferences defaultOrientation defaultFen


flagsDecoder : Decoder Preferences
flagsDecoder =
    map2 Preferences
        (field "orientation" string |> withDefault defaultOrientation |> map String.toLower)
        (field "fen" string |> withDefault defaultFen)



-- from elm-community/json-extra


withDefault : a -> Decoder a -> Decoder a
withDefault fallback decoder =
    maybe decoder
        |> map (Maybe.withDefault fallback)
