module Data exposing (Data, Datum, combine, defaultMax, defaultMin, isFinish, isStart)

import Date exposing (Date)
import Time exposing (Month(..))


type alias Datum =
    { kilo : Float
    , date : Date
    }


type alias Data =
    List Datum


defaultMax : Datum
defaultMax =
    Datum 100.0 (Date.fromCalendarDate 2055 Nov 9)


defaultMin : Datum
defaultMin =
    Datum 70.0 (Date.fromCalendarDate 2014 Dec 1)


isStart : Datum -> Bool
isStart d =
    d.kilo > 0.0


isFinish : Datum -> Bool
isFinish d =
    d.kilo <= 0.0


combine : List Float -> List String -> Data
combine kilos dates =
    combine_ [] kilos dates


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
