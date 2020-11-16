module Data exposing
    ( Data
    , Datum
    , combine
    , dateMax
    , dateMin
    , isFinish
    , isStart
    , kiloMinMax
    )

import Date exposing (Date, Unit(..))
import Start exposing (Start)
import Time exposing (Month(..))


type alias Datum =
    { kilo : Float
    , date : Date
    }


type alias Data =
    List Datum


combine : List Float -> List String -> Data
combine kilos dates =
    combine_ [] kilos dates


dateMin : Data -> Start -> Date
dateMin data start =
    if start == 0 then
        defaultMin.date

    else
        data
            |> dateMax
            |> Date.add Months -start
            |> Date.add Days -1


dateMax : Data -> Date
dateMax data =
    data
        |> List.head
        |> Maybe.withDefault defaultMax
        |> .date
        |> Date.add Days 1


kiloMinMax : Data -> Start -> ( Float, Float )
kiloMinMax data start =
    let
        cutoff =
            dateMin data start |> Date.toRataDie

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


isStart : Datum -> Bool
isStart d =
    d.kilo > 0.0


isFinish : Datum -> Bool
isFinish d =
    d.kilo <= 0.0



-- Utilities


defaultMax : Datum
defaultMax =
    Datum 100.0 (Date.fromCalendarDate 2055 Nov 9)


defaultMin : Datum
defaultMin =
    Datum 70.0 (Date.fromCalendarDate 2014 Dec 1)


combine_ : Data -> List Float -> List String -> Data
combine_ data kilos dates =
    case ( kilos, dates ) of
        ( kilo :: ks, str :: ds ) ->
            case Date.fromIsoString str of
                Ok date ->
                    combine_ (Datum kilo date :: data) ks ds

                _ ->
                    combine_ data ks ds

        _ ->
            List.reverse data


limits : Data -> Int -> ( Maybe Float, Maybe Float ) -> ( Maybe Float, Maybe Float )
limits data cutoff sofar =
    case data of
        d :: rest ->
            if Date.toRataDie d.date < cutoff then
                sofar

            else
                let
                    minKilo =
                        case Tuple.first sofar of
                            Nothing ->
                                Just (abs d.kilo)

                            Just k ->
                                if k > abs d.kilo then
                                    Just (abs d.kilo)

                                else
                                    Just k

                    maxKilo =
                        case Tuple.second sofar of
                            Nothing ->
                                Just (abs d.kilo)

                            Just k ->
                                if k < abs d.kilo then
                                    Just (abs d.kilo)

                                else
                                    Just k
                in
                limits rest cutoff ( minKilo, maxKilo )

        [] ->
            sofar
