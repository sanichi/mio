module Types exposing (..)

import Array exposing (Array)
import Config


type alias Model =
    { width : Int
    , height : Int
    , focus : Focus
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
    , younger_siblings : People
    , older_siblings : People
    }


type alias Flags =
    { focus : Focus }


initModel : Flags -> Model
initModel flags =
    { width = Config.initialWidth
    , height = Config.initialHeight
    , focus = flags.focus
    }


picturePath : Int -> Person -> String
picturePath picture person =
    let
        total =
            Array.length person.pictures

        index =
            if total < 1 then
                0
            else
                picture % total
    in
        Array.get index person.pictures |> Maybe.withDefault defaultPicturePath


defaultPicturePath : String
defaultPicturePath =
    "/images/blank_woman.png"
