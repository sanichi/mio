module Y16D04 exposing (answers)

import Char
import Dict exposing (Dict)
import Regex
import Util


answers : String -> String
answers input =
    let
        rooms =
            parse input

        a1 =
            List.filter realRoom rooms |> List.map .sector |> List.sum |> toString

        a2 =
            List.filter northPole rooms |> List.map .sector |> List.sum |> toString
    in
        Util.join a1 a2


type alias Room =
    { name : String
    , sector : Int
    , checksum : String
    }


checksum : Room -> String
checksum room =
    let
        dict =
            stats room.name Dict.empty

        list =
            Dict.toList dict
                |> List.sortWith statCompare
                |> List.take 5
    in
        List.map Tuple.first list
            |> List.map String.fromChar
            |> String.join ""


realRoom : Room -> Bool
realRoom room =
    room.checksum == checksum room


stats : String -> Dict Char Int -> Dict Char Int
stats name dict =
    case String.uncons name of
        Just ( char, rest ) ->
            let
                newDict =
                    if char == '-' then
                        dict
                    else
                        Dict.update char insert dict
            in
                stats rest newDict

        Nothing ->
            dict


statCompare : ( Char, Int ) -> ( Char, Int ) -> Order
statCompare ( char1, int1 ) ( char2, int2 ) =
    if int1 == int2 then
        compare char1 char2
    else
        compare int2 int1


insert : Maybe Int -> Maybe Int
insert count =
    case count of
        Just c ->
            Just (c + 1)

        Nothing ->
            Just 1


decrypt : Int -> String -> String -> String
decrypt shift accum string =
    case String.uncons string of
        Just ( char, rest ) ->
            let
                newChar =
                    if char == '-' then
                        ' '
                    else
                        97 + ((Char.toCode char + shift - 97) % 26) |> Char.fromCode

                newAccum =
                    String.cons newChar accum
            in
                decrypt shift newAccum rest

        Nothing ->
            String.reverse accum


northPole : Room -> Bool
northPole room =
    let
        name =
            decrypt room.sector "" room.name
    in
        Regex.contains (Regex.regex "northpole object") name


parse : String -> List Room
parse input =
    Regex.find (Regex.All) (Regex.regex "([-a-z]+)-([1-9]\\d*)\\[([a-z]{5})\\]") input
        |> List.map .submatches
        |> List.map convertToMaybeRoom
        |> List.filterMap potentialRoom


convertToMaybeRoom : List (Maybe String) -> Maybe Room
convertToMaybeRoom matches =
    case matches of
        [ Just name, Just sector, Just checksum ] ->
            Room name (String.toInt sector |> Result.withDefault 0) checksum |> Just

        _ ->
            Nothing


potentialRoom : Maybe Room -> Maybe Room
potentialRoom room =
    case room of
        Just r ->
            if r.sector > 0 then
                Just r
            else
                Nothing

        Nothing ->
            Nothing
