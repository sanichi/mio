module Types exposing (..)

import Array exposing (Array)


type alias Model =
    { focus : Focus
    , family : Int
    , picture : Int
    , shift : Int
    }


type alias Person =
    { id : Int
    , name : String
    , years : String
    , pictures : Array String
    }


type alias People =
    Array Person


type alias Family =
    { partner : Person
    , children : People
    }


type alias Families =
    Array Family


type alias Focus =
    { person : Person
    , father : Person
    , mother : Person
    , families : Families
    , youngerSiblings : People
    , olderSiblings : People
    }


type alias Flags =
    { focus : Focus
    }


initModel : Flags -> Model
initModel flags =
    { focus = flags.focus
    , family = 0
    , picture = 0
    , shift = 0
    }
