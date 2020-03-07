module Model exposing (Model, flipOrientation, init, toggleNotation)

import Colour exposing (Colour)
import Mark exposing (Mark)
import Position exposing (Position)
import Preferences exposing (Preferences)
import Scheme exposing (Scheme)


type alias Model =
    { position : Position
    , orientation : Colour
    , notation : Bool
    , marks : List Mark
    , scheme : Scheme
    , error : Maybe String
    }


init : Preferences -> Model
init preferences =
    let
        orientation =
            Colour.fromString preferences.orientation

        ( position, error ) =
            case Position.fromFen preferences.fen of
                Ok pos ->
                    ( pos, Nothing )

                Err ( current, consumed, remaining ) ->
                    ( current, Just <| Position.errorMessage consumed remaining )

        notation =
            preferences.notation

        marks =
            Mark.fromList preferences.marks

        scheme =
            Scheme.fromString preferences.scheme
    in
    Model position orientation notation marks scheme error


flipOrientation : Model -> Model
flipOrientation model =
    { model | orientation = Colour.not model.orientation }


toggleNotation : Model -> Model
toggleNotation model =
    { model | notation = not model.notation }
