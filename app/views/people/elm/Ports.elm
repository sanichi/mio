port module Ports exposing (..)

import Types exposing (Focus)


port getFocus : Int -> Cmd msg


port gotFocus : (Focus -> msg) -> Sub msg


port displayPerson : Int -> Cmd msg
