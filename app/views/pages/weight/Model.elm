module Model exposing (Model, changeCross, changeBegin, changeEnd, changeUnits, debugMsg, init, updateCross)

import Data exposing (Data, Datum)
import Event exposing (Events, Event)
import Preferences exposing (Preferences)
import Transform exposing (Transform)
import Units exposing (Unit)


type alias Model =
    { data : Data
    , begin : Int
    , end : Int
    , units : Unit
    , transform : Transform
    , cross : Datum
    , events : Events
    , debug : Bool
    }


init : Preferences -> Model
init preferences =
    let
        data =
            Data.combine preferences.kilos preferences.dates

        begin =
            Preferences.begin preferences

        end =
            Preferences.end preferences

        units =
            Units.fromString preferences.units

        transform =
            Transform.fromData data begin end

        cross =
            startCross (List.head data) transform

        debug =
            preferences.debug

        events =
            Event.combine preferences.eventNames preferences.eventDates preferences.eventSpans
    in
    Model data begin end units transform cross events debug


debugMsg : Model -> String
debugMsg model =
    String.join " | "
        [ String.fromInt <| List.length model.data
        , Units.toString model.units
        , String.fromInt model.begin
        , String.fromInt model.end
        , String.fromInt <| List.length model.events
        ]


changeUnits : String -> Model -> Model
changeUnits units model =
    { model | units = Units.fromString units }


changeBegin : Int -> Model -> Model
changeBegin begin model =
    let
        transform =
            Transform.fromData model.data begin model.end

        cross =
            Transform.restrict transform model.cross
    in
    { model | begin = begin, transform = transform, cross = cross }


changeEnd : Int -> Model -> Model
changeEnd end model =
    let
        -- If the new end-year is a particular year rather than 0 (now) then increase
        -- the begin-months to 12 unless they are already 12 or more or zero (all).
        begin =
            if end == 0 || model.begin == 0 || model.begin >= 12 then
                model.begin
            else
                12

        transform =
            Transform.fromData model.data begin end

        cross =
            Transform.restrict transform model.cross
    in
    { model | end = end , transform = transform, cross = cross, begin = begin }


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
