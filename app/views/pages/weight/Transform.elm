module Transform exposing (Transform, fromData, transform)

import Data exposing (Data, Datum)
import Start exposing (Start)


type alias Transform =
    { dLow : Int
    , dHgh : Int
    , dFac : Float
    , kLow : Float
    , kHgh : Float
    , kFac : Float
    , kHit : Int
    }


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
    let
        i =
            d.rata
                |> (\x -> x - t.dLow)
                |> toFloat
                |> (*) t.dFac
                |> round

        j =
            d.kilo
                |> (\y -> y - t.kLow)
                |> (*) t.kFac
                |> round
                |> (-) t.kHit
    in
    ( i, j )



--
--
-- points : Model -> Svg Msg
-- points model =
--     let
--         d2i =
--             iFromDate model
--
--         k2j =
--             jFromKilo model
--
--         transform =
--             point d2i k2j
--
--         morning =
--             model.data
--                 |> List.filter Data.isMorning
--                 |> List.map transform
--
--         evening =
--             model.data
--                 |> List.filter Data.isEvening
--                 |> List.map transform
--     in
--     S.g [ cc "points" ]
--         [ S.g [ cc "morning" ] morning
--         , S.g [ cc "evening" ] evening
--         ]
--
--
--
-- -- Helpers
--
--
-- box : String
-- box =
--     "0 0 " ++ String.fromInt width ++ " " ++ String.fromInt height
--
--
-- cc : String -> Attribute Msg
-- cc c =
--     A.class c
--
--
-- cx : Int -> Attribute Msg
-- cx x =
--     A.cx <| String.fromInt x
--
--
-- cy : Int -> Attribute Msg
-- cy y =
--     A.cy <| String.fromInt y
--
--
-- r : Int -> Attribute Msg
-- r d =
--     A.r <| String.fromInt d
--
--
-- xx : Int -> Attribute Msg
-- xx x =
--     A.x <| String.fromInt x
--
--
-- yy : Int -> Attribute Msg
-- yy y =
--     A.y <| String.fromInt y
--
--
-- x1 : Int -> S.Attribute msg
-- x1 i =
--     A.x1 <| String.fromInt i
--
--
-- x2 : Int -> S.Attribute msg
-- x2 i =
--     A.x2 <| String.fromInt i
--
--
-- y1 : Int -> S.Attribute msg
-- y1 i =
--     A.y1 <| String.fromInt i
--
--
-- y2 : Int -> S.Attribute msg
-- y2 i =
--     A.y2 <| String.fromInt i
--
--
-- tt : String -> Svg Msg
-- tt t =
--     S.text t
--
--
--
-- -- Dimensions
--
--
-- debugTextX : Int
-- debugTextX =
--     width // 2
--
--
-- debugTextY : Int
-- debugTextY =
--     20
--
--
-- height : Int
-- height =
--     440
--
--
-- width : Int
-- width =
--     1000
--
--
-- iFromDate : Model -> Int -> Int
-- iFromDate model d =
--     let
--         low =
--             Data.dateMin model.data model.start
--
--         hgh =
--             Data.dateMax model.data
--
--         wid =
--             hgh - low |> toFloat
--
--         fac =
--             toFloat width / wid
--     in
--     d
--         |> (\x -> x - low)
--         |> toFloat
--         |> (*) fac
--         |> round
--
--
-- jFromKilo : Model -> Float -> Int
-- jFromKilo model k =
--     let
--         ( low, hgh ) =
--             Data.kiloMinMax model.data model.start
--
--         hit =
--             hgh - low
--
--         fac =
--             toFloat height / hit
--     in
--     k
--         |> (\x -> x - low)
--         |> (*) fac
--         |> round
--         |> (-) height
--
--
-- point : (Int -> Int) -> (Float -> Int) -> Datum -> Svg Msg
-- point d2i k2j d =
--     let
--         x =
--             d2i d.rata
--
--         y =
--             k2j d.kilo
--     in
--     S.circle [ cx x, cy y, r 2 ] []
