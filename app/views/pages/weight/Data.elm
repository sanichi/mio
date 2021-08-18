module Data exposing
    ( Data
    , Datum
    , combine
    , dateFormat
    , dateMax
    , dateMin
    , kiloMinMax
    )

import Date exposing (Unit(..))
import Start exposing (Start)
import Time exposing (Month(..))


type alias Datum =
    { kilo : Float
    , rata : Int
    , even : Bool
    }


type alias Data =
    List Datum


combine : List Float -> List String -> Data
combine kilos dates =
    combine_ [] kilos dates


dateFormat : Int -> String
dateFormat rata =
    rata
        |> Date.fromRataDie
        |> Date.format "y-MM-dd"


dateMin : Data -> Start -> Int
dateMin data start =
    if start == 0 then
        defaultMin.rata

    else
        data
            |> dateMax
            |> (\x -> x - 30 * start)


dateMax : Data -> Int
dateMax data =
    data
        |> List.head
        |> Maybe.withDefault defaultMax
        |> .rata
        |> (+) 1


kiloMinMax : Data -> Start -> ( Float, Float )
kiloMinMax data start =
    let
        cutoff =
            dateMin data start

        ( min, max ) =
            limits data cutoff ( Nothing, Nothing )
    in
    let
        rnd =
            5.0

        delta =
            0.1

        low =
            min
                |> Maybe.withDefault defaultMin.kilo
                |> (\x -> (x / rnd) - delta)
                |> floor
                |> toFloat
                |> (*) rnd

        hgh =
            max
                |> Maybe.withDefault defaultMax.kilo
                |> (\x -> (x / rnd) + delta)
                |> ceiling
                |> toFloat
                |> (*) rnd
    in
    ( low, hgh )



-- Utilities


defaultMax : Datum
defaultMax =
    let
        rata =
            Date.fromCalendarDate 2055 Nov 9 |> Date.toRataDie
    in
    Datum 100.0 rata True


defaultMin : Datum
defaultMin =
    let
        rata =
            Date.fromCalendarDate 2014 Dec 1 |> Date.toRataDie
    in
    Datum 70.0 rata True


combine_ : Data -> List Float -> List String -> Data
combine_ data kilos dates =
    case ( kilos, dates ) of
        ( kilo :: ks, str :: ds ) ->
            case Date.fromIsoString str of
                Ok date ->
                    let
                        rata =
                            Date.toRataDie date

                        datum =
                            Datum (abs kilo) rata (kilo < 0.0)
                    in
                    combine_ (datum :: data) ks ds

                _ ->
                    combine_ data ks ds

        _ ->
            List.reverse data


limits : Data -> Int -> ( Maybe Float, Maybe Float ) -> ( Maybe Float, Maybe Float )
limits data cutoff sofar =
    case data of
        d :: rest ->
            if d.rata < cutoff then
                sofar

            else
                let
                    minKilo =
                        case Tuple.first sofar of
                            Nothing ->
                                Just d.kilo

                            Just k ->
                                if k > d.kilo then
                                    Just d.kilo

                                else
                                    Just k

                    maxKilo =
                        case Tuple.second sofar of
                            Nothing ->
                                Just d.kilo

                            Just k ->
                                if k < d.kilo then
                                    Just d.kilo

                                else
                                    Just k
                in
                limits rest cutoff ( minKilo, maxKilo )

        [] ->
            sofar
