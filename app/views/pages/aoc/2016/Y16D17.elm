module Y16D17 exposing (answer)

import Char exposing (KeyCode)
import MD5
import Regex


answer : Int -> String -> String
answer part input =
    input
        |> parse
        |> search part 0 [ start ]


search : Int -> Int -> List Location -> String -> String
search part len queue passcode =
    case queue of
        [] ->
            if part == 1 then
                "none"
            else
                toString len

        location :: rest ->
            let
                locations =
                    newLocations passcode location

                maybeGoal =
                    locations
                        |> List.filter found
                        |> List.head
            in
                case maybeGoal of
                    Nothing ->
                        search part len (rest ++ locations) passcode

                    Just goal ->
                        if part == 1 then
                            goal.path
                        else
                            let
                                newLen =
                                    String.length goal.path

                                notGoals =
                                    List.filter (not << found) locations
                            in
                                search part newLen (rest ++ notGoals) passcode


newLocations : String -> Location -> List Location
newLocations passcode location =
    passcode
        ++ location.path
        |> MD5.hex
        |> String.left 4
        |> String.toList
        |> List.map Char.toCode
        |> List.indexedMap (\i c -> ( i, c ))
        |> List.filterMap (newLocation location)


newLocation : Location -> ( Int, KeyCode ) -> Maybe Location
newLocation location ( index, code ) =
    if code < bCode || code > fCode then
        Nothing
    else
        let
            ( x, y, step ) =
                case index of
                    0 ->
                        ( location.x, location.y - 1, "U" )

                    1 ->
                        ( location.x, location.y + 1, "D" )

                    2 ->
                        ( location.x - 1, location.y, "L" )

                    _ ->
                        ( location.x + 1, location.y, "R" )
        in
            if x < 0 || y < 0 || x > 3 || y > 3 then
                Nothing
            else
                location.path
                    ++ step
                    |> Location x y
                    |> Just


found : Location -> Bool
found location =
    location.x == 3 && location.y == 3


type alias Location =
    { x : Int
    , y : Int
    , path : String
    }


start : Location
start =
    Location 0 0 ""


bCode : KeyCode
bCode =
    Char.toCode 'b'


fCode : KeyCode
fCode =
    Char.toCode 'f'


parse : String -> String
parse input =
    input
        |> Regex.find (Regex.AtMost 1) (Regex.regex "\\S+")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault ""
