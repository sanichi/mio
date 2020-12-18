module Messages exposing (..)


type Msg
    = CounterIncrement
    | CounterDecrement
    | CounterReset
    | DniIncrement
    | DniDecrement
    | DniCycle
    | MagicIncrement
    | MagicDecrement
    | RandomRequest
    | RandomResponse Int
