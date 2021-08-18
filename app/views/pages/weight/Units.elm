module Units exposing (Unit(..), delta, format, format2, fromString, toString)

import Regex exposing (Regex)


type Unit
    = Kg
    | Lb
    | St
    | Bm


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

        Bm ->
            1.0 / kg2bm


format : Unit -> Float -> String
format u k =
    case u of
        Kg ->
            decimal k 1

        Lb ->
            decimal (k * kg2lb) 1

        Bm ->
            decimal (k * kg2bm) 1

        St ->
            decimal (k * kg2st) 10


format2 : Unit -> Float -> String
format2 u k =
    let
        num =
            case u of
                Kg ->
                    decimal k 10

                Lb ->
                    decimal (k * kg2lb) 1

                Bm ->
                    decimal (k * kg2bm) 10

                St ->
                    decimal (k * kg2st) 10
    in
    num ++ toString u


decimal : Float -> Int -> String
decimal w d =
    if d == 1 then
        String.fromInt <| round w

    else
        let
            num =
                round (toFloat d * w)

            whole =
                String.fromInt (num // d)

            fraction =
                String.fromInt (remainderBy d num)
        in
        String.join "" [ whole, ".", fraction ]


fromString : String -> Unit
fromString str =
    if Regex.contains pounds str then
        Lb

    else if Regex.contains stones str then
        St

    else if Regex.contains bmi str then
        Bm

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

        Bm ->
            "bm"


pounds : Regex
pounds =
    Maybe.withDefault Regex.never <| Regex.fromString "^(lb|pound)s?$"


stones : Regex
stones =
    Maybe.withDefault Regex.never <| Regex.fromString "^(st|stone)s?$"


bmi : Regex
bmi =
    Maybe.withDefault Regex.never <| Regex.fromString "^(bm|bmi)$"



-- Conversion factors


kg2lb : Float
kg2lb =
    2.20462


kg2st : Float
kg2st =
    0.157472


kg2bm : Float
kg2bm =
    0.290861
