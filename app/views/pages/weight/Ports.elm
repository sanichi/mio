port module Ports exposing (..)


port changeUnits : (String -> msg) -> Sub msg


port changeBegin : (Int -> msg) -> Sub msg


port changeEnd : (Int -> msg) -> Sub msg


port updateCross : (( Int, Int ) -> msg) -> Sub msg


port changeCross : (( Int, Int ) -> msg) -> Sub msg
