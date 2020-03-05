module Piece exposing (Category(..), Piece, fromChar)

import Colour exposing (Colour(..))
import Square exposing (Square)


type Category
    = King
    | Queen
    | Rook
    | Bishop
    | Knight
    | Pawn


type alias Piece =
    { colour : Colour
    , category : Category
    , square : Square
    }


type alias PieceType =
    Square -> Piece


fromChar : Char -> Maybe PieceType
fromChar char =
    case char of
        'K' ->
            Just (Piece White King)

        'Q' ->
            Just (Piece White Queen)

        'R' ->
            Just (Piece White Rook)

        'N' ->
            Just (Piece White Knight)

        'B' ->
            Just (Piece White Bishop)

        'P' ->
            Just (Piece White Pawn)

        'k' ->
            Just (Piece Black King)

        'q' ->
            Just (Piece Black Queen)

        'r' ->
            Just (Piece Black Rook)

        'n' ->
            Just (Piece Black Knight)

        'b' ->
            Just (Piece Black Bishop)

        'p' ->
            Just (Piece Black Pawn)

        _ ->
            Nothing
