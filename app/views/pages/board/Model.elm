module Model exposing (Model, flip, init)

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


flip : Model -> Model
flip model =
    { model | orientation = Colour.flip model.orientation }
