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


type alias People =
    List Person


type alias Person =
    Dict Char Bool


count : Int -> People -> Int
count part people =
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
            mergePeople mergePerson people start
    in
    Dict.size merged


mergePeople : (Person -> Person -> Person) -> People -> Person -> Person
mergePeople mergePerson people soFar =
    case people of
        person :: rest ->
            soFar
                |> mergePerson person
                |> mergePeople mergePerson rest

        _ ->
            soFar


parse : String -> List People
parse input =
    input
        |> Regex.split (Util.regex "\\n\\n")
        |> List.map parsePeople


parsePeople : String -> People
parsePeople input =
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
