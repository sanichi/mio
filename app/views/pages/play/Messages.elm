module Messages exposing (..)


type Msg
    = CounterIncrement
    | CounterDecrement
    | CounterReset
    | DniIncrement
    | DniDecrement
    | DniCycle
    | ErasIncrement Int
    | ErasDecrement Int
    | MagicIncrement
    | MagicDecrement
    | RandomRequest
    | RandomResponse Int
