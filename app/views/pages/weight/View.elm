module View exposing (fromModel)

import Html exposing (Html)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Svg as S exposing (Svg)
import Svg.Attributes as A
import Svg.Events exposing (onClick)


fromModel : Model -> List (Svg Msg)
fromModel model =
    [ frame ]


frame : Svg Msg
frame =
    let
        borderStyle =
            "stroke:black;stroke-width:2;"
    in
    S.g []
        [ S.line [ A.x1 "0", A.y1 "0", A.x2 "360", A.y2 "0", A.style borderStyle ] []
        , S.line [ A.x1 "360", A.y1 "0", A.x2 "360", A.y2 "360", A.style borderStyle ] []
        , S.line [ A.x1 "0", A.y1 "360", A.x2 "360", A.y2 "360", A.style borderStyle ] []
        , S.line [ A.x1 "0", A.y1 "0", A.x2 "0", A.y2 "360", A.style borderStyle ] []
        ]
