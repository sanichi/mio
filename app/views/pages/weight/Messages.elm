module Messages exposing (..)


type Msg
    = ChangeUnits String
    | ChangeStart Int
    | ChangeCross ( Int, Int )
    | UpdateCross ( Int, Int )
