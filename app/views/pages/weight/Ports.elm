port module Ports exposing (..)


port changeUnits : (String -> msg) -> Sub msg


port changeStart : (Int -> msg) -> Sub msg


port updateCross : (( Int, Int ) -> msg) -> Sub msg


port changeCross : (( Int, Int ) -> msg) -> Sub msg
