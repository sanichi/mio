module Messages exposing (..)

import Types exposing (Focus)


type Msg
    = NoOp
    | GetFocus Int
    | GotFocus Focus
    | DisplayPerson Int
