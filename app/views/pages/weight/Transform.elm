module Transform exposing (Transform, fromData, height, levelsd, levelsk, reverse, transform, width)

import Data exposing (Data, Datum)
import Date exposing (Date, Unit(..))
import Start exposing (Start)
import Time exposing (Month(..))
import Units exposing (Unit(..))


type alias Transform =
    { dLow : Int
    , dHgh : Int
    , dFac : Float
    , kLow : Float
    , kHgh : Float
    , kFac : Float
    }


type alias Level =
    { val : Int
    , label : String
    }


type alias Levels =
    List Level


fromData : Data -> Start -> Transform
fromData data start =
    let
        dLow =
            Data.dateMin data start

        dHgh =
            Data.dateMax data

        dFac =
            toFloat width / toFloat (dHgh - dLow)

        ( kLow, kHgh ) =
            Data.kiloMinMax data start

        kFac =
            toFloat height / (kHgh - kLow)
    in
    Transform dLow dHgh dFac kLow kHgh kFac


transform : Transform -> Datum -> ( Int, Int )
transform t d =
    ( d2i t d.rata, k2j t d.kilo )


reverse : Transform -> ( Int, Int ) -> Datum
reverse t ( x, y ) =
    Datum (j2k t y) (i2d t x) True


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


levelsk : Transform -> Unit -> Levels
levelsk t u =
    let
        d =
            Units.delta u (t.kHgh - t.kLow)

        l =
            d * toFloat (floor (t.kLow / d))
    in
    jlevels t u d l []



-- Helpers


d2i : Transform -> Int -> Int
d2i t d =
    d
        |> (\x -> x - t.dLow)
        |> toFloat
        |> (*) t.dFac
        |> round


i2d : Transform -> Int -> Int
i2d t x =
    x
        |> toFloat
        |> (\z -> z / t.dFac)
        |> round
        |> (+) t.dLow


k2j : Transform -> Float -> Int
k2j t k =
    k
        |> (\y -> y - t.kLow)
        |> (*) t.kFac
        |> round
        |> (-) height


j2k : Transform -> Int -> Float
j2k t y =
    y
        |> (-) height
        |> toFloat
        |> (\z -> z / t.kFac)
        |> (+) t.kLow


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


jlevels : Transform -> Unit -> Float -> Float -> Levels -> Levels
jlevels t u d l ls =
    if l > t.kHgh then
        ls

    else
        let
            nl =
                l + d
        in
        if l < t.kLow then
            jlevels t u d nl ls

        else
            let
                j =
                    k2j t l

                s =
                    Units.format u l
            in
            jlevels t u d nl (Level j s :: ls)


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
