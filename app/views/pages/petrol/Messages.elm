module Messages exposing (..)


type Msg
    = ChangeBegin Int
    | ChangeCross ( Int, Int )
    | UpdateCross ( Int, Int )
    | ToggleStation Int
