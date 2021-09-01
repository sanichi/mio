module Model exposing (Model, changePoint, changeStart, changeUnits, debugMsg, init, updatePoint)

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
    , point : ( Int, Int )
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

        point =
            startPoint (List.head data) transform

        debug =
            preferences.debug
    in
    Model data start units transform point debug


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


startPoint : Maybe Datum -> Transform -> ( Int, Int )
startPoint md t =
    case md of
        Just d ->
            restrict <| Transform.transform t d

        Nothing ->
            ( Transform.width // 2, Transform.height // 2 )


updatePoint : ( Int, Int ) -> Model -> Model
updatePoint ( dx, dy ) model =
    let
        ( x, y ) =
            model.point
    in
    { model | point = restrict ( x + dx, y + dy ) }


changePoint : ( Int, Int ) -> Model -> Model
changePoint point model =
    { model | point = restrict point }


restrict : ( Int, Int ) -> ( Int, Int )
restrict ( i, j ) =
    let
        x =
            if i < 0 then
                0

            else if i > Transform.width then
                Transform.width

            else
                i

        y =
            if j < 0 then
                0

            else if j > Transform.height then
                Transform.height

            else
                j
    in
    ( x, y )
