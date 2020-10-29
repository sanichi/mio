module Model exposing (Model, flipOrientation, init, toggleNotation)

import Months exposing (Months)
import Preferences exposing (Preferences)
import Unit exposing (Unit)


type alias Model =
    { months : Int
    , unit : Unit
    }


init : Preferences -> Model
init preferences =
    let
        months =
            Months.fromInt preferences.months

        unit =
            Unit.fromString preferences.unit
    in
    -- Debug.log "initial model" <| Model months unit
    Model months unit


flipOrientation : Model -> Model
flipOrientation model =
    model


toggleNotation : Model -> Model
toggleNotation model =
    model
