module Castle exposing (Castle, any, bk, bq, init, none, wk, wq)


type alias Castle =
    { whiteKing : Bool
    , whiteQueen : Bool
    , blackKing : Bool
    , blackQueen : Bool
    }


any : Castle -> Bool
any castle =
    castle.whiteKing
        || castle.whiteQueen
        || castle.blackKing
        || castle.blackQueen


none : Castle -> Bool
none castle =
    not castle.whiteKing
        && not castle.whiteQueen
        && not castle.blackKing
        && not castle.blackQueen


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
