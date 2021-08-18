module Model exposing (Model, changePoint, changeStart, changeUnits, debugMsg, init, pointMsg, updatePoint)

import Data exposing (Data)
import Preferences exposing (Preferences)
import Start exposing (Start)
import Transform
import Units exposing (Unit)


type alias Model =
    { data : Data
    , debug : Bool
    , start : Start
    , units : Unit
    , point : ( Int, Int )
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

        point =
            ( 500, 220 )
    in
    Model data debug start units point


debugMsg : Model -> String
debugMsg model =
    String.join " | "
        [ String.fromInt <| List.length model.data
        , Units.toString model.units
        , String.fromInt model.start
        ]


pointMsg : Model -> String
pointMsg model =
    String.join ","
        [ String.fromInt <| Tuple.first model.point
        , String.fromInt <| Tuple.second model.point
        ]


changeUnits : String -> Model -> Model
changeUnits units model =
    { model | units = Units.fromString units }


changeStart : Int -> Model -> Model
changeStart start model =
    { model | start = Start.fromInt start }


changePoint : ( Int, Int ) -> Model -> Model
changePoint ( dx, dy ) model =
    let
        ( x, y ) =
            model.point
    in
    { model | point = restrict ( x + dx, y + dy ) }


updatePoint : ( Int, Int ) -> Model -> Model
updatePoint point model =
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
