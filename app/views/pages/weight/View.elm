module View exposing (box, fromModel)

import Html exposing (Html)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Svg as S exposing (Attribute, Svg)
import Svg.Attributes as A
import Svg.Events exposing (onClick)


fromModel : Model -> List (Svg Msg)
fromModel model =
    let
        basics =
            [ frame ]
    in
    if model.debug then
        debug model :: basics

    else
        basics


debug : Model -> Svg Msg
debug model =
    S.text_ [ xx debugTextX, yy debugTextY, cc "debug" ] [ tt <| Model.debugMsg model ]


frame : Svg Msg
frame =
    let
        borderStyle =
            "stroke:black;stroke-width:2;"
    in
    S.g []
        [ S.line [ x1 0, y1 0, x2 width, y2 0 ] []
        , S.line [ x1 width, y1 0, x2 width, y2 height ] []
        , S.line [ x1 width, y1 height, x2 0, y2 height ] []
        , S.line [ x1 0, y1 height, x2 0, y2 0 ] []
        ]



-- Helpers


box : String
box =
    "0 0 " ++ String.fromInt width ++ " " ++ String.fromInt height


cc : String -> Attribute Msg
cc c =
    A.class c


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


tt : String -> Svg Msg
tt t =
    S.text t
