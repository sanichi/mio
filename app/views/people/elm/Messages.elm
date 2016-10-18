module Messages exposing (..)

import Types exposing (Focus)


type Msg
    = NoOp
    | GotFocus Focus
    | GetFocus Int
    | DisplayPerson Int
