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
                        if file == 9 && rank > 1 then
                            fenPieces current 1 (rank - 1) prev next

                        else
                            err

                    '1' ->
                        if file <= 8 then
                            fenPieces current (file + 1) rank prev next

                        else
                            err

                    '2' ->
                        if file <= 7 then
                            fenPieces current (file + 2) rank prev next

                        else
                            err

                    '3' ->
                        if file <= 6 then
                            fenPieces current (file + 3) rank prev next

                        else
                            err

                    '4' ->
                        if file <= 5 then
                            fenPieces current (file + 4) rank prev next

                        else
                            err

                    '5' ->
                        if file <= 4 then
                            fenPieces current (file + 5) rank prev next

                        else
                            err

                    '6' ->
                        if file <= 3 then
                            fenPieces current (file + 6) rank prev next

                        else
                            err

                    '7' ->
                        if file <= 2 then
                            fenPieces current (file + 7) rank prev next

                        else
                            err

                    '8' ->
                        if file == 1 then
                            fenPieces current 9 rank prev next

                        else
                            err

                    _ ->
                        if file <= 8 then
                            let
                                tryPiece =
                                    Piece.fromChar char
                            in
                            case tryPiece of
                                Just pieceType ->
                                    let
                                        piece =
                                            pieceType <| Square file rank

                                        position =
                                            { current | pieces = piece :: current.pieces }
                                    in
                                    fenPieces position (file + 1) rank prev next

                                Nothing ->
                                    err

                        else
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
