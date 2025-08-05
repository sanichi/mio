port module Ports exposing (..)


-- JS to Elm


port changeUnits : (String -> msg) -> Sub msg


port changeBegin : (Int -> msg) -> Sub msg


port changeEnd : (Int -> msg) -> Sub msg


port updateCross : (( Int, Int ) -> msg) -> Sub msg


port changeCross : (( Int, Int ) -> msg) -> Sub msg


-- Elm to JS


port adjustBegin : Int -> Cmd msg
