module Y16D07 exposing (answer)

import List.Extra exposing (scanl)
import Regex exposing (Regex, contains, find)
import Util exposing (regex)


answer : Int -> String -> String
answer part input =
    let
        addresses =
            parse input
    in
    if part == 1 then
        addresses
            |> List.filter tls
            |> List.length
            |> String.fromInt

    else
        addresses
            |> List.filter ssl
            |> List.length
            |> String.fromInt


tls : String -> Bool
tls address =
    let
        hasAbba fragment =
            let
                abbas =
                    fragment
                        |> find (regex "(.)(.)\\2\\1")
                        |> List.map .match
                        |> List.filter (\s -> not (contains (regex "^(.)\\1\\1\\1$") s))
            in
            List.length abbas > 0

        exteriors =
            address
                |> fragments matchExterior
                |> List.any hasAbba

        interiors =
            address
                |> fragments matchInterior
                |> List.any hasAbba
    in
    exteriors && not interiors


ssl : String -> Bool
ssl address =
    let
        abaList fragment =
            fragment
                |> String.toList
                |> scanl (\a b -> a :: List.take 2 b) []
                |> List.map String.fromList
                |> List.filter (\a -> String.length a == 3)
                |> List.filter (\a -> contains (regex "^(.).\\1$") a)
                |> List.filter (\a -> not (contains (regex "^(.)\\1\\1$") a))

        abas =
            address
                |> fragments matchExterior
                |> List.map abaList
                |> List.concat
    in
    if List.isEmpty abas then
        False

    else
        let
            abaToBab aba =
                case String.toList aba of
                    [ a, b, _ ] ->
                        String.fromList [ b, a, b ]

                    _ ->
                        "---"

            babs =
                List.map abaToBab abas

            hasBab fragment =
                List.any (\b -> String.contains b fragment) babs
        in
        address
            |> fragments matchInterior
            |> List.any hasBab


fragments : Regex -> String -> List String
fragments matcher address =
    address
        |> find matcher
        |> List.map .submatches
        |> List.map List.head
        |> List.map (Maybe.withDefault Nothing)
        |> List.map (Maybe.withDefault "")


matchExterior : Regex
matchExterior =
    regex "(?:^|\\])([a-z]+)(?:\\[|$)"


matchInterior : Regex
matchInterior =
    regex "\\[([a-z]+)\\]"


parse : String -> List String
parse input =
    find (regex "[a-z\\[\\]]+") input |> List.map .match
