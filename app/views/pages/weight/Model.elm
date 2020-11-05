module Model exposing (Model, changeStart, changeUnits, debugMsg, init)

import Preferences exposing (Preferences)
import Start exposing (Start)
import Units exposing (Units)


type alias Model =
    { debug : Bool
    , kilos : List Float
    , start : Start
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
            Start.fromInt preferences.start

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


changeUnits : String -> Model -> Model
changeUnits units model =
    { model | units = Units.fromString units }


changeStart : Int -> Model -> Model
changeStart start model =
    { model | start = Start.fromInt start }
