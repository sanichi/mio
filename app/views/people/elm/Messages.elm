module Messages exposing (..)

import Types exposing (Focus)
import Time exposing (Time)


type Msg
    = NoOp
    | GetFocus Int
    | GotFocus Focus
    | DisplayPerson Int
    | Tick Time
