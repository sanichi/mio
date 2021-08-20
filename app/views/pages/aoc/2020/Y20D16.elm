module Y20D16 exposing (answer)

import Dict exposing (Dict)
import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        data =
            parse input
    in
    if part == 1 then
        data
            |> sumInvalid
            |> String.fromInt

    else
        data
            |> multiplySelected "departure"
            |> String.fromInt


type alias Rule =
    { name : String
    , r1 : ( Int, Int )
    , r2 : ( Int, Int )
    }


type alias Ticket =
    List Int


type alias Tickets =
    List Ticket


type alias Data =
    { rules : List Rule
    , mine : Ticket
    , near : Tickets
    }


type alias IndexToName =
    Dict Int String


type alias Possibles =
    Dict String Int


type alias IndexToPossibles =
    Dict Int Possibles


sumInvalid : Data -> Int
sumInvalid data =
    data.near
        |> List.map (findInvalid data.rules)
        |> List.concat
        |> List.sum


findInvalid : List Rule -> Ticket -> List Int
findInvalid rules ticket =
    List.filterMap (noValidRules rules) ticket


noValidRules : List Rule -> Int -> Maybe Int
noValidRules rules num =
    case rules of
        rule :: rest ->
            if valid rule num then
                Nothing

            else
                noValidRules rest num

        _ ->
            Just num


valid : Rule -> Int -> Bool
valid rule num =
    ok num rule.r1 || ok num rule.r2


ok : Int -> ( Int, Int ) -> Bool
ok num ( min, max ) =
    num <= max && num >= min


multiplySelected : String -> Data -> Int
multiplySelected start data =
    let
        indexToName =
            getIndexToName data
    in
    data.mine
        |> List.indexedMap
            (\index num ->
                case Dict.get index indexToName of
                    Just name ->
                        if String.startsWith start name then
                            num

                        else
                            1

                    Nothing ->
                        1
            )
        |> List.product


getIndexToName : Data -> IndexToName
getIndexToName data =
    let
        validTickets =
            List.filter (\ticket -> findInvalid data.rules ticket == []) data.near

        possibles =
            getPossibles validTickets data.rules Dict.empty

        len =
            List.length validTickets
    in
    possiblesToNames len possibles Dict.empty


getPossibles : Tickets -> List Rule -> IndexToPossibles -> IndexToPossibles
getPossibles tickets rules possibles =
    case tickets of
        ticket :: rest ->
            let
                indexNums =
                    List.indexedMap (\index num -> ( index, num )) ticket

                possibles_ =
                    possiblesFromIndexNums indexNums rules possibles
            in
            getPossibles rest rules possibles_

        _ ->
            possibles


possiblesToNames : Int -> IndexToPossibles -> IndexToName -> IndexToName
possiblesToNames len possible positions =
    let
        certain =
            possible
                |> Dict.map
                    (\_ dict ->
                        dict
                            |> Dict.toList
                            |> List.filter (\( _, count ) -> count == len)
                            |> List.map Tuple.first
                    )
                |> Dict.map
                    (\_ candidates ->
                        if List.length candidates == 1 then
                            List.head candidates

                        else
                            Nothing
                    )
                |> Dict.toList
                |> List.filterMap (\( id, name ) -> Maybe.map (\n -> ( id, n )) name)
                |> Dict.fromList

        reduced =
            possible
                |> pruneInexes (Dict.keys certain)
                |> Dict.map
                    (\_ dict ->
                        pruneNames (Dict.values certain) dict
                    )
    in
    if Dict.size certain > 0 then
        positions
            |> Dict.union certain
            |> possiblesToNames len reduced

    else
        positions


possiblesFromIndexNums : List ( Int, Int ) -> List Rule -> IndexToPossibles -> IndexToPossibles
possiblesFromIndexNums indexNums rules possibles =
    case indexNums of
        ( index, num ) :: rest ->
            let
                names =
                    rules
                        |> List.filter (\rule -> valid rule num)
                        |> List.map .name

                possibles_ =
                    possiblesFromIndexNames names index possibles
            in
            possiblesFromIndexNums rest rules possibles_

        _ ->
            possibles


possiblesFromIndexNames : List String -> Int -> IndexToPossibles -> IndexToPossibles
possiblesFromIndexNames names index possibles =
    case names of
        name :: rest ->
            let
                counts =
                    Dict.get index possibles |> Maybe.withDefault Dict.empty

                current =
                    Dict.get name counts |> Maybe.withDefault 0

                update =
                    Dict.insert name (current + 1) counts

                possibles_ =
                    Dict.insert index update possibles
            in
            possiblesFromIndexNames rest index possibles_

        _ ->
            possibles


pruneInexes : List Int -> IndexToPossibles -> IndexToPossibles
pruneInexes indexes dict =
    case indexes of
        index :: rest ->
            dict
                |> Dict.remove index
                |> pruneInexes rest

        _ ->
            dict


pruneNames : List String -> Possibles -> Possibles
pruneNames names dict =
    case names of
        name :: rest ->
            dict
                |> Dict.remove name
                |> pruneNames rest

        _ ->
            dict


parse : String -> Data
parse input =
    input
        |> Regex.split (Util.regex "\\n")
        |> parse_ 0 (Data [] [] [])


parse_ : Int -> Data -> List String -> Data
parse_ state data lines =
    case lines of
        line :: rest ->
            case state of
                0 ->
                    if String.contains "your ticket" line then
                        parse_ 1 data rest

                    else
                        let
                            matches =
                                line
                                    |> Regex.find (Util.regex "([a-z].*): (\\d+)-(\\d+) or (\\d+)-(\\d+)")
                                    |> List.map .submatches
                        in
                        case matches of
                            [ [ Just name, Just r11, Just r12, Just r21, Just r22 ] ] ->
                                let
                                    rule =
                                        Rule name ( toInt r11, toInt r12 ) ( toInt r21, toInt r22 )

                                    data_ =
                                        { data | rules = rule :: data.rules }
                                in
                                parse_ state data_ rest

                            _ ->
                                parse_ state data rest

                1 ->
                    if String.contains "nearby tickets" line then
                        parse_ 2 data rest

                    else
                        let
                            mine =
                                toInts line

                            data_ =
                                if List.length mine > 0 then
                                    { data | mine = mine }

                                else
                                    data
                        in
                        parse_ state data_ rest

                2 ->
                    let
                        near =
                            toInts line

                        data_ =
                            if List.length near > 0 then
                                { data | near = near :: data.near }

                            else
                                data
                    in
                    parse_ state data_ rest

                _ ->
                    parse_ state data rest

        _ ->
            data


toInt : String -> Int
toInt str =
    str
        |> String.toInt
        |> Maybe.withDefault 0


toInts : String -> List Int
toInts str =
    str
        |> Regex.find (Util.regex "\\d+")
        |> List.map .match
        |> List.map toInt



-- example1 : String
-- example1 =
--     """
--         class: 1-3 or 5-7
--         row: 6-11 or 33-44
--         seat: 13-40 or 45-50
--         your ticket:
--         7,1,14
--         nearby tickets:
--         7,3,47
--         40,4,50
--         55,2,20
--         38,6,12
--     """
-- example2 : String
-- example2 =
--     """
--         class: 0-1 or 4-19
--         row: 0-5 or 8-19
--         seat: 0-13 or 16-19
--         your ticket:
--         11,12,13
--         nearby tickets:
--         3,9,18
--         15,1,5
--         5,14,9
--     """
