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
    let
        lastCross =
            model.cross

        dummyCross =
            case List.head model.data of
                Just datum ->
                    { lastCross | rata = datum.rata }

                Nothing ->
                    lastCross

        transform =
            Transform.fromData (dummyCross :: model.data) start

        cross =
            Transform.restrict transform model.cross
    in
    { model | start = Start.fromInt start, transform = transform, cross = cross }


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
        dd =
            1 * dx

        dk =
            0.1 * toFloat dy

        cross =
            model.cross
                |> (\c -> { c | rata = c.rata + dd, kilo = c.kilo + dk })
                |> Transform.restrict model.transform
    in
    { model | cross = cross }


changeCross : ( Int, Int ) -> Model -> Model
changeCross point model =
    let
        cross =
            point
                |> Transform.reverse model.transform
                |> Transform.restrict model.transform
    in
    { model | cross = cross }
