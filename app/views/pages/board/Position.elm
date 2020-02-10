module Position exposing (Position, initialPosition)

import Piece exposing (Category(..), Colour(..), Piece)


type alias Position =
    List Piece


initialPosition : Position
initialPosition =
    [ Piece White King 5 1
    , Piece White Queen 4 1
    , Piece Black King 5 8
    , Piece Black Queen 4 8
    ]
