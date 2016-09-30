module Messages exposing (..)

import Http


type Msg
    = CounterIncrement
    | CounterReset
    | CheckRequest
    | CheckFail Http.Error
    | CheckSucceed ( Bool, String )
    | RandomRequest
    | RandomResponse Int
