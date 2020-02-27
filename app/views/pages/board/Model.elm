module Model exposing (Model, flipOrientation, init, toggleNotation)

import Colour exposing (Colour)
import Mark exposing (Mark)
import Position exposing (Position)
import Preferences exposing (Preferences)


type alias Model =
    { position : Position
    , orientation : Colour
    , notation : Bool
    , marks : List Mark
    }


init : Preferences -> Model
init preferences =
    let
        orientation =
            Colour.fromString preferences.orientation

        position =
            case Position.fromFen preferences.fen of
                Ok pos ->
                    pos

                Err ( current, consumed, remaining ) ->
                    current

        notation =
            preferences.notation

        marks =
            Mark.fromList preferences.marks
    in
    Model position orientation notation marks


flipOrientation : Model -> Model
flipOrientation model =
    { model | orientation = Colour.not model.orientation }


toggleNotation : Model -> Model
toggleNotation model =
    { model | notation = not model.notation }
