port module Ports exposing (..)


port problem : (( Int, Int, String ) -> msg) -> Sub msg


port answers : String -> Cmd msg
