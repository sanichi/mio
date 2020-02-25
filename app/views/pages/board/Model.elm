module Model exposing (Model, flip, init)

import Colour exposing (Colour)
import Position exposing (Position)
import Preferences exposing (Preferences)
import Square exposing (Square)


type alias Model =
    { position : Position
    , orientation : Colour
    , dots : List Square
    , crosses : List Square
    , stars : List Square
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

        dots =
            Square.fromList preferences.dots

        crosses =
            Square.fromList preferences.crosses

        stars =
            Square.fromList preferences.stars
    in
    Model position orientation dots crosses stars


flip : Model -> Model
flip model =
    { model | orientation = Colour.flip model.orientation }
