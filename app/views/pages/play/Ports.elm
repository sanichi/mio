port module Ports exposing (..)


port random_request : () -> Cmd msg


port random_response : (Int -> msg) -> Sub msg
