module Y16D21 exposing (answer)

import Array exposing (Array)
import Regex exposing (Regex)


answer : Int -> String -> String
answer part input =
    let
        test =
            """
            swap position 4 with position 0
            swap letter d with letter b
            reverse positions 0 through 4
            rotate left 1 step
            move position 1 to position 4
            move position 3 to position 0
            rotate based on position of letter b
            rotate based on position of letter d
            """

        instructions =
            parse test

        chars =
            "abcde"
                |> String.toList
                |> Array.fromList
    in
        if part == 1 then
            chars
                |> process instructions
                |> Array.toList
                |> String.fromList
        else
            instructions
                |> List.map getTransformer
                |> toString


process : List Instruction -> Chars -> Chars
process instructions chars =
    case instructions of
        [] ->
            chars

        instruction :: rest ->
            chars
                |> transform instruction
                |> process rest


transform : Instruction -> Chars -> Chars
transform instruction chars =
    chars |> getTransformer instruction


swapPosition : Int -> Int -> Chars -> Chars
swapPosition i1 i2 chars =
    identity chars


swapLetter : Char -> Char -> Chars -> Chars
swapLetter c1 c2 chars =
    identity chars


rotateLeft : Int -> Chars -> Chars
rotateLeft n chars =
    identity chars


rotateRight : Int -> Chars -> Chars
rotateRight n chars =
    identity chars


rotateBased : Char -> Chars -> Chars
rotateBased c chars =
    identity chars


reversePosition : Int -> Int -> Chars -> Chars
reversePosition i1 i2 chars =
    identity chars


movePosition : Int -> Int -> Chars -> Chars
movePosition i1 i2 chars =
    identity chars


type alias Instruction =
    List String


type alias Chars =
    Array Char


parse : String -> List Instruction
parse input =
    input
        |> Regex.find Regex.All instructionPattern
        |> List.map .submatches
        |> List.map (List.map (Maybe.withDefault ""))
        |> List.map (List.filter (not << String.isEmpty))


instructionPattern : Regex
instructionPattern =
    let
        list =
            [ "(swap position) ([0-9]) with position ([0-9])"
            , "(swap letter) ([a-z]) with letter ([a-z])"
            , "(rotate left) ([0-9]) steps?"
            , "(rotate right) ([0-9]) steps?"
            , "(rotate based) on position of letter ([a-z])"
            , "(reverse positions) ([0-9]) through ([1-9])"
            , "(move position) ([0-9]) to position ([0-9])"
            ]
    in
        list
            |> String.join "|"
            |> Regex.regex


getTransformer : Instruction -> (Chars -> Chars)
getTransformer instruction =
    case instruction of
        [ "swap position", a, b ] ->
            let
                i1 =
                    toInt a

                i2 =
                    toInt b
            in
                if i1 /= i2 then
                    swapPosition i1 i2
                else
                    identity

        [ "swap letter", a, b ] ->
            let
                c1 =
                    toChar a

                c2 =
                    toChar b
            in
                if c1 /= c2 then
                    swapLetter c1 c2
                else
                    identity

        [ "rotate left", a ] ->
            let
                n =
                    toInt a
            in
                if n > 0 then
                    rotateLeft n
                else
                    identity

        [ "rotate right", a ] ->
            let
                n =
                    toInt a
            in
                if n > 0 then
                    rotateRight n
                else
                    identity

        [ "rotate based", a ] ->
            let
                c =
                    toChar a
            in
                rotateBased c

        [ "reverse positions", a, b ] ->
            let
                i1 =
                    toInt a

                i2 =
                    toInt b
            in
                if i1 < i2 then
                    reversePosition i1 i2
                else
                    identity

        [ "move position", a, b ] ->
            let
                i1 =
                    toInt a

                i2 =
                    toInt b
            in
                if i1 /= i2 then
                    movePosition i1 i2
                else
                    identity

        _ ->
            identity


toInt : String -> Int
toInt str =
    str
        |> String.toInt
        |> Result.withDefault 0


toChar : String -> Char
toChar str =
    case String.uncons str of
        Just ( c, s ) ->
            c

        Nothing ->
            '_'
