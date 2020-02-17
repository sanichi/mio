module Position exposing (Position, initialPosition)

import Piece exposing (Category(..), Colour(..), Piece)


type alias Position =
    List Piece


initialPosition : Position
initialPosition =
    [ Piece White King 5 1
    , Piece White Queen 4 1
    , Piece White Rook 1 1
    , Piece White Rook 8 1
    , Piece White Bishop 3 1
    , Piece White Bishop 6 1
    , Piece White Knight 2 1
    , Piece White Knight 7 1
    , Piece White Pawn 1 2
    , Piece White Pawn 2 2
    , Piece White Pawn 3 2
    , Piece White Pawn 4 2
    , Piece White Pawn 5 2
    , Piece White Pawn 6 2
    , Piece White Pawn 7 2
    , Piece White Pawn 8 2
    , Piece Black King 5 8
    , Piece Black Queen 4 8
    , Piece Black Rook 1 8
    , Piece Black Rook 8 8
    , Piece Black Bishop 3 8
    , Piece Black Bishop 6 8
    , Piece Black Knight 2 8
    , Piece Black Knight 7 8
    , Piece Black Pawn 1 7
    , Piece Black Pawn 2 7
    , Piece Black Pawn 3 7
    , Piece Black Pawn 4 7
    , Piece Black Pawn 5 7
    , Piece Black Pawn 6 7
    , Piece Black Pawn 7 7
    , Piece Black Pawn 8 7
    ]
