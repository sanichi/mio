module Station exposing (Station, Stations, colourOf, combine, nameOf, toggle)

import Array exposing (Array)


type alias Station =
    { name : String
    , colour : String
    , shown : Bool
    }


type alias Stations =
    Array Station


{-| Stations arrive from Rails as parallel arrays of names and hex colours,
already in legend order. They all start out shown.
-}
combine : List String -> List String -> Stations
combine names colours =
    List.map2 (\name colour -> Station name (sanitise colour) True) names colours
        |> Array.fromList


toggle : Int -> Stations -> Stations
toggle index stations =
    case Array.get index stations of
        Just station ->
            Array.set index { station | shown = not station.shown } stations

        Nothing ->
            stations


nameOf : Int -> Stations -> String
nameOf index stations =
    Array.get index stations |> Maybe.map .name |> Maybe.withDefault ""


colourOf : Int -> Stations -> String
colourOf index stations =
    Array.get index stations |> Maybe.map .colour |> Maybe.withDefault defaultColour



-- Helpers


{-| Guard against anything that isn't a bare six digit hex colour, since the
value is interpolated straight into an SVG attribute.
-}
sanitise : String -> String
sanitise colour =
    let
        clean =
            String.toLower colour |> String.filter isHexDigit
    in
    if String.length clean == 6 then
        clean

    else
        defaultColour


isHexDigit : Char -> Bool
isHexDigit c =
    Char.isDigit c || (c >= 'a' && c <= 'f')


defaultColour : String
defaultColour =
    "888888"
