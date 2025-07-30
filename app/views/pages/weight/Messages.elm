module Messages exposing (..)


type Msg
    = ChangeUnits String
    | ChangeBegin Int
    | ChangeEnd Int
    | ChangeCross ( Int, Int )
    | UpdateCross ( Int, Int )
