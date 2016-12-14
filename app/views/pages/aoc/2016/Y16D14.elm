module Y16D14 exposing (answer)

import Dict exposing (Dict)
import MD5
import Regex


answer : Int -> String -> String
answer part input =
    let
        salt =
            parse input
    in
        search part salt 0 0 Dict.empty


search : Int -> String -> Int -> Int -> Cache -> String
search part salt keys index cache =
    if keys >= 64 then
        toString (index - 1)
    else
        let
            hash =
                getHash part salt index cache

            maybeMatch3 =
                hash
                    |> Regex.find (Regex.AtMost 1) (Regex.regex "(.)\\1\\1")
                    |> List.map .match
                    |> List.head

            newIndex =
                index + 1
        in
            case maybeMatch3 of
                Nothing ->
                    search part salt keys newIndex cache

                Just match3 ->
                    let
                        match5 =
                            match3
                                |> String.repeat 2
                                |> String.left 5

                        newCache =
                            buildCache part salt (index + 1000) newIndex cache Dict.empty

                        matches =
                            newCache
                                |> Dict.values
                                |> List.any (String.contains match5)

                        newKeys =
                            if matches then
                                keys + 1
                            else
                                keys
                    in
                        search part salt newKeys newIndex newCache


type alias Cache =
    Dict Int String


buildCache : Int -> String -> Int -> Int -> Cache -> Cache -> Cache
buildCache part salt upto index oldCache cache =
    if index > upto then
        cache
    else
        let
            hash =
                getHash part salt index oldCache

            newCache =
                Dict.insert index hash cache

            newIndex =
                index + 1
        in
            buildCache part salt upto newIndex oldCache newCache


getHash : Int -> String -> Int -> Cache -> String
getHash part salt index cache =
    let
        maybeHash =
            Dict.get index cache

        hash =
            case maybeHash of
                Just hash ->
                    hash

                Nothing ->
                    MD5.hex (salt ++ (toString index))

        iterations =
            if part == 1 then
                0
            else
                2016
    in
        repeatHash iterations hash


repeatHash : Int -> String -> String
repeatHash iterations hash =
    if iterations <= 0 then
        hash
    else
        hash
            |> MD5.hex
            |> repeatHash (iterations - 1)


parse : String -> String
parse input =
    input
        |> Regex.find (Regex.AtMost 1) (Regex.regex "[a-z]+")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault ""
