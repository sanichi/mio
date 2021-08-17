module Messages exposing (..)


type Msg
    = ChangeUnits String
    | ChangeStart Int
    | ChangePoint ( Int, Int )
    | UpdatePoint ( Int, Int )
