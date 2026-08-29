module Transform exposing
    ( Level
    , Levels
    , Transform
    , fromData
    , height
    , levelsd
    , levelsp
    , transform
    , transformPence
    , transformRata
    , width
    )

import Data exposing (Data, Point)
import Date exposing (Date, Unit(..))
import Station exposing (Stations)
import Time exposing (Month(..))


type alias Transform =
    { dLow : Int
    , dHgh : Int
    , dFac : Float
    , pLow : Float
    , pHgh : Float
    , pFac : Float
    , pStep : Float
    }


type alias Level =
    { val : Int
    , label : String
    }


type alias Levels =
    List Level


fromData : Stations -> Data -> Int -> Transform
fromData stations data begin =
    let
        dLow =
            Data.dateMin data begin

        dHgh =
            Data.dateMax data

        dFac =
            toFloat width / toFloat (dHgh - dLow)

        ( pLow, pHgh ) =
            Data.penceMinMax stations data dLow dHgh

        pFac =
            toFloat height / (pHgh - pLow)

        -- Ten pence gridlines get sparse once the range is narrow, so halve
        -- the interval when there isn't room for at least four of them.
        pStep =
            if pHgh - pLow >= 40.0 then
                10.0

            else
                5.0
    in
    Transform dLow dHgh dFac pLow pHgh pFac pStep


transform : Transform -> Point -> ( Int, Int )
transform t p =
    ( d2i t p.rata, p2j t p.pence )


transformRata : Transform -> Int -> Int
transformRata t rata =
    d2i t rata


transformPence : Transform -> Float -> Int
transformPence t pence =
    p2j t pence


levelsd : Transform -> Levels
levelsd t =
    let
        days =
            t.dHgh - t.dLow

        ( dn, du ) =
            if days <= 31 then
                ( 1, Weeks )

            else if days <= 62 then
                ( 2, Weeks )

            else if days <= 125 then
                ( 1, Months )

            else if days <= 250 then
                ( 2, Months )

            else if days <= 400 then
                ( 4, Months )

            else if days <= 800 then
                ( 8, Months )

            else
                ( 1, Years )

        l =
            t.dLow
                |> dateFromRataDie du
                |> Date.year
                |> (\y -> Date.fromCalendarDate y Jan 1)
                |> Date.toRataDie
    in
    dlevels t du dn l []


levelsp : Transform -> Levels
levelsp t =
    let
        l =
            t.pStep * toFloat (floor (t.pLow / t.pStep))
    in
    plevels t l []



-- Helpers


d2i : Transform -> Int -> Int
d2i t d =
    d
        |> (\x -> x - t.dLow)
        |> toFloat
        |> (*) t.dFac
        |> round


p2j : Transform -> Float -> Int
p2j t p =
    p
        |> (\y -> y - t.pLow)
        |> (*) t.pFac
        |> round
        |> (-) height


dlevels : Transform -> Date.Unit -> Int -> Int -> Levels -> Levels
dlevels t du dn l ls =
    if l > t.dHgh then
        ls

    else
        let
            nl =
                l
                    |> Date.fromRataDie
                    |> Date.add du dn
                    |> Date.toRataDie
        in
        if l < t.dLow then
            dlevels t du dn nl ls

        else
            let
                i =
                    d2i t l

                d =
                    dateFromRataDie du l

                s =
                    case du of
                        Years ->
                            Date.format "YYYY" d

                        Months ->
                            if dn <= 2 then
                                Date.format "MMM" d

                            else
                                Date.format "MMM YYYY" d

                        _ ->
                            Date.format "MMM d" d
            in
            dlevels t du dn nl (Level i s :: ls)


plevels : Transform -> Float -> Levels -> Levels
plevels t l ls =
    if l > t.pHgh then
        ls

    else
        let
            nl =
                l + t.pStep
        in
        if l < t.pLow then
            plevels t nl ls

        else
            plevels t nl (Level (p2j t l) (String.fromInt (round l)) :: ls)


dateFromRataDie : Date.Unit -> Int -> Date
dateFromRataDie du rd =
    let
        fudge =
            if du == Years then
                7

            else
                0
    in
    Date.fromRataDie (rd + fudge)


width : Int
width =
    1000


height : Int
height =
    440
