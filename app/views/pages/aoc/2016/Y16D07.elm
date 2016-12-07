module Y16D07 exposing (answers)

import Regex
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
        exteriors =
            address
                |> fragments "(?:^|\\])([a-z]+)(?:\\[|$)"
                |> List.any abba

        interiors =
            address
                |> fragments "\\[([a-z]+)\\]"
                |> List.any abba
    in
        exteriors && not interiors


ssl : String -> Bool
ssl address =
    let
        abas =
            address
                |> fragments "(?:^|\\])([a-z]+)(?:\\[|$)"
                |> List.map aba
                |> List.concat
    in
        if List.isEmpty abas then
            False
        else
            let
                babs =
                    List.map abababa abas

                interiors =
                    fragments "\\[([a-z]+)\\]" address

                hasBab fragment =
                    List.any (\b -> String.contains b fragment) babs
            in
                List.any hasBab interiors


abba : String -> Bool
abba fragment =
    let
        abbas =
            fragment
                |> Regex.find Regex.All (Regex.regex "(.)(.)\\2\\1")
                |> List.map .match
                |> List.filter (\s -> not (Regex.contains (Regex.regex "^(.)\\1\\1\\1$") s))
    in
        List.length abbas > 0


aba : String -> List String
aba fragment =
    fragment
        |> Regex.find Regex.All (Regex.regex "(.).(?=\\1)")
        |> List.map .match
        |> List.filter (\s -> not (Regex.contains (Regex.regex "^(.)\\1$") s))


abababa : String -> String
abababa aba =
    let
        ( char1, rest ) =
            case String.uncons aba of
                Just pair ->
                    pair

                Nothing ->
                    ( '-', "-" )

        char2 =
            case String.uncons rest of
                Just ( c, _ ) ->
                    c

                Nothing ->
                    '-'
    in
        [ char2, char1, char2 ]
            |> List.map String.fromChar
            |> String.join ""


fragments : String -> String -> List String
fragments pattern address =
    address
        |> Regex.find Regex.All (Regex.regex pattern)
        |> List.map .submatches
        |> List.map List.head
        |> List.map (Maybe.withDefault Nothing)
        |> List.map (Maybe.withDefault "")


parse : String -> List String
parse input =
    Regex.find Regex.All (Regex.regex "[a-z\\[\\]]+") input |> List.map .match
