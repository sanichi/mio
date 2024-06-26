module Y15D24 exposing (answer)

import Regex exposing (find)
import Util exposing (combinations, regex)


answer : Int -> String -> String
answer part input =
    let
        num =
            if part == 1 then
                3

            else
                4
    in
    input
        |> parse
        |> bestQe num
        |> String.fromInt


bestQe : Int -> Weights -> Int
bestQe groups weights =
    let
        weight =
            List.sum weights // groups

        maxLen =
            List.length weights - groups + 1
    in
    searchLength 0 1 maxLen weight weights


searchLength : Int -> Int -> Int -> Int -> Weights -> Int
searchLength qe length maxLen weight weights =
    if length > maxLen then
        qe

    else
        let
            combos =
                combinations length weights

            qe_ =
                searchCombo qe weight combos
        in
        if qe_ > 0 then
            qe_

        else
            searchLength qe (length + 1) maxLen weight weights


searchCombo : Int -> Int -> List Weights -> Int
searchCombo qe weight combos =
    case combos of
        [] ->
            qe

        weights :: rest ->
            let
                qe_ =
                    if List.sum weights /= weight then
                        qe

                    else
                        let
                            qe__ =
                                List.product weights
                        in
                        if qe == 0 || qe__ < qe then
                            qe__

                        else
                            qe
            in
            searchCombo qe_ weight rest


parse : String -> Weights
parse input =
    input
        |> find (regex "\\d+")
        |> List.map .match
        |> List.map String.toInt
        |> List.map (Maybe.withDefault 0)
        |> List.filter (\w -> w /= 0)


type alias Weights =
    List Int
