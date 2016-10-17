module Messages exposing (..)

import Types exposing (Focus)


type Msg
    = NoOp
    | Refocus Focus
    | PersonId Int
