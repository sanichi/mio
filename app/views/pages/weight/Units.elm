module Units exposing (Units(..), fromString, toString)

import Regex exposing (Regex)


type Units
    = Kg
    | Lb
    | St


fromString : String -> Units
fromString str =
    if Regex.contains pounds str then
        Lb

    else if Regex.contains stones str then
        St

    else
        Kg


toString : Units -> String
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
