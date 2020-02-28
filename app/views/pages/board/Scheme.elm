module Scheme exposing (Scheme(..), dark, fromString, light)


type Scheme
    = Default
    | Blue
    | Brown
    | Green


fromString : String -> Scheme
fromString str =
    let
        low =
            String.toLower str
    in
    case low of
        "blue" ->
            Blue

        "brown" ->
            Brown

        "green" ->
            Green

        _ ->
            Default


light : Scheme -> String
light scheme =
    case scheme of
        Brown ->
            "#f0d9b5"

        Blue ->
            "#edf7ff"

        Green ->
            "#eeeed1"

        Default ->
            "#f0d9b5"


dark : Scheme -> String
dark scheme =
    case scheme of
        Brown ->
            "#b58863"

        Blue ->
            "#3b98d9"

        Green ->
            "#769656"

        Default ->
            "#b58863"
