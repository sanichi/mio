module Model exposing (Model, changeStart, changeUnits, debugMsg, init)

import Data exposing (Data)
import Preferences exposing (Preferences)
import Start exposing (Start)
import Units exposing (Units)


type alias Model =
    { data : Data
    , debug : Bool
    , start : Start
    , units : Units
    }


init : Preferences -> Model
init preferences =
    let
        data =
            Data.combine preferences.kilos preferences.dates

        debug =
            preferences.debug

        start =
            Start.fromInt preferences.start

        units =
            Units.fromString preferences.units
    in
    Model data debug start units


debugMsg : Model -> String
debugMsg model =
    String.join " | "
        [ String.fromInt <| List.length model.data
        , Units.toString model.units
        , String.fromInt model.start
        ]


changeUnits : String -> Model -> Model
changeUnits units model =
    { model | units = Units.fromString units }


changeStart : Int -> Model -> Model
changeStart start model =
    { model | start = Start.fromInt start }
