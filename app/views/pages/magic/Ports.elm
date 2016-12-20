port module Ports exposing (..)


port waitAMoment : () -> Cmd msg


port continue : (() -> msg) -> Sub msg
