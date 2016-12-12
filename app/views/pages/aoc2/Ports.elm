port module Ports exposing (..)


port newData : (String -> msg) -> Sub msg


port getData : ( Int, Int ) -> Cmd msg
