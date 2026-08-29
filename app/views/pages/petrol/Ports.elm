port module Ports exposing (..)

-- JS to Elm


port changeBegin : (Int -> msg) -> Sub msg


{-| Where in the graph the user clicked, in SVG user coordinates.
-}
port changeCross : (( Int, Int ) -> msg) -> Sub msg


{-| How far to move the selection: points along the current station's line,
then stations up or down the legend.
-}
port updateCross : (( Int, Int ) -> msg) -> Sub msg
