module View exposing (box, fromModel)

import Data exposing (Datum)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Svg as S exposing (Attribute, Svg)
import Svg.Attributes as A
import Transform exposing (Transform)
import Units


fromModel : Model -> List (Svg Msg)
fromModel m =
    let
        d =
            debug m

        i =
            info m

        x =
            point m

        f =
            frame

        dl =
            levelsd m

        kl =
            levelsk m

        p =
            points m

        c =
            [ f, dl, kl, p, i, x ]
    in
    if m.debug then
        d :: c

    else
        c


debug : Model -> Svg Msg
debug m =
    S.text_ [ xx debugTextX, yy debugTextY, cc "debug" ] [ tt <| Model.debugMsg m ]


info : Model -> Svg Msg
info m =
    let
        datum =
            Transform.reverse m.transform m.point

        date =
            Data.dateFormat datum.rata

        weight =
            Units.format2 m.units datum.kilo
    in
    S.text_ [ xx infoTextX, yy infoTextY, cc "info" ] [ tt <| date ++ " " ++ weight ]


point : Model -> Svg Msg
point m =
    let
        ( x, y ) =
            m.point
    in
    S.g [ cc "cross" ]
        [ S.line [ x1 (x - crossWidth), y1 y, x2 (x + crossWidth), y2 y ] []
        , S.line [ x1 x, y1 (y - crossWidth), x2 x, y2 (y + crossWidth) ] []
        ]


frame : Svg Msg
frame =
    S.g [ cc "frame" ]
        [ S.line [ x1 0, y1 0, x2 width, y2 0 ] []
        , S.line [ x1 width, y1 0, x2 width, y2 height ] []
        , S.line [ x1 width, y1 height, x2 0, y2 height ] []
        , S.line [ x1 0, y1 height, x2 0, y2 0 ] []
        ]


levelsd : Model -> Svg Msg
levelsd m =
    let
        levels =
            Transform.levelsd m.transform

        level2line =
            \l -> S.line [ x1 l.val, y1 0, x2 l.val, y2 height ] []

        lines =
            List.map level2line levels

        level2label =
            \l -> S.text_ [ xx l.val, yy (height + 17), A.textAnchor "mid" ] [ S.text l.label ]

        labels =
            List.map level2label levels
    in
    lines ++ labels |> S.g [ cc "axes" ]


levelsk : Model -> Svg Msg
levelsk m =
    let
        levels =
            Transform.levelsk m.transform m.units

        level2line =
            \l -> S.line [ x1 -3, y1 l.val, x2 width, y2 l.val ] []

        lines =
            List.map level2line levels

        level2label =
            \l -> S.text_ [ xx -6, yy (l.val + 5), A.textAnchor "end" ] [ S.text l.label ]

        labels =
            List.map level2label levels
    in
    lines ++ labels |> S.g [ cc "axes" ]


points : Model -> Svg Msg
points m =
    let
        t =
            m.transform

        d2p =
            transform t

        morning =
            m.data
                |> List.filter (\d -> not d.even && d.rata >= t.dLow)
                |> List.map d2p

        evening =
            m.data
                |> List.filter (\d -> d.even && d.rata >= t.dLow)
                |> List.map d2p
    in
    S.g [ cc "points" ]
        [ S.g [ cc "morning" ] morning
        , S.g [ cc "evening" ] evening
        ]


box : String
box =
    [ -margin, -margin, width + 2 * margin, height + 2 * margin ]
        |> List.map String.fromInt
        |> String.join " "



-- Helpers


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


infoTextX : Int
infoTextX =
    width


infoTextY : Int
infoTextY =
    -10


height : Int
height =
    Transform.height


width : Int
width =
    Transform.width


margin : Int
margin =
    40


crossWidth : Int
crossWidth =
    10


transform : Transform -> Datum -> Svg Msg
transform t d =
    let
        ( x, y ) =
            Transform.transform t d
    in
    S.circle [ cx x, cy y, r 2 ] []
