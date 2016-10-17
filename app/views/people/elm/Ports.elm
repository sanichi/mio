port module Ports exposing (..)

import Types exposing (Focus)


port refocus : (Focus -> msg) -> Sub msg


port personId : Int -> Cmd msg
