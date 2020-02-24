module Model exposing (Model)

import Piece exposing (Colour(..))
import Position exposing (Position)
import Square exposing (Square)


type alias Model =
    { position : Position
    , orientation : Colour
    , dots : List Square
    }
