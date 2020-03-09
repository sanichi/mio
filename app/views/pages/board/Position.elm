module Position exposing (Position, errorMessage, fromFen)

import Castle exposing (Castle)
import Colour exposing (Colour(..))
import Piece exposing (Piece)
import Square exposing (Square)


type alias Position =
    { pieces : List Piece
    , move : Colour
    , castle : Castle
    , enPassant : Maybe Square
    , halfMove : Int
    , fullMove : Int
    }


type alias ParseResult =
    Result ( Position, String, String ) Position


fromFen : String -> ParseResult
fromFen fen =
    fenPieces emptyBoard 1 8 "" fen


fenPieces : Position -> Int -> Int -> String -> String -> ParseResult
fenPieces current file rank consumed remaining =
    let
        ( err, char_, ( prev, next ) ) =
            prepare current consumed remaining
    in
    case char_ of
        Just char ->
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

                ' ' ->
                    if file == 9 && rank == 1 then
                        fenMove current False prev next

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


fenMove : Position -> Bool -> String -> String -> ParseResult
fenMove current done consumed remaining =
    let
        ( err, char_, ( prev, next ) ) =
            prepare current consumed remaining
    in
    case char_ of
        Just char ->
            case char of
                'w' ->
                    if done then
                        err

                    else
                        fenMove { current | move = White } True prev next

                'b' ->
                    if done then
                        err

                    else
                        fenMove { current | move = Black } True prev next

                ' ' ->
                    if done then
                        fenCastle current 0 prev next

                    else
                        err

                _ ->
                    err

        Nothing ->
            if done then
                Ok current

            else
                err


fenCastle : Position -> Int -> String -> String -> ParseResult
fenCastle current state consumed remaining =
    let
        ( err, char_, ( prev, next ) ) =
            prepare current consumed remaining
    in
    case char_ of
        Just char ->
            case char of
                '-' ->
                    if state == 0 then
                        fenCastle current 2 prev next

                    else
                        err

                'K' ->
                    if current.castle.whiteKing || state == 2 then
                        err

                    else
                        fenCastle { current | castle = Castle.wk current.castle } 1 prev next

                'Q' ->
                    if current.castle.whiteQueen || state == 2 then
                        err

                    else
                        fenCastle { current | castle = Castle.wq current.castle } 1 prev next

                'k' ->
                    if current.castle.blackKing || state == 2 then
                        err

                    else
                        fenCastle { current | castle = Castle.bk current.castle } 1 prev next

                'q' ->
                    if current.castle.blackQueen || state == 2 then
                        err

                    else
                        fenCastle { current | castle = Castle.bq current.castle } 1 prev next

                ' ' ->
                    if state == 0 then
                        err

                    else
                        fenEnPassant current "" prev next

                _ ->
                    err

        Nothing ->
            Ok current


fenEnPassant : Position -> String -> String -> String -> ParseResult
fenEnPassant current state consumed remaining =
    let
        ( err, char_, ( prev, next ) ) =
            prepare current consumed remaining
    in
    case char_ of
        Just char ->
            case char of
                '-' ->
                    if state == "" then
                        fenEnPassant current "-" prev next

                    else
                        err

                ' ' ->
                    if state == "-" then
                        fenHalfMove current False prev next

                    else
                        err

                _ ->
                    if state == "" then
                        fenEnPassant current (String.fromChar char) prev next

                    else
                        let
                            square_ =
                                Square.fromString (state ++ String.fromChar char)
                        in
                        case square_ of
                            Just sq ->
                                if (current.move == White && sq.rank == 6) || (current.move == Black && sq.rank == 3) then
                                    fenEnPassant { current | enPassant = square_ } "-" prev next

                                else
                                    err

                            Nothing ->
                                err

        Nothing ->
            if state == "" || state == "-" then
                Ok current

            else
                err


fenHalfMove : Position -> Bool -> String -> String -> ParseResult
fenHalfMove current done consumed remaining =
    let
        ( err, char_, ( prev, next ) ) =
            prepare current consumed remaining
    in
    case char_ of
        Just char ->
            case char of
                ' ' ->
                    if done || current.halfMove > 0 then
                        fenFullMove current False prev next

                    else
                        err

                _ ->
                    if done then
                        err

                    else
                        let
                            num_ =
                                String.toInt (String.fromChar char)
                        in
                        case num_ of
                            Just num ->
                                if num == 0 && current.halfMove == 0 then
                                    fenHalfMove current True prev next

                                else
                                    fenHalfMove { current | halfMove = 10 * current.halfMove + num } False prev next

                            Nothing ->
                                err

        Nothing ->
            Ok current


fenFullMove : Position -> Bool -> String -> String -> ParseResult
fenFullMove current started consumed remaining =
    let
        ( err, char_, ( prev, next ) ) =
            prepare current consumed remaining
    in
    case char_ of
        Just char ->
            let
                num_ =
                    String.toInt (String.fromChar char)
            in
            case num_ of
                Just num ->
                    if started then
                        if current.fullMove == 0 then
                            err

                        else
                            fenFullMove { current | fullMove = current.fullMove * 10 + num } True prev next

                    else
                        fenFullMove { current | fullMove = num } True prev next

                _ ->
                    err

        Nothing ->
            Ok current


prepare : Position -> String -> String -> ( ParseResult, Maybe Char, ( String, String ) )
prepare current consumed remaining =
    let
        err =
            Err ( current, consumed, remaining )

        split =
            String.uncons remaining

        ( char_, next ) =
            case split of
                Just ( char, next_ ) ->
                    ( Just char, next_ )

                Nothing ->
                    ( Nothing, remaining )

        prev =
            case char_ of
                Just char ->
                    consumed ++ String.fromChar char

                Nothing ->
                    consumed
    in
    ( err, char_, ( prev, next ) )


emptyBoard : Position
emptyBoard =
    { pieces = []
    , move = White
    , castle = Castle.init
    , enPassant = Nothing
    , halfMove = 0
    , fullMove = 1
    }


errorMessage : String -> String -> String
errorMessage consumed remaining =
    let
        preface =
            "FEN parsing error: "
    in
    preface
        ++ consumed
        ++ remaining
        ++ "\n"
        ++ String.repeat (String.length preface + String.length consumed) " "
        ++ "^"
        ++ "\n"
