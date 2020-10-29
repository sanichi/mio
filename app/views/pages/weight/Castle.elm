module Castle exposing (Castle, bk, bq, init, wk, wq)


type alias Castle =
    { whiteKing : Bool
    , whiteQueen : Bool
    , blackKing : Bool
    , blackQueen : Bool
    }


init : Castle
init =
    Castle False False False False


wk : Castle -> Castle
wk castle =
    { castle | whiteKing = True }


wq : Castle -> Castle
wq castle =
    { castle | whiteQueen = True }


bk : Castle -> Castle
bk castle =
    { castle | blackKing = True }


bq : Castle -> Castle
bq castle =
    { castle | blackQueen = True }
