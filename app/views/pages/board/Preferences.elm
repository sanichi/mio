module Preferences exposing (Preferences, decode)

import Json.Decode as D exposing (Decoder, Value)


type alias Preferences =
    { fen : String
    , orientation : String
    , dots : List String
    , crosses : List String
    , stars : List String
    , notation : Bool
    }


default : Preferences
default =
    Preferences "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" "white" [] [] [] False


flagsDecoder : Decoder Preferences
flagsDecoder =
    D.map6 Preferences
        (D.field "fen" D.string |> withDefault default.fen)
        (D.field "orientation" D.string |> withDefault default.orientation)
        (D.field "dots" (D.list D.string) |> withDefault default.dots)
        (D.field "crosses" (D.list D.string) |> withDefault default.crosses)
        (D.field "stars" (D.list D.string) |> withDefault default.stars)
        (D.field "notation" D.bool |> withDefault default.notation)


decode : Value -> Preferences
decode value =
    D.decodeValue flagsDecoder value |> Result.withDefault default



-- from elm-community/json-extra


withDefault : a -> Decoder a -> Decoder a
withDefault fallback decoder =
    D.maybe decoder
        |> D.map (Maybe.withDefault fallback)
