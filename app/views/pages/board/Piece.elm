module Piece exposing (Category(..), Colour(..), Piece)


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
