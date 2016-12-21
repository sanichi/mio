module Y16D21 exposing (answer)

import Array exposing (Array)
import Regex exposing (Regex)


answer : Int -> String -> String
answer part input =
    let
        instructions =
            parse input
    in
        if part == 1 then
            scramble instructions "abcdefgh"
        else
            unscramble instructions "fbgdceah"


scramble : List Instruction -> String -> String
scramble instructions password =
    let
        chars =
            password
                |> String.toList
                |> Array.fromList

        scrambledChars =
            process instructions chars
    in
        scrambledChars
            |> Array.toList
            |> String.fromList


unscramble : List Instruction -> String -> String
unscramble instructions scrambled =
    let
        newInstructions =
            instructions
                |> List.reverse
                |> List.map reverse

        scrambledChars =
            scrambled
                |> String.toList
                |> Array.fromList

        chars =
            process newInstructions scrambledChars
    in
        chars
            |> Array.toList
            |> String.fromList


process : List Instruction -> Chars -> Chars
process instructions chars =
    case instructions of
        [] ->
            chars

        instruction :: rest ->
            let
                newChars =
                    transform instruction chars
            in
                process rest newChars


transform : Instruction -> Chars -> Chars
transform instruction chars =
    case instruction of
        NoOp ->
            chars

        SwapPosition i1 i2 ->
            swapPosition i1 i2 chars

        SwapLetter c1 c2 ->
            swapLetter c1 c2 chars

        RotateLeft n ->
            rotateLeft n chars

        RotateRight n ->
            rotateRight n chars

        RotateBased c ->
            rotateBased c chars

        RotateBasedInverse c ->
            rotateBasedInverse c chars

        ReversePosition i1 i2 ->
            reversePosition i1 i2 chars

        MovePosition i1 i2 ->
            movePosition i1 i2 chars


reverse : Instruction -> Instruction
reverse instruction =
    case instruction of
        NoOp ->
            NoOp

        SwapPosition i1 i2 ->
            SwapPosition i2 i1

        SwapLetter c1 c2 ->
            SwapLetter c2 c1

        RotateLeft n ->
            RotateRight n

        RotateRight n ->
            RotateLeft n

        RotateBased c ->
            RotateBasedInverse c

        RotateBasedInverse c ->
            NoOp

        ReversePosition i1 i2 ->
            ReversePosition i1 i2

        MovePosition i1 i2 ->
            MovePosition i2 i1


swapPosition : Int -> Int -> Chars -> Chars
swapPosition i1 i2 chars =
    let
        mc1 =
            Array.get i1 chars

        mc2 =
            Array.get i2 chars
    in
        case ( mc1, mc2 ) of
            ( Just c1, Just c2 ) ->
                chars
                    |> Array.set i1 c2
                    |> Array.set i2 c1

            _ ->
                chars


swapLetter : Char -> Char -> Chars -> Chars
swapLetter c1 c2 chars =
    let
        mi1 =
            indexOf c1 chars

        mi2 =
            indexOf c2 chars
    in
        case ( mi1, mi2 ) of
            ( Just i1, Just i2 ) ->
                swapPosition i1 i2 chars

            _ ->
                chars


rotateLeft : Int -> Chars -> Chars
rotateLeft n chars =
    if n == 0 then
        chars
    else
        let
            len =
                Array.length chars

            n_ =
                n % len

            a1 =
                Array.slice 0 n_ chars

            a2 =
                Array.slice n_ len chars
        in
            Array.append a2 a1


rotateRight : Int -> Chars -> Chars
rotateRight n chars =
    if n == 0 then
        chars
    else
        let
            len =
                Array.length chars

            n_ =
                n % len
        in
            rotateLeft (len - n_) chars


rotateBased : Char -> Chars -> Chars
rotateBased c chars =
    let
        mi =
            indexOf c chars
    in
        case mi of
            Just i ->
                let
                    x =
                        if i >= 4 then
                            1
                        else
                            0

                    n =
                        1 + i + x
                in
                    rotateRight n chars

            Nothing ->
                chars


