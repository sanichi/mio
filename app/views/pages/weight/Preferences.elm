module Preferences exposing (Preferences, decode)

import Json.Decode as D exposing (Decoder, Value)


type alias Preferences =
    { fen : String
    , orientation : String
    , notation : Bool
    , marks : List String
    , scheme : String
    }


decode : Value -> Preferences
decode value =
    D.decodeValue flagsDecoder value |> Result.withDefault default


flagsDecoder : Decoder Preferences
flagsDecoder =
    D.map5 Preferences
        (D.field "fen" D.string |> withDefault default.fen)
        (D.field "orientation" D.string |> withDefault default.orientation)
        (D.field "notation" D.bool |> withDefault default.notation)
        (D.field "marks" (D.list D.string) |> withDefault default.marks)
        (D.field "scheme" D.string |> withDefault default.scheme)


default : Preferences
default =
    Preferences "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" "white" False [] "default"



-- from elm-community/json-extra


withDefault : a -> Decoder a -> Decoder a
withDefault fallback decoder =
    D.maybe decoder
        |> D.map (Maybe.withDefault fallback)
