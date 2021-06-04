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
            [ button [ class "btn btn-success btn-sm me-3" ] [ text (String.fromInt m.counter) ]
            ]
        , div [ class "col" ]
            [ dniSvg m
            ]
        , div [ class "col" ]
            [ div [ class "float-end" ]
                [ button [ class "btn btn-primary btn-sm ms-1", onClick DniIncrement ] [ text "+" ]
                , button [ class "btn btn-secondary btn-sm ms-1", onClick DniCycle ] [ text (String.fromInt m.increment) ]
                , button [ class "btn btn-danger btn-sm ms-1", onClick DniDecrement ] [ text "-" ]
                ]
            ]
        ]


dniSvg : Model -> Html Msg
dniSvg m =
    let
        dniDigits =
            m.counter
                |> digits
                |> List.indexedMap digit

        d =
            List.length dniDigits
    in
    S.svg [ aWidth (fullWidth d), aHeight fullHeight, aViewBox (fullWidth d) fullHeight, aId "dni" ]
        (hRails d :: dniDigits)


hRails : Int -> Html Msg
hRails d =
    let
        x1 =
            0

        y1 =
            margin

        x2 =
            fullWidth d

        y2 =
            fullHeight - margin
    in
    S.g []
        [ S.line [ aX1 x1, aY1 y1, aX2 x2, aY2 y1, aClass "rails" ] []
        , S.line [ aX1 x1, aY1 y2, aX2 x2, aY2 y2, aClass "rails" ] []
        ]



-- digit images


digit : Int -> Int -> Html Msg
digit position d =
    let
        digs =
            case d of
                1 ->
                    one

                2 ->
                    two

                3 ->
                    three

                4 ->
                    four

                5 ->
                    rotate one

                6 ->
                    rotate one ++ one

                7 ->
                    rotate one ++ two

                8 ->
                    rotate one ++ three

                9 ->
                    rotate one ++ four

                10 ->
                    rotate two

                11 ->
                    rotate two ++ one

                12 ->
                    rotate two ++ two

                13 ->
                    rotate two ++ three

                14 ->
                    rotate two ++ four

                15 ->
                    rotate three

                16 ->
                    rotate three ++ one

                17 ->
                    rotate three ++ two

                18 ->
                    rotate three ++ three

                19 ->
                    rotate three ++ four

                20 ->
                    rotate four

                21 ->
                    rotate four ++ one

                22 ->
                    rotate four ++ two

                23 ->
                    rotate four ++ three

                24 ->
                    rotate four ++ four

                _ ->
                    zero
    in
    digs
        ++ vRails
        |> S.g [ aTranslate position ]


zero : List (Html Msg)
zero =
    S.circle [ aCx hW, aCy hH, aR 1 ] [] |> List.singleton


one : List (Html Msg)
one =
    S.line [ aX1 hW, aY1 0, aX2 hW, aY2 dH, aClass "digit" ] [] |> List.singleton


two : List (Html Msg)
two =
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
    S.path [ aD path ] [] |> List.singleton


three : List (Html Msg)
three =
    let
        l1 =
            S.line [ aX1 0, aY1 hH, aX2 hW, aY2 0, aClass "digit" ] []

        l2 =
            S.line [ aX1 0, aY1 hH, aX2 hW, aY2 dH, aClass "digit" ] []
    in
    [ l1, l2 ]


four : List (Html Msg)
four =
    let
        p1 =
            [ hW, dH ]
                |> List.map String.fromInt
                |> String.join ","

        p2 =
            [ hW, qH ]
                |> List.map String.fromInt
                |> String.join ","

        p3 =
            [ dW, qH ]
                |> List.map String.fromInt
                |> String.join ","

        path =
            String.join " " [ "M", p1, "L", p2, "L", p3 ]
    in
    S.path [ aD path ] [] |> List.singleton


rotate : List (Html Msg) -> List (Html Msg)
rotate digs =
    S.g [ aRotate ] digs |> List.singleton


vRails : List (Html Msg)
vRails =
    [ S.line [ aX1 dW, aY1 0, aX2 dW, aY2 dH, aClass "rails" ] []
    , S.line [ aX1 0, aY1 dH, aX2 0, aY2 0, aClass "rails" ] []
    ]



-- dimensions


fullWidth : Int -> Int
fullWidth d =
    dW * d + 2 * margin


fullHeight : Int
fullHeight =
    44


margin : Int
margin =
    5


dW : Int
dW =
    dH


dH : Int
dH =
    fullHeight - 2 * margin


hW : Int
hW =
    dW // 2


hH : Int
hH =
    dH // 2


qH : Int
qH =
    dH // 4


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


aTranslate : Int -> Attribute msg
aTranslate position =
    let
        x =
            dX position |> String.fromInt

        y =
            dY |> String.fromInt
    in
    [ "translate(", x, ",", y, ")" ]
        |> String.join ""
        |> SA.transform


aRotate : Attribute msg
aRotate =
    let
        cx =
            String.fromInt hW

        cy =
            String.fromInt hH
    in
    [ "rotate(-90,", cx, ",", cy, ")" ]
        |> String.join ""
        |> SA.transform


aId : String -> Attribute msg
aId c =
    SA.id c


aClass : String -> Attribute msg
aClass c =
    SA.class c
