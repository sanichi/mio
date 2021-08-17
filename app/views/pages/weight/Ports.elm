port module Ports exposing (..)


port changeUnits : (String -> msg) -> Sub msg


port changeStart : (Int -> msg) -> Sub msg


port changePoint : (( Int, Int ) -> msg) -> Sub msg


port updatePoint : (( Int, Int ) -> msg) -> Sub msg
