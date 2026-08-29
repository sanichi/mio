module Data exposing
    ( Data
    , Point
    , Series
    , combine
    , dateFormat
    , dateMax
    , dateMin
    , penceFormat
    , penceMinMax
    , pointAt
    , seriesAt
    )

import Array exposing (Array)
import Date
import Station exposing (Stations)
import Time exposing (Month(..))


type alias Point =
    { rata : Int
    , pence : Float
    }


{-| One station's prices, ascending by date.
-}
type alias Series =
    Array Point


{-| One series per station, in the same order as the stations themselves.
-}
type alias Data =
    Array Series


{-| Prices arrive from Rails as three parallel lists: which station each price
belongs to, when it was recorded, and what it was.
-}
combine : Int -> List Int -> List String -> List Float -> Data
combine count indices dates pences
    =
    let
        add ( index, str, pence ) acc =
            case ( Array.get index acc, Date.fromIsoString str ) of
                ( Just points, Ok date ) ->
                    Array.set index (Point (Date.toRataDie date) pence :: points) acc

                _ ->
                    acc
    in
    List.map3 (\i d p -> ( i, d, p )) indices dates pences
        |> List.foldl add (Array.repeat count [])
        |> Array.map (List.sortBy .rata >> Array.fromList)


seriesAt : Int -> Data -> Series
seriesAt index data =
    Array.get index data |> Maybe.withDefault Array.empty


pointAt : Int -> Int -> Data -> Maybe Point
pointAt station point data =
    Array.get point (seriesAt station data)


dateFormat : Int -> String
dateFormat rata =
    rata
        |> Date.fromRataDie
        |> Date.format "y-MM-dd"


penceFormat : Float -> String
penceFormat pence =
    let
        tenths =
            round (pence * 10)
    in
    String.fromInt (tenths // 10) ++ "." ++ String.fromInt (remainderBy 10 tenths) ++ "p"


{-| The right hand edge of the graph is the day after the most recent price,
whichever station it came from, so that toggling stations doesn't shift it.
-}
dateMax : Data -> Int
dateMax data =
    everyPoint data
        |> List.map .rata
        |> List.maximum
        |> Maybe.withDefault defaultRata
        |> (+) 1


dateMin : Data -> Int -> Int
dateMin data months =
    dateMax data - (30 * months)


{-| The price range covered by the shown stations inside the date window,
rounded outwards to a multiple of ten pence. Segments that merely cross the
window are counted at the point where they cross it, so that a station with no
prices in the window still has its line drawn on the scale.
-}
penceMinMax : Stations -> Data -> Int -> Int -> ( Float, Float )
penceMinMax stations data lower upper =
    let
        values =
            data
                |> Array.toIndexedList
                |> List.filter (\( index, _ ) -> isShown index stations)
                |> List.concatMap (\( _, series ) -> windowValues lower upper (Array.toList series))

        ( min, max ) =
            ( List.minimum values |> Maybe.withDefault defaultLow
            , List.maximum values |> Maybe.withDefault defaultHgh
            )

        low =
            min / rounding |> floor |> toFloat |> (*) rounding

        hgh =
            max / rounding |> ceiling |> toFloat |> (*) rounding
    in
    if hgh - low < minimumSpan then
        ( low, low + minimumSpan )

    else
        ( low, hgh )



-- Helpers


everyPoint : Data -> List Point
everyPoint data =
    data |> Array.toList |> List.concatMap Array.toList


isShown : Int -> Stations -> Bool
isShown index stations =
    Array.get index stations |> Maybe.map .shown |> Maybe.withDefault False


windowValues : Int -> Int -> List Point -> List Float
windowValues lower upper points =
    let
        inside =
            points
                |> List.filter (\p -> p.rata >= lower && p.rata <= upper)
                |> List.map .pence

        crossings =
            List.map2 Tuple.pair points (List.drop 1 points)
                |> List.concatMap (\( a, b ) -> edgeValues lower upper a b)
    in
    inside ++ crossings


edgeValues : Int -> Int -> Point -> Point -> List Float
edgeValues lower upper a b =
    let
        crossing rata =
            if a.rata < rata && b.rata > rata then
                [ interpolate a b rata ]

            else
                []
    in
    crossing lower ++ crossing upper


interpolate : Point -> Point -> Int -> Float
interpolate a b rata =
    let
        span =
            toFloat (b.rata - a.rata)
    in
    if span == 0 then
        a.pence

    else
        a.pence + (b.pence - a.pence) * toFloat (rata - a.rata) / span


rounding : Float
rounding =
    10.0


minimumSpan : Float
minimumSpan =
    10.0


defaultLow : Float
defaultLow =
    130.0


defaultHgh : Float
defaultHgh =
    170.0


defaultRata : Int
defaultRata =
    Date.fromCalendarDate 2026 Jan 1 |> Date.toRataDie
