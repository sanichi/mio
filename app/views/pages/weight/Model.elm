module Model exposing (Model, debugMsg, flipOrientation, init, toggleNotation)

import Months exposing (Months)
import Preferences exposing (Preferences)
import Unit exposing (Unit)


type alias Model =
    { debug : Bool
    , kilos : List Float
    , months : Int
    , unit : Unit
    }


init : Preferences -> Model
init preferences =
    let
        debug =
            preferences.debug

        kilos =
            preferences.kilos

        months =
            Months.fromInt preferences.months

        unit =
            Unit.fromString preferences.unit
    in
    Model debug kilos months unit


debugMsg : Model -> String
debugMsg model =
    String.join " | "
        [ String.fromInt <| List.length model.kilos
        , Unit.toString model.unit
        , String.fromInt model.months
        ]


flipOrientation : Model -> Model
flipOrientation model =
    model


toggleNotation : Model -> Model
toggleNotation model =
    model
