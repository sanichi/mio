port module Ports exposing (..)


port waitAMoment : Int -> Cmd msg


port continue : (() -> msg) -> Sub msg
