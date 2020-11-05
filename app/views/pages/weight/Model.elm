module Model exposing (Model, debugMsg, flipOrientation, init, toggleNotation)

import Months exposing (Months)
import Preferences exposing (Preferences)
import Units exposing (Units)


type alias Model =
    { debug : Bool
    , kilos : List Float
    , start : Int
    , units : Units
    }


init : Preferences -> Model
init preferences =
    let
        debug =
            preferences.debug

        kilos =
            preferences.kilos

        start =
            Months.fromInt preferences.start

        units =
            Units.fromString preferences.units
    in
    Model debug kilos start units


debugMsg : Model -> String
debugMsg model =
    String.join " | "
        [ String.fromInt <| List.length model.kilos
        , Units.toString model.units
        , String.fromInt model.start
        ]


flipOrientation : Model -> Model
flipOrientation model =
    model


toggleNotation : Model -> Model
toggleNotation model =
    model
