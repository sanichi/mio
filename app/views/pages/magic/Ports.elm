port module Ports exposing (..)


port waitAMoment : Int -> Cmd msg


port continue : (Int -> msg) -> Sub msg
