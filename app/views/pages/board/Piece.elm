module Piece exposing (Category(..), Colour(..), Piece, fromChar, place)

import Square exposing (Square)


type Colour
    = Black
    | White


type Category
    = King
    | Queen
    | Rook
    | Bishop
    | Knight
    | Pawn


type alias Piece =
    { col : Colour
    , cat : Category
    , file : Int
    , rank : Int
    }


type alias PieceType =
    Int -> Int -> Piece


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


place : PieceType -> Square -> Maybe Piece
place pieceType square =
    if Square.valid square then
        Just (pieceType square.file square.rank)

    else
        Nothing
