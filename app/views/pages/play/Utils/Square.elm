module Utils.Square exposing (Square, fromString)


type alias Square =
    { file : Int
    , rank : Int
    }


valid : Square -> Bool
valid square =
    square.file >= 1 && square.file <= 8 && square.file >= 1 && square.file <= 8


fromString : String -> Maybe Square
fromString str =
    let
        square =
            case String.toList <| String.toLower str of
                file :: (rank :: []) ->
                    Square (Char.toCode file - 96) (Char.toCode rank - 48)

                _ ->
                    Square 0 0
    in
    if valid square then
        Just square

    else
        Nothing
