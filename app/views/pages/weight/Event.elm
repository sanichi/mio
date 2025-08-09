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
    case ( names, codes, spans ) of
        ( name :: ns, code :: cs, span :: ss ) ->
            case dates of
                dstr :: ds ->
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
