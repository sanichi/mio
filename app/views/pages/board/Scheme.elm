module Scheme exposing (Scheme, black, fromString, white)

import Regex as R


type alias Scheme =
    ( String, String )


default : Scheme
default =
    ( "#f0d9b5", "#b58863" )


fromString : String -> Scheme
fromString str =
    let
        low =
            String.toLower str
    in
    case low of
        "blue" ->
            ( "#edf7ff", "#3b98d9" )

        "brown" ->
            ( "#f0d9b5", "#b58863" )

        "green" ->
            ( "#eeeed1", "#769656" )

        "default" ->
            default

        _ ->
            let
                colours =
                    Maybe.withDefault R.never <| R.fromString "^(#[0-9a-f]{3}|#[0-9a-f]{6})(#[0-9a-f]{3}|#[0-9a-f]{6})$"

                matches =
                    R.find colours low |> List.map .submatches
            in
            case matches of
                [ [ Just light, Just dark ] ] ->
                    ( light, dark )

                _ ->
                    default


white : Scheme -> String
white scheme =
    Tuple.first scheme


black : Scheme -> String
black scheme =
    Tuple.second scheme
