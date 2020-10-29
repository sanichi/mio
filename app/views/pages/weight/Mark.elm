module Mark exposing (Mark, Symbol(..), fromList)

import Square exposing (Square)


type Symbol
    = Cross
    | Dot
    | Star


type alias Mark =
    { symbol : Symbol
    , square : Square
    }


fromString : String -> Maybe Mark
fromString str =
    let
        ( char_, square_ ) =
            case String.toLower str |> String.uncons of
                Just ( ch, sq ) ->
                    ( ch, Square.fromString sq )

                _ ->
                    ( ' ', Nothing )

        symbol_ =
            case char_ of
                'x' ->
                    Just Cross

                'o' ->
                    Just Dot

                '*' ->
                    Just Star

                _ ->
                    Nothing
    in
    case ( symbol_, square_ ) of
        ( Just symbol, Just square ) ->
            Just (Mark symbol square)

        _ ->
            Nothing


fromList : List String -> List Mark
fromList strings =
    List.filterMap fromString strings
