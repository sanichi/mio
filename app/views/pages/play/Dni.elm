module Dni exposing (Model, cycle, decrement, increment, init, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))
import Svg as S exposing (Attribute)
import Svg.Attributes as SA



-- model


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


digits : Int -> List Int
digits n =
    digits_ [] n


digits_ : List Int -> Int -> List Int
digits_ ds n =
    if n < 25 then
        n :: ds

    else
        digits_ (modBy 25 n :: ds) (n // 25)



-- view


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
            m.counter
                |> digits
                |> List.indexedMap digit

        d =
            List.length ds
    in
    S.svg [ aWidth (fullWidth d), aHeight fullHeight, aViewBox (fullWidth d) fullHeight, aId "dni" ]
        (frame d :: ds)


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



-- digit images


dSquare : List (Html Msg)
dSquare =
    [ S.line [ aX1 0, aY1 0, aX2 dW, aY2 0 ] []
    , S.line [ aX1 dW, aY1 0, aX2 dW, aY2 dH ] []
    , S.line [ aX1 dW, aY1 dH, aX2 0, aY2 dH ] []
    , S.line [ aX1 0, aY1 dH, aX2 0, aY2 0 ] []
    ]


digit : Int -> Int -> Html Msg
digit position d =
    let
        x =
            dX position

        y =
            dY
    in
    case d of
        1 ->
            one x y

        2 ->
            two x y

        3 ->
            three x y

        _ ->
            zero x y


zero : Int -> Int -> Html Msg
zero x y =
    S.circle [ aCx (dW // 2), aCy (dH // 2), aR 1 ] []
        :: dSquare
        |> S.g [ aClass "digit", aTranslate x y ]


one : Int -> Int -> Html Msg
one x y =
    S.line [ aX1 (dW // 2), aY1 0, aX2 (dW // 2), aY2 dH ] []
        :: dSquare
        |> S.g [ aClass "digit", aTranslate x y ]


two : Int -> Int -> Html Msg
two x y =
    let
        p1 =
            "0,0"

        p2 =
            "0," ++ String.fromInt dH

        ff =
            round (toFloat dW / 3.0)

        b1 =
            String.fromInt ff ++ "," ++ String.fromInt ff

        b2 =
            String.fromInt ff ++ "," ++ String.fromInt (dH - ff)

        path =
            String.join " " [ "M", p1, "C", b1, b2, p2 ]
    in
    S.path [ aD path ] []
        :: dSquare
        |> S.g [ aClass "digit", aTranslate x y ]


three : Int -> Int -> Html Msg
three x y =
    let
        l1 =
            S.line [ aX1 0, aY1 (dH // 2), aX2 (dW // 2), aY2 0 ] []

        l2 =
            S.line [ aX1 0, aY1 (dH // 2), aX2 (dW // 2), aY2 dH ] []
    in
    [ l1, l2 ]
        ++ dSquare
        |> S.g [ aClass "digit", aTranslate x y ]



-- dimensions


fullWidth : Int -> Int
fullWidth d =
    dW * d + 2 * margin


fullHeight : Int
fullHeight =
    50


margin : Int
margin =
    8


dW : Int
dW =
    dH


dH : Int
dH =
    fullHeight - 2 * margin


dX : Int -> Int
dX position =
    margin + dW * position


dY : Int
dY =
    margin



-- SVG helpers


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


aCx : Int -> Attribute msg
aCx x =
    SA.cx (String.fromInt x)


aCy : Int -> Attribute msg
aCy y =
    SA.cy (String.fromInt y)


aR : Int -> Attribute msg
aR r =
    SA.r (String.fromInt r)


aD : String -> Attribute msg
aD path =
    SA.d path


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


aTranslate : Int -> Int -> Attribute msg
aTranslate x y =
    [ "translate(", String.fromInt x, ",", String.fromInt y, ")" ]
        |> String.join ""
        |> SA.transform


aId : String -> Attribute msg
aId c =
    SA.id c


aClass : String -> Attribute msg
aClass c =
    SA.class c
