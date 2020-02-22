module Position exposing (Position, emptyBoard, fromFen, initialPosition)

import Piece exposing (Category(..), Colour(..), Piece, fromChar, place)
import Preferences exposing (defaultFen)


type alias Position =
    List Piece


fromFen : String -> Result String Position
fromFen fen =
    if fen == defaultFen then
        Ok initialPosition

    else
        fromFen_ emptyBoard 1 8 fen


fromFen_ : Position -> Int -> Int -> String -> Result String Position
fromFen_ current file rank fen =
    if file == 9 && rank == 1 then
        Ok current

    else
        let
            split =
                String.uncons fen
        in
        case split of
            Just ( char, rest ) ->
                case char of
                    '/' ->
                        fromFen_ current (file - 8) (rank - 1) rest

                    '1' ->
                        fromFen_ current (file + 1) rank rest

                    '2' ->
                        fromFen_ current (file + 2) rank rest

                    '3' ->
                        fromFen_ current (file + 3) rank rest

                    '4' ->
                        fromFen_ current (file + 4) rank rest

                    '5' ->
                        fromFen_ current (file + 5) rank rest

                    '6' ->
                        fromFen_ current (file + 6) rank rest

                    '7' ->
                        fromFen_ current (file + 7) rank rest

                    '8' ->
                        fromFen_ current (file + 8) rank rest

                    _ ->
                        let
                            tryPiece =
                                fromChar char
                        in
                        case tryPiece of
                            Just pieceType ->
                                case place pieceType file rank of
                                    Just piece ->
                                        fromFen_ (piece :: current) (file + 1) rank rest

                                    Nothing ->
                                        Err fen

                            Nothing ->
                                Err fen

            Nothing ->
                Err fen


emptyBoard : Position
emptyBoard =
    []


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
