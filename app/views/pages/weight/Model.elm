module Model exposing (Model, flipOrientation, init, toggleNotation)

import Preferences exposing (Preferences)
import Unit exposing (Unit)


type alias Model =
    { unit : Unit
    }


init : Preferences -> Model
init preferences =
    let
        unit =
            Unit.fromString preferences.unit
    in
    Model unit


flipOrientation : Model -> Model
flipOrientation model =
    model


toggleNotation : Model -> Model
toggleNotation model =
    model
