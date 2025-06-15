module Event exposing
    ( Events
    , Event
    , combine
    )

import Date


type alias Event =
    { name : String
    , rata : Int
    , span : Int
    }


type alias Events =
    List Event


combine : List String -> List String -> List Int -> Events
combine names dates spans =
    combine_ [] names dates spans


-- Utilities


combine_ : Events -> List String -> List String -> List Int -> Events
combine_ events names dates spans =
    case ( names, dates, spans ) of
        ( name :: ns, dstr :: ds, span :: ss ) ->
            case Date.fromIsoString dstr of
                Ok date ->
                    let
                        rata =
                            Date.toRataDie date

                        event =
                            Event name rata span
                    in
                    combine_ (event :: events) ns ds ss

                _ ->
                    combine_ events ns ds ss

        _ ->
            List.reverse events
