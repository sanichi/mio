module Event exposing
    ( Events
    , Event
    , combine
    )

import Date


type alias Event =
    { name : String
    , code : String
    , rata : Int
    , span : Int
    }


type alias Events =
    List Event


combine : List String -> List String -> List String -> List Int -> Events
combine names codes dates spans =
    combine_ [] names codes dates spans


-- Utilities


combine_ : Events -> List String -> List String -> List String -> List Int -> Events
combine_ events names codes dates spans =
    case ( names, codes, spans ) of -- maximum of 3 in a tuple so we have to split 1 of the 4 off
        ( name :: ns, code :: cs, span :: ss ) ->
            case dates of
                dstr :: ds -> -- since dates need special handling anyway, this is the one we choose to split off
                    case Date.fromIsoString dstr of
                        Ok date ->
                            let
                                rata =
                                    Date.toRataDie date

                                event =
                                    Event name code rata span
                            in
                                combine_ (event :: events) ns cs ds ss

                        _ ->
                            combine_ events ns cs ds ss

                _ ->
                    List.reverse events

        _ ->
            List.reverse events
