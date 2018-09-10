module Messages exposing (Msg(..))

import Time exposing (Posix)
import Types exposing (Focus)


type Msg
    = NoOp
    | GetFocus Int
    | GotFocus Focus
    | DisplayPerson Int
    | ShiftLeft
    | ShiftRight
    | SwitchFamily Int
    | Tick Posix
