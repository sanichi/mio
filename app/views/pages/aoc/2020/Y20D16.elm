module Y20D16 exposing (answer)

import Dict exposing (Dict)
import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        tickets =
            parse input
    in
    if part == 1 then
        tickets
            |> sum
            |> String.fromInt

    else
        tickets
            |> multiply "departure"
            |> String.fromInt


type alias Rule =
    { name : String
    , r1 : ( Int, Int )
    , r2 : ( Int, Int )
    }


type alias Ticket =
    List Int


type alias Tickets =
    { rules : List Rule
    , mine : Ticket
    , near : List Ticket
    }


type alias PossiblePositions =
    Dict Int (Dict String Int)


type alias Positions =
    Dict Int String


sum : Tickets -> Int
sum tickets =
    tickets.near
        |> List.map (findInvalid tickets.rules)
        |> List.concat
        |> List.sum


multiply : String -> Tickets -> Int
multiply start tickets =
    let
        positions =
            rulePositions tickets
    in
    tickets.mine
        |> List.indexedMap
            (\index num ->
                case Dict.get index positions of
                    Just name ->
                        if String.startsWith start name then
                            num

                        else
                            1

                    Nothing ->
                        1
            )
        |> List.product


rulePositions : Tickets -> Positions
rulePositions tickets =
    let
        list =
            List.filter (\ticket -> findInvalid tickets.rules ticket == []) tickets.near

        possible =
            rulePositionsFromTickets list tickets.rules Dict.empty

        len =
            List.length list
    in
    rulePositionsFromPossible len possible Dict.empty


rulePositionsFromPossible : Int -> PossiblePositions -> Positions -> Positions
rulePositionsFromPossible len possible positions =
    let
        certain =
            possible
                |> Dict.map
                    (\index dict ->
                        dict
                            |> Dict.toList
                            |> List.filter (\( name, count ) -> count == len)
                            |> List.map Tuple.first
                    )
                |> Dict.map
                    (\index candidates ->
                        if List.length candidates == 1 then
                            List.head candidates

                        else
                            Nothing
                    )
                |> Dict.toList
                |> List.filterMap
                    (\( index, maybeName ) ->
                        case maybeName of
                            Just name ->
                                Just ( index, name )

                            Nothing ->
                                Nothing
                    )
                |> Dict.fromList

        reduced =
            possible
                |> removeIndexes (Dict.keys certain)
                |> Dict.map
                    (\index dict ->
                        removeNames (Dict.values certain) dict
                    )
    in
    if Dict.size certain > 0 then
        positions
            |> Dict.union certain
            |> rulePositionsFromPossible len reduced

    else
        positions


rulePositionsFromTickets : List Ticket -> List Rule -> PossiblePositions -> PossiblePositions
rulePositionsFromTickets tickets rules positions =
    case tickets of
        ticket :: rest ->
            let
                indexNums =
                    ticket
                        |> List.indexedMap (\index num -> ( index, num ))

                newPositions =
                    rulePositionsFromIndexNums indexNums rules positions
            in
            rulePositionsFromTickets rest rules newPositions

        _ ->
            positions


rulePositionsFromIndexNums : List ( Int, Int ) -> List Rule -> PossiblePositions -> PossiblePositions
rulePositionsFromIndexNums indexNums rules positions =
    case indexNums of
        ( index, num ) :: rest ->
            let
                names =
                    rules
                        |> List.filter (\rule -> valid rule num)
                        |> List.map .name

                newPositions =
                    rulePositionsFromIndexNames names index positions
            in
            rulePositionsFromIndexNums rest rules newPositions

        _ ->
            positions


rulePositionsFromIndexNames : List String -> Int -> PossiblePositions -> PossiblePositions
rulePositionsFromIndexNames names index positions =
    case names of
        name :: rest ->
            let
                counts =
                    Dict.get index positions |> Maybe.withDefault Dict.empty

                current =
                    Dict.get name counts |> Maybe.withDefault 0

                update =
                    Dict.insert name (current + 1) counts

                newPositions =
                    Dict.insert index update positions
            in
            rulePositionsFromIndexNames rest index newPositions

        _ ->
            positions


findInvalid : List Rule -> Ticket -> List Int
findInvalid rules ticket =
    ticket
        |> List.filterMap (noRulesValid rules)


noRulesValid : List Rule -> Int -> Maybe Int
noRulesValid rules num =
    case rules of
        rule :: rest ->
            if valid rule num then
                Nothing

            else
                noRulesValid rest num

        _ ->
            Just num


valid : Rule -> Int -> Bool
valid rule num =
    ok num rule.r1 || ok num rule.r2


ok : Int -> ( Int, Int ) -> Bool
ok num ( min, max ) =
    num <= max && num >= min


removeNames : List String -> Dict String Int -> Dict String Int
removeNames names dict =
    case names of
        name :: rest ->
            dict
                |> Dict.remove name
                |> removeNames rest

        _ ->
            dict


removeIndexes : List Int -> PossiblePositions -> PossiblePositions
removeIndexes indexes dict =
    case indexes of
        index :: rest ->
            dict
                |> Dict.remove index
                |> removeIndexes rest

        _ ->
            dict


parse : String -> Tickets
parse input =
    input
        |> Regex.split (Util.regex "\\n")
        |> parse_ 0 (Tickets [] [] [])


parse_ : Int -> Tickets -> List String -> Tickets
parse_ state tickets lines =
    case lines of
        line :: rest ->
            case state of
                0 ->
                    if String.contains "your ticket" line then
                        parse_ 1 tickets rest

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

                                    tickets_ =
                                        { tickets | rules = rule :: tickets.rules }
                                in
                                parse_ state tickets_ rest

                            _ ->
                                parse_ state tickets rest

                1 ->
                    if String.contains "nearby tickets" line then
                        parse_ 2 tickets rest

                    else
                        let
                            mine =
                                toInts line

                            tickets_ =
                                if List.length mine > 0 then
                                    { tickets | mine = mine }

                                else
                                    tickets
                        in
                        parse_ state tickets_ rest

                2 ->
                    let
                        near =
                            toInts line

                        tickets_ =
                            if List.length near > 0 then
                                { tickets | near = near :: tickets.near }

                            else
                                tickets
                    in
                    parse_ state tickets_ rest

                _ ->
                    parse_ state tickets rest

        _ ->
            tickets


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


example1 : String
example1 =
    """
        class: 1-3 or 5-7
        row: 6-11 or 33-44
        seat: 13-40 or 45-50

        your ticket:
        7,1,14

        nearby tickets:
        7,3,47
        40,4,50
        55,2,20
        38,6,12
    """


example2 : String
example2 =
    """
        class: 0-1 or 4-19
        row: 0-5 or 8-19
        seat: 0-13 or 16-19

        your ticket:
        11,12,13

        nearby tickets:
        3,9,18
        15,1,5
        5,14,9
    """
