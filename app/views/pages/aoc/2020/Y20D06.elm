module Y20D06 exposing (answer)

import Dict exposing (Dict)
import Regex
import Util


answer : Int -> String -> String
answer part input =
    input
        |> parse
        |> List.map (count part)
        |> List.sum
        |> String.fromInt


type alias Group =
    List Person


type alias Person =
    Dict Char Bool


count : Int -> Group -> Int
count part group =
    let
        start =
            if part == 1 then
                Dict.empty

            else
                "abcdefghijklmnopqrstuvwxyz"
                    |> String.toList
                    |> List.map (\c -> ( c, True ))
                    |> Dict.fromList

        mergePerson =
            if part == 1 then
                Dict.union

            else
                Dict.intersect

        merged =
            mergeGroup mergePerson group start
    in
    Dict.size merged


mergeGroup : (Person -> Person -> Person) -> Group -> Person -> Person
mergeGroup mergePerson group dict =
    case group of
        person :: rest ->
            dict
                |> mergePerson person
                |> mergeGroup mergePerson rest

        _ ->
            dict


parse : String -> List Group
parse input =
    input
        |> Regex.split (Util.regex "\\n\\n")
        |> List.map parseGroup


parseGroup : String -> Group
parseGroup input =
    input
        |> Regex.find (Util.regex "[a-z]+")
        |> List.map .match
        |> List.map parsePerson


parsePerson : String -> Person
parsePerson input =
    input
        |> String.toList
        |> List.map (\c -> ( c, True ))
        |> Dict.fromList


example : String
example =
    """
        abc

        a
        b
        c

        ab
        ac

        a
        a
        a
        a

        b
    """
