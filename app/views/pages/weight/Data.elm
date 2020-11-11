module Data exposing (Data, combine)


type alias Datum =
    { kilo : Float
    , date : String
    }


type alias Data =
    List Datum


combine : List Float -> List String -> Data
combine kilos dates =
    combine_ [] kilos dates


combine_ : Data -> List Float -> List String -> Data
combine_ data kilos dates =
    case ( kilos, dates ) of
        ( kilo :: ks, date :: ds ) ->
            combine_ (Datum kilo date :: data) ks ds

        _ ->
            data
