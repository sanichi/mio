module Position exposing (Position, fromFen)

import Colour exposing (Colour(..))
import Piece exposing (Piece)
import Square exposing (Square)


type alias Position =
    { pieces : List Piece
    , move : Colour
    }


type alias ParseResult =
    Result ( Position, String, String ) Position


fromFen : String -> ParseResult
fromFen fen =
    fenPieces emptyBoard 1 8 "" fen


fenPieces : Position -> Int -> Int -> String -> String -> ParseResult
fenPieces current file rank consumed remaining =
    if file == 9 && rank == 1 then
        fenMove current consumed remaining

    else
        let
            split =
                String.uncons remaining

            err =
                Err ( current, consumed, remaining )
        in
        case split of
            Just ( char, next ) ->
                let
                    prev =
                        consumed ++ String.fromChar char
                in
                case char of
                    '/' ->
                        fenPieces current (file - 8) (rank - 1) prev next

                    '1' ->
                        fenPieces current (file + 1) rank prev next

                    '2' ->
                        fenPieces current (file + 2) rank prev next

                    '3' ->
                        fenPieces current (file + 3) rank prev next

                    '4' ->
                        fenPieces current (file + 4) rank prev next

                    '5' ->
                        fenPieces current (file + 5) rank prev next

                    '6' ->
                        fenPieces current (file + 6) rank prev next

                    '7' ->
                        fenPieces current (file + 7) rank prev next

                    '8' ->
                        fenPieces current (file + 8) rank prev next

                    _ ->
                        let
                            tryPiece =
                                Piece.fromChar char

                            square =
                                Square file rank
                        in
                        case tryPiece of
                            Just pieceType ->
                                case Piece.place pieceType square of
                                    Just piece ->
                                        let
                                            position =
                                                { current | pieces = piece :: current.pieces }
                                        in
                                        fenPieces position (file + 1) rank prev next

                                    Nothing ->
                                        err

                            Nothing ->
                                err

            Nothing ->
                err


fenMove : Position -> String -> String -> ParseResult
fenMove current consumed remaining =
    let
        split =
            String.uncons remaining

        err =
            Err ( current, consumed, remaining )
    in
    case split of
        Just ( char, next ) ->
            let
                prev =
                    consumed ++ String.fromChar char
            in
            case char of
                ' ' ->
                    fenMove current prev next

                'w' ->
                    fenEnd { current | move = White }

                'b' ->
                    fenEnd { current | move = Black }

                _ ->
                    err

        Nothing ->
            err


fenEnd : Position -> ParseResult
fenEnd position =
    Ok position


emptyBoard : Position
emptyBoard =
    { pieces = []
    , move = White
    }
