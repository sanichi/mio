module Transform exposing (Transform, fromData, levelsd, levelsk, transform)

import Data exposing (Data, Datum)
import Start exposing (Start)
import Units exposing (Unit(..))


type alias Transform =
    { dLow : Int
    , dHgh : Int
    , dFac : Float
    , kLow : Float
    , kHgh : Float
    , kFac : Float
    , kHit : Int
    }


type alias Level =
    { val : Int
    , label : String
    }


type alias Levels =
    List Level


fromData : Data -> Start -> Int -> Int -> Transform
fromData data start width height =
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
    Transform dLow dHgh dFac kLow kHgh kFac height


transform : Transform -> Datum -> ( Int, Int )
transform t d =
    ( d2i t d.rata, k2j t d.kilo )


levelsd : Transform -> Levels
levelsd t =
    [ Level 100 "May", Level 200 "June" ]


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


k2j : Transform -> Float -> Int
k2j t k =
    k
        |> (\y -> y - t.kLow)
        |> (*) t.kFac
        |> round
        |> (-) t.kHit


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