rotateBasedInverse : Char -> Chars -> Chars
rotateBasedInverse c chars =
    let
        mi =
            indexOf c chars

        n =
            case mi of
                Just 0 ->
                    1

                Just 1 ->
                    1

                Just 2 ->
                    6

                Just 3 ->
                    2

                Just 4 ->
                    7

                Just 5 ->
                    3

                Just 6 ->
                    0

                Just 7 ->
                    4

                _ ->
                    0
    in
        rotateLeft n chars


reversePosition : Int -> Int -> Chars -> Chars
reversePosition i1 i2 chars =
    let
        len =
            Array.length chars
    in
        if i1 < len && i2 < len then
            let
                a1 =
                    Array.slice 0 i1 chars

                a2 =
                    chars
                        |> Array.slice i1 (i2 + 1)
                        |> Array.toList
                        |> List.reverse
                        |> Array.fromList

                a3 =
                    Array.slice (i2 + 1) len chars
            in
                a3
                    |> Array.append a2
                    |> Array.append a1
        else
            chars


movePosition : Int -> Int -> Chars -> Chars
movePosition i1 i2 chars =
    let
        len =
            Array.length chars
    in
        if i1 < len && i2 < len then
            let
                a1 =
                    Array.slice 0 i1 chars

                a2 =
                    Array.slice i1 (i1 + 1) chars

                a3 =
                    Array.slice (i1 + 1) len chars

                a4 =
                    Array.append a1 a3

                a5 =
                    Array.slice 0 i2 a4

                a6 =
                    Array.slice i2 (len - 1) a4
            in
                a6
                    |> Array.append a2
                    |> Array.append a5
        else
            chars


type Instruction
    = NoOp
    | SwapPosition Int Int
    | SwapLetter Char Char
    | RotateLeft Int
    | RotateRight Int
    | RotateBased Char
    | RotateBasedInverse Char
    | ReversePosition Int Int
    | MovePosition Int Int


type alias Chars =
    Array Char


parse : String -> List Instruction
parse input =
    input
        |> Regex.find Regex.All instructionPattern
        |> List.map .submatches
        |> List.map (List.map (Maybe.withDefault ""))
        |> List.map (List.filter (not << String.isEmpty))
        |> List.map toInstruction


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


toInstruction : List String -> Instruction
toInstruction words =
    case words of
        [ "swap position", a, b ] ->
            let
                i1 =
                    toInt a

                i2 =
                    toInt b
            in
                if i1 /= i2 then
                    SwapPosition i1 i2
                else
                    NoOp

        [ "swap letter", a, b ] ->
            let
                c1 =
                    toChar a

                c2 =
                    toChar b
            in
                if c1 /= c2 then
                    SwapLetter c1 c2
                else
                    NoOp

        [ "rotate left", a ] ->
            let
                n =
                    toInt a
            in
                if n > 0 then
                    RotateLeft n
                else
                    NoOp

        [ "rotate right", a ] ->
            let
                n =
                    toInt a
            in
                if n > 0 then
                    RotateRight n
                else
                    NoOp

        [ "rotate based", a ] ->
            let
                c =
                    toChar a
            in
                RotateBased c

        [ "reverse positions", a, b ] ->
            let
                i1 =
                    toInt a

                i2 =
                    toInt b
            in
                if i1 < i2 then
                    ReversePosition i1 i2
                else
                    NoOp

        [ "move position", a, b ] ->
            let
                i1 =
                    toInt a

                i2 =
                    toInt b
            in
                if i1 /= i2 then
                    MovePosition i1 i2
                else
                    NoOp

        _ ->
            NoOp


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


indexOf : Char -> Chars -> Maybe Int
indexOf char chars =
    chars
        |> Array.toIndexedList
        |> List.filter (\t -> Tuple.second t == char)
        |> List.map Tuple.first
        |> List.head
