module View exposing (box, fromModel)

import Data exposing (Datum)
import Html exposing (Html)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Svg as S exposing (Attribute, Svg)
import Svg.Attributes as A
import Transform exposing (Transform)


fromModel : Model -> List (Svg Msg)
fromModel m =
    let
        t =
            Transform.fromData m.data m.start width height

        components =
            [ debug m, frame, points m t ]
    in
    if m.debug then
        components

    else
        List.drop 1 components


debug : Model -> Svg Msg
debug m =
    S.text_ [ xx debugTextX, yy debugTextY, cc "debug" ] [ tt <| Model.debugMsg m ]


frame : Svg Msg
frame =
    S.g [ cc "frame" ]
        [ S.line [ x1 0, y1 0, x2 width, y2 0 ] []
        , S.line [ x1 width, y1 0, x2 width, y2 height ] []
        , S.line [ x1 width, y1 height, x2 0, y2 height ] []
        , S.line [ x1 0, y1 height, x2 0, y2 0 ] []
        ]


points : Model -> Transform -> Svg Msg
points m t =
    let
        d2p =
            point t

        morning =
            m.data
                |> List.filter Data.isMorning
                |> List.map d2p

        evening =
            m.data
                |> List.filter Data.isEvening
                |> List.map d2p
    in
    S.g [ cc "points" ]
        [ S.g [ cc "morning" ] morning
        , S.g [ cc "evening" ] evening
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
    440


width : Int
width =
    1000


point : Transform -> Datum -> Svg Msg
point t d =
    let
        ( x, y ) =
            Transform.transform t d
    in
    S.circle [ cx x, cy y, r 2 ] []
