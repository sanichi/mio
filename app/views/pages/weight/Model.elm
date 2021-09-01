module Model exposing (Model, changeCross, changeStart, changeUnits, debugMsg, init, updateCross)

import Data exposing (Data, Datum)
import Preferences exposing (Preferences)
import Start exposing (Start)
import Transform exposing (Transform)
import Units exposing (Unit)


type alias Model =
    { data : Data
    , start : Start
    , units : Unit
    , transform : Transform
    , cross : Datum
    , debug : Bool
    }


init : Preferences -> Model
init preferences =
    let
        data =
            Data.combine preferences.kilos preferences.dates

        start =
            Start.fromInt preferences.start

        units =
            Units.fromString preferences.units

        transform =
            Transform.fromData data start

        cross =
            startCross (List.head data) transform

        debug =
            preferences.debug
    in
    Model data start units transform cross debug


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
    { model | start = Start.fromInt start, transform = Transform.fromData model.data start }


startCross : Maybe Datum -> Transform -> Datum
startCross md t =
    case md of
        Just datum ->
            datum

        Nothing ->
            Transform.reverse t ( Transform.width // 2, Transform.height // 2 )


updateCross : ( Int, Int ) -> Model -> Model
updateCross ( dx, dy ) model =
    let
        ( x, y ) =
            model.cross
                |> Transform.transform model.transform
                |> Transform.restrict

        cross =
            Transform.reverse model.transform ( x + dx, y + dy )
    in
    { model | cross = cross }


changeCross : ( Int, Int ) -> Model -> Model
changeCross point model =
    let
        cross =
            Transform.reverse model.transform point
    in
    { model | cross = cross }
