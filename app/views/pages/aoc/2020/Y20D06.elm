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
        dict =
            if part == 1 then
                Dict.empty

            else
                "abcdefghijklmnopqrstuvwxyz"
                    |> String.toList
                    |> List.map (\c -> ( c, True ))
                    |> Dict.fromList
    in
    count_ part group dict |> Dict.size


count_ : Int -> Group -> Dict Char Bool -> Dict Char Bool
count_ part group dict =
    case group of
        person :: rest ->
            let
                combine =
                    if part == 1 then
                        Dict.union

                    else
                        Dict.intersect
            in
            count_ part rest (combine person dict)

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
