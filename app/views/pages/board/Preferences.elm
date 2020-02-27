module Preferences exposing (Preferences, decode)

import Json.Decode as D exposing (Decoder, Value)


type alias Preferences =
    { fen : String
    , orientation : String
    , notation : Bool
    , marks : List String
    }


default : Preferences
default =
    Preferences "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" "white" False []


flagsDecoder : Decoder Preferences
flagsDecoder =
    D.map4 Preferences
        (D.field "fen" D.string |> withDefault default.fen)
        (D.field "orientation" D.string |> withDefault default.orientation)
        (D.field "notation" D.bool |> withDefault default.notation)
        (D.field "marks" (D.list D.string) |> withDefault default.marks)


decode : Value -> Preferences
decode value =
    D.decodeValue flagsDecoder value |> Result.withDefault default



-- from elm-community/json-extra


withDefault : a -> Decoder a -> Decoder a
withDefault fallback decoder =
    D.maybe decoder
        |> D.map (Maybe.withDefault fallback)
