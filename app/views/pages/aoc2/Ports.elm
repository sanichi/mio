port module Ports exposing (..)


port getData : ( Int, Int ) -> Cmd msg


port newData : (String -> msg) -> Sub msg


port prepareAnswer : Int -> Cmd msg


port startAnswer : (Int -> msg) -> Sub msg


port concludeAnswer : Int -> Cmd msg


port finishAnswer : (Int -> msg) -> Sub msg
