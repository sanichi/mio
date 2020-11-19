module Units exposing (Unit(..), delta, format, fromString, toString)

import Regex exposing (Regex)


type Unit
    = Kg
    | Lb
    | St


delta : Unit -> Float -> Float
delta u w =
    let
        large =
            w > 10.0
    in
    case u of
        Kg ->
            if large then
                5.0

            else
                1.0

        Lb ->
            if large then
                10.0 / kg2lb

            else
                2.0 / kg2lb

        St ->
            if large then
                1.0 / kg2st

            else
                0.2 / kg2st


format : Unit -> Float -> String
format u k =
    case u of
        Kg ->
            round k |> String.fromInt

        Lb ->
            round (k * kg2lb) |> String.fromInt

        St ->
            let
                num =
                    round (10.0 * k * kg2st)

                whole =
                    String.fromInt (num // 10)

                decimal =
                    String.fromInt (remainderBy 10 num)
            in
            String.join "" [ whole, ".", decimal ]


fromString : String -> Unit
fromString str =
    if Regex.contains pounds str then
        Lb

    else if Regex.contains stones str then
        St

    else
        Kg


toString : Unit -> String
toString unit =
    case unit of
        Kg ->
            "kg"

        Lb ->
            "lb"

        St ->
            "st"


pounds : Regex
pounds =
    Maybe.withDefault Regex.never <| Regex.fromString "^(lb|pound)s?$"


stones : Regex
stones =
    Maybe.withDefault Regex.never <| Regex.fromString "^(st|stone)s?$"



-- Conversion factors


kg2lb : Float
kg2lb =
    2.20462


kg2st : Float
kg2st =
    0.157472
