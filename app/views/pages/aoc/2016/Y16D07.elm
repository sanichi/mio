module Y16D07 exposing (answers)

import Regex exposing (Regex)
import Util


answers : String -> String
answers input =
    let
        addresses =
            parse input

        a1 =
            addresses
                |> List.filter tls
                |> List.length
                |> toString

        a2 =
            addresses
                |> List.filter ssl
                |> List.length
                |> toString
    in
        Util.join a1 a2


tls : String -> Bool
tls address =
    let
        hasAbba fragment =
            let
                abbas =
                    fragment
                        |> Regex.find Regex.All (Regex.regex "(.)(.)\\2\\1")
                        |> List.map .match
                        |> List.filter (\s -> not (Regex.contains (Regex.regex "^(.)\\1\\1\\1$") s))
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
                |> List.scanl (\a b -> a :: List.take 2 b) []
                |> List.map String.fromList
                |> List.filter (\a -> String.length a == 3)
                |> List.filter (\a -> Regex.contains (Regex.regex "^(.).\\1$") a)
                |> List.filter (\a -> not (Regex.contains (Regex.regex "^(.)\\1\\1$") a))

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
        |> Regex.find Regex.All matcher
        |> List.map .submatches
        |> List.map List.head
        |> List.map (Maybe.withDefault Nothing)
        |> List.map (Maybe.withDefault "")


matchExterior : Regex
matchExterior =
    Regex.regex "(?:^|\\])([a-z]+)(?:\\[|$)"


matchInterior : Regex
matchInterior =
    Regex.regex "\\[([a-z]+)\\]"


parse : String -> List String
parse input =
    Regex.find Regex.All (Regex.regex "[a-z\\[\\]]+") input |> List.map .match
