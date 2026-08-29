module View exposing (box, fromModel, legend)

import Array
import Data exposing (Point, Series)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Messages exposing (Msg(..))
import Model exposing (Model)
import Station
import Svg as S exposing (Attribute, Svg)
import Svg.Attributes as A
import Transform exposing (Level, Transform)


fromModel : Model -> List (Svg Msg)
fromModel m =
    [ clip, frame, levelsd m, levelsp m, series m, cross m, info m, debug m ]


box : String
box =
    [ -leftMargin, -margin, width + leftMargin + margin, height + 2 * margin ]
        |> List.map String.fromInt
        |> String.join " "


{-| Tick boxes to show and hide each station's line, named in its own colour so
that the legend doubles as the key to the graph.
-}
legend : Model -> Html Msg
legend m =
    m.stations
        |> Array.toIndexedList
        |> List.map item
        |> H.div [ HA.class "petrol-legend" ]



-- The graph


{-| Lines and points are clipped to the graph area, so a station whose prices
straddle the window still has its line drawn across it. The few pixels of slack
keep points that sit exactly on an axis from being sliced in half.
-}
clip : Svg Msg
clip =
    S.defs []
        [ S.clipPath [ A.id clipId ]
            [ S.rect
                [ A.x (String.fromInt -slack)
                , A.y (String.fromInt -slack)
                , A.width (String.fromInt (width + 2 * slack))
                , A.height (String.fromInt (height + 2 * slack))
                ]
                []
            ]
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

        lines =
            List.map (\l -> S.line [ x1 l.val, y1 0, x2 l.val, y2 height ] []) levels

        labels =
            List.map (\l -> S.text_ [ xx l.val, yy (height + 17) ] [ tt l.label ]) levels
    in
    lines ++ labels |> S.g [ cc "axes" ]


levelsp : Model -> Svg Msg
levelsp m =
    let
        levels =
            Transform.levelsp m.transform

        lines =
            List.map (\l -> S.line [ x1 -3, y1 l.val, x2 width, y2 l.val ] []) levels

        labels =
            List.map (\l -> S.text_ [ xx -7, yy (l.val + 5), cc "ylabel" ] [ tt l.label ]) levels
    in
    lines ++ labels |> S.g [ cc "axes" ]


series : Model -> Svg Msg
series m =
    m.data
        |> Array.toIndexedList
        |> List.filterMap
            (\( index, points ) ->
                if shown index m then
                    Just (station m index points)

                else
                    Nothing
            )
        |> S.g [ cc "series", A.clipPath ("url(#" ++ clipId ++ ")") ]


station : Model -> Int -> Series -> Svg Msg
station m index points =
    let
        colour =
            "#" ++ Station.colourOf index m.stations

        plotted =
            points |> Array.toList |> List.map (Transform.transform m.transform)

        selected =
            m.cross |> Maybe.map (\c -> c.station == index) |> Maybe.withDefault False

        line =
            S.polyline
                [ A.points (String.join " " (List.map pair plotted))
                , A.stroke colour
                , A.strokeWidth
                    (if selected then
                        "2.5"

                     else
                        "1.2"
                    )
                ]
                []

        dots =
            List.map (\( x, y ) -> S.circle [ cx x, cy y, r 3, A.fill colour ] []) plotted
    in
    S.g [] (line :: dots)


cross : Model -> Svg Msg
cross m =
    case ( m.cross, Model.crossPoint m ) of
        ( Just c, Just point ) ->
            let
                ( x, y ) =
                    Transform.transform m.transform point

                colour =
                    "#" ++ Station.colourOf c.station m.stations
            in
            S.g [ cc "cross", A.stroke colour ]
                [ S.line [ x1 (x - crossWidth), y1 y, x2 (x + crossWidth), y2 y ] []
                , S.line [ x1 x, y1 (y - crossWidth), x2 x, y2 (y + crossWidth) ] []
                , S.circle [ cx x, cy y, r 5, A.fill "none" ] []
                ]

        _ ->
            S.g [] []


{-| What the selected point is: when it was recorded, whose it is, and what the
price was, written in that station's colour.
-}
info : Model -> Svg Msg
info m =
    case ( m.cross, Model.crossPoint m ) of
        ( Just c, Just point ) ->
            let
                text =
                    String.join " "
                        [ Data.dateFormat point.rata
                        , Station.nameOf c.station m.stations
                        , Data.penceFormat point.pence
                        ]
            in
            S.text_
                [ xx (width // 2)
                , yy -12
                , cc "info"
                , A.fill ("#" ++ Station.colourOf c.station m.stations)
                ]
                [ tt text ]

        _ ->
            S.g [] []


debug : Model -> Svg Msg
debug m =
    if m.debug then
        S.text_ [ xx (width // 2), yy 60, cc "debug" ] [ tt (Model.debugMsg m) ]

    else
        S.g [] []



-- The legend


item : ( Int, Station.Station ) -> Html Msg
item ( index, s ) =
    H.label [ HA.class "petrol-legend-item" ]
        [ H.input
            [ HA.type_ "checkbox"
            , HA.class "form-check-input"
            , HA.checked s.shown
            , HE.onCheck (\_ -> ToggleStation index)
            ]
            []
        , H.span [ HA.style "color" ("#" ++ s.colour) ] [ H.text s.name ]
        ]



-- Helpers


shown : Int -> Model -> Bool
shown index m =
    Array.get index m.stations |> Maybe.map .shown |> Maybe.withDefault False


pair : ( Int, Int ) -> String
pair ( x, y ) =
    String.fromInt x ++ "," ++ String.fromInt y


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


x1 : Int -> Attribute Msg
x1 i =
    A.x1 <| String.fromInt i


x2 : Int -> Attribute Msg
x2 i =
    A.x2 <| String.fromInt i


y1 : Int -> Attribute Msg
y1 i =
    A.y1 <| String.fromInt i


y2 : Int -> Attribute Msg
y2 i =
    A.y2 <| String.fromInt i


tt : String -> Svg Msg
tt t =
    S.text t



-- Dimensions


clipId : String
clipId =
    "petrol-clip"


height : Int
height =
    Transform.height


width : Int
width =
    Transform.width


margin : Int
margin =
    40


leftMargin : Int
leftMargin =
    50


crossWidth : Int
crossWidth =
    10


slack : Int
slack =
    4
