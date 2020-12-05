module Dni exposing (Model, cycle, decrement, increment, init, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))
import Svg as S exposing (Attribute)
import Svg.Attributes as SA


type alias Model =
    { counter : Int
    , increment : Int
    }


init : Model
init =
    Model 0 1


increment : Model -> Model
increment m =
    { m | counter = m.counter + m.increment }


decrement : Model -> Model
decrement m =
    let
        update =
            if m.counter >= m.increment then
                m.counter - m.increment

            else
                0
    in
    { m | counter = update }


cycle : Model -> Model
cycle m =
    let
        update =
            case m.increment of
                1 ->
                    5

                5 ->
                    10

                10 ->
                    25

                25 ->
                    100

                100 ->
                    625

                625 ->
                    1000

                _ ->
                    1
    in
    { m | increment = update }


view : Model -> Html Msg
view m =
    div [ class "row" ]
        [ div [ class "col" ]
            [ button [ class "btn btn-success btn-sm mr-3" ] [ text (String.fromInt m.counter) ]
            ]
        , div [ class "col" ]
            [ dniSvg m
            ]
        , div [ class "col" ]
            [ div [ class "float-right" ]
                [ button [ class "btn btn-primary btn-sm ml-1", onClick DniIncrement ] [ text "+" ]
                , button [ class "btn btn-warning btn-sm ml-1", onClick DniCycle ] [ text (String.fromInt m.increment) ]
                , button [ class "btn btn-danger btn-sm ml-1", onClick DniDecrement ] [ text "-" ]
                ]
            ]
        ]


dniSvg : Model -> Html Msg
dniSvg m =
    let
        ds =
            digits m.counter

        d =
            List.length ds
    in
    S.svg [ aWidth (actualWidth d), aHeight actualHeight, aViewBox (fullWidth d) fullHeight, aId "dni" ]
        [ frame d
        ]


frame : Int -> Html Msg
frame d =
    let
        w =
            fullWidth d

        h =
            fullHeight
    in
    S.g [ aClass "frame" ]
        [ S.line [ aX1 0, aY1 0, aX2 w, aY2 0 ] []
        , S.line [ aX1 w, aY1 0, aX2 w, aY2 h ] []
        , S.line [ aX1 w, aY1 h, aX2 0, aY2 h ] []
        , S.line [ aX1 0, aY1 h, aX2 0, aY2 0 ] []
        ]


digits : Int -> List Int
digits n =
    digits_ [] n


digits_ : List Int -> Int -> List Int
digits_ ds n =
    if n < 25 then
        n :: ds

    else
        digits_ (modBy 25 n :: ds) (n // 25)



-- dimensions


actualWidth : Int -> Int
actualWidth d =
    toFloat actualHeight * toFloat (fullWidth d) / toFloat fullHeight |> round


actualHeight : Int
actualHeight =
    32


fullWidth : Int -> Int
fullWidth d =
    dniWidth * d + 2 * margin


fullHeight : Int
fullHeight =
    1000


margin : Int
margin =
    50


dniWidth : Int
dniWidth =
    dniHeight


dniHeight : Int
dniHeight =
    fullHeight - 2 * margin


dniY : Int
dniY =
    margin



-- SVG helpers


aX : Int -> Attribute msg
aX x =
    SA.x (String.fromInt x)


aY : Int -> Attribute msg
aY y =
    SA.y (String.fromInt y)


aX1 : Int -> Attribute msg
aX1 x =
    SA.x1 (String.fromInt x)


aY1 : Int -> Attribute msg
aY1 y =
    SA.y1 (String.fromInt y)


aX2 : Int -> Attribute msg
aX2 x =
    SA.x2 (String.fromInt x)


aY2 : Int -> Attribute msg
aY2 y =
    SA.y2 (String.fromInt y)


aWidth : Int -> Attribute msg
aWidth w =
    SA.width (String.fromInt w)


aHeight : Int -> Attribute msg
aHeight h =
    SA.height (String.fromInt h)


aViewBox : Int -> Int -> Attribute msg
aViewBox w h =
    let
        arg =
            [ 0, 0, w, h ]
                |> List.map String.fromInt
                |> String.join " "
    in
    SA.viewBox arg


aId : String -> Attribute msg
aId c =
    SA.id c


aClass : String -> Attribute msg
aClass c =
    SA.class c
