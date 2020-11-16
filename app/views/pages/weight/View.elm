module View exposing (box, fromModel)

import Data exposing (Datum)
import Date exposing (Date)
import Html exposing (Html)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Svg as S exposing (Attribute, Svg)
import Svg.Attributes as A
import Svg.Events exposing (onClick)
import Time exposing (Month(..))


fromModel : Model -> List (Svg Msg)
fromModel model =
    let
        components =
            [ frame, points model ]
    in
    if model.debug then
        debug model :: components

    else
        components


debug : Model -> Svg Msg
debug model =
    S.text_ [ xx debugTextX, yy debugTextY, cc "debug" ] [ tt <| Model.debugMsg model ]


frame : Svg Msg
frame =
    S.g [ cc "frame" ]
        [ S.line [ x1 0, y1 0, x2 width, y2 0 ] []
        , S.line [ x1 width, y1 0, x2 width, y2 height ] []
        , S.line [ x1 width, y1 height, x2 0, y2 height ] []
        , S.line [ x1 0, y1 height, x2 0, y2 0 ] []
        ]


points : Model -> Svg Msg
points model =
    let
        d2i =
            iFromDate model

        k2j =
            jFromKilo model

        transform =
            point d2i k2j

        start =
            model.data
                |> List.filter Data.isStart
                |> List.map transform

        finish =
            model.data
                |> List.filter Data.isFinish
                |> List.map transform
    in
    S.g [ cc "points" ]
        [ S.g [ cc "start" ] start
        , S.g [ cc "finish" ] finish
        ]



-- Helpers


box : String
box =
    "0 0 " ++ String.fromInt width ++ " " ++ String.fromInt height


cc : String -> Attribute Msg
cc c =
    A.class c


cx : Int -> Attribute Msg
cx x =
    A.cx <| String.fromInt x


cy : Int -> Attribute Msg
cy y =
    A.cy <| String.fromInt y


r : Int -> Attribute Msg
r d =
    A.r <| String.fromInt d


xx : Int -> Attribute Msg
xx x =
    A.x <| String.fromInt x


yy : Int -> Attribute Msg
yy y =
    A.y <| String.fromInt y


x1 : Int -> S.Attribute msg
x1 i =
    A.x1 <| String.fromInt i


x2 : Int -> S.Attribute msg
x2 i =
    A.x2 <| String.fromInt i


y1 : Int -> S.Attribute msg
y1 i =
    A.y1 <| String.fromInt i


y2 : Int -> S.Attribute msg
y2 i =
    A.y2 <| String.fromInt i


tt : String -> Svg Msg
tt t =
    S.text t



-- Dimensions


debugTextX : Int
debugTextX =
    width // 2


debugTextY : Int
debugTextY =
    20


height : Int
height =
    500


width : Int
width =
    1000


iFromDate : Model -> Date -> Int
iFromDate model d =
    let
        low =
            Data.dateMin model.data model.start |> Date.toRataDie

        hgh =
            Data.dateMax model.data |> Date.toRataDie

        wid =
            hgh - low |> toFloat

        fac =
            toFloat width / wid
    in
    d
        |> Date.toRataDie
        |> (\x -> x - low)
        |> toFloat
        |> (*) fac
        |> round


jFromKilo : Model -> Float -> Int
jFromKilo model k =
    let
        ( low, hgh ) =
            Data.kiloMinMax model.data model.start

        hit =
            hgh - low

        fac =
            toFloat height / hit
    in
    k
        |> abs
        |> (\x -> x - low)
        |> (*) fac
        |> round
        |> (-) height


point : (Date -> Int) -> (Float -> Int) -> Datum -> Svg Msg
point d2i k2j d =
    let
        x =
            d2i d.date

        y =
            k2j d.kilo
    in
    S.circle [ cx x, cy y, r 2 ] []
