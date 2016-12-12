module Y16D05 exposing (answer)

import Array exposing (Array)
import MD5
import Regex


answer : Int -> String -> String
answer part input =
    let
        doorId =
            parse input
    in
        if part == 1 then
            password1 doorId 0 ""
        else
            password2 doorId 0 (Array.repeat 8 Nothing)


password1 : String -> Int -> String -> String
password1 doorId index accum =
    if String.length accum >= 8 then
        String.reverse accum
    else
        let
            digest =
                MD5.hex (doorId ++ (toString index))

            newAccum =
                if String.startsWith zeros digest then
                    case String.uncons <| String.dropLeft zLen digest of
                        Just ( c, _ ) ->
                            String.cons c accum

                        Nothing ->
                            String.cons '-' accum
                else
                    accum

            newIndex =
                index + 1
        in
            password1 doorId newIndex newAccum


password2 : String -> Int -> Array (Maybe String) -> String
password2 doorId index accum =
    if not <| List.member Nothing <| Array.toList accum then
        accum
            |> Array.toList
            |> List.map (Maybe.withDefault "-")
            |> String.join ""
    else
        let
            digest =
                MD5.hex (doorId ++ (toString index))

            newAccum =
                if String.startsWith zeros digest then
                    let
                        rest =
                            String.dropLeft zLen digest

                        char =
                            case String.uncons rest of
                                Just ( c, _ ) ->
                                    c

                                Nothing ->
                                    '-'

                        index =
                            char
                                |> String.fromChar
                                |> String.toInt
                                |> Result.withDefault -1
                    in
                        if index >= 0 && index < 8 then
                            case Array.get index accum of
                                Just Nothing ->
                                    let
                                        item =
                                            case String.uncons <| String.dropLeft 1 rest of
                                                Just ( c, _ ) ->
                                                    Just <| String.fromChar c

                                                Nothing ->
                                                    Just "-"
                                    in
                                        Array.set index item accum

                                _ ->
                                    accum
                        else
                            accum
                else
                    accum

            newIndex =
                index + 1
        in
            password2 doorId newIndex newAccum


zeros : String
zeros =
    "00000"


zLen : Int
zLen =
    String.length zeros


parse : String -> String
parse input =
    input
        |> Regex.find (Regex.AtMost 1) (Regex.regex "[a-z]+")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault "error"
