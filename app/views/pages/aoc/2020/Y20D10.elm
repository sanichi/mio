module Y20D10 exposing (answer)

import Dict exposing (Dict)
import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        numbers =
            parse input
    in
    if part == 1 then
        numbers
            |> onesAndThrees
            |> String.fromInt

    else
        numbers
            |> numberOfArrangements
            |> String.fromInt


onesAndThrees : List Int -> Int
onesAndThrees numbers =
    let
        diffs =
            numbers
                |> extendAndSort
                |> getDiffs

        ones =
            Dict.get 1 diffs |> Maybe.withDefault 0

        threes =
            Dict.get 3 diffs |> Maybe.withDefault 0
    in
    ones * threes


getDiffs : List Int -> Dict Int Int
getDiffs numbers =
    getDiffs_ 0 numbers Dict.empty


getDiffs_ : Int -> List Int -> Dict Int Int -> Dict Int Int
getDiffs_ prev numbers diffs =
    case numbers of
        num :: rest ->
            let
                diff =
                    num - prev

                times =
                    Dict.get diff diffs |> Maybe.withDefault 0

                newDiffs =
                    Dict.insert diff (times + 1) diffs
            in
            getDiffs_ num rest newDiffs

        _ ->
            diffs


numberOfArrangements : List Int -> Int
numberOfArrangements numbers =
    numbers
        |> extendAndSort
        |> runsOfOnes 0 0 []
        |> List.map runArrangements
        |> List.product


runsOfOnes : Int -> Int -> List Int -> List Int -> List Int
runsOfOnes prev run ones numbers =
    case numbers of
        num :: rest ->
            if num - prev == 1 then
                runsOfOnes num (run + 1) ones rest

            else if run > 1 then
                runsOfOnes num 0 ((run - 1) :: ones) rest

            else
                runsOfOnes num 0 ones rest

        _ ->
            if run > 0 then
                run :: ones

            else
                ones


runArrangements : Int -> Int
runArrangements run =
    Nothing
        |> List.repeat run
        |> List.indexedMap (\i _ -> i + 1)
        |> arrangements 0 (run + 1)


arrangements : Int -> Int -> List Int -> Int
arrangements start finish numbers =
    case numbers of
        num :: rest ->
            if num - start > 3 then
                0

            else
                let
                    with =
                        arrangements num finish rest

                    without =
                        if finish - start > 3 + List.length rest then
                            0

                        else
                            arrangements start finish rest
                in
                with + without

        _ ->
            if finish - start > 3 then
                0

            else
                1


extendAndSort : List Int -> List Int
extendAndSort numbers =
    let
        target =
            numbers
                |> List.maximum
                |> Maybe.withDefault 0
                |> (+) 3
    in
    List.sort (target :: numbers)


parse : String -> List Int
parse input =
    input
        |> Regex.find (Util.regex "[1-9]\\d*")
        |> List.map .match
        |> List.filterMap String.toInt


example1 : String
example1 =
    """
        16
        10
        15
        5
        1
        11
        7
        19
        6
        12
        4
    """


example2 : String
example2 =
    """
        28
        33
        18
        42
        31
        14
        46
        20
        48
        47
        24
        23
        49
        45
        19
        38
        39
        11
        1
        32
        25
        35
        8
        17
        7
        9
        4
        2
        34
        10
        3
    """
