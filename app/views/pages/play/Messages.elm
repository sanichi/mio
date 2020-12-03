module Messages exposing (..)


type Msg
    = CounterIncrement
    | CounterDecrement
    | CounterReset
    | DniIncrement
    | DniDecrement
    | DniCycle
    | RandomRequest
    | RandomResponse Int
