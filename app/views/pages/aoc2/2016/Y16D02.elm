module Y16D02 exposing (answer)

import Regex


answer : Int -> String -> String
answer part input =
    let
        instructions =
            parse input
    in
        if part == 1 then
            instructions
                |> translate init [] move1
                |> String.fromList
        else
            instructions
                |> translate init [] move2
                |> String.fromList


translate : Char -> List Char -> (Char -> Char -> Char) -> List String -> List Char
translate current buttons mover instructions =
    case instructions of
        instruction :: remainingInstructions ->
            let
                button =
                    follow current mover instruction

                newButtons =
                    button :: buttons
            in
                translate button newButtons mover remainingInstructions

        _ ->
            List.reverse buttons


follow : Char -> (Char -> Char -> Char) -> String -> Char
follow current mover instruction =
    case String.uncons instruction of
        Just ( letter, rest ) ->
            let
                button =
                    mover current letter
            in
                follow button mover rest

        Nothing ->
            current


move1 : Char -> Char -> Char
move1 current letter =
    case current of
        '1' ->
            case letter of
                'R' ->
                    '2'

                'D' ->
                    '4'

                _ ->
                    current

        '2' ->
            case letter of
                'R' ->
                    '3'

                'L' ->
                    '1'

                'D' ->
                    '5'

                _ ->
                    current

        '3' ->
            case letter of
                'L' ->
                    '2'

                'D' ->
                    '6'

                _ ->
                    current

        '4' ->
            case letter of
                'R' ->
                    '5'

                'U' ->
                    '1'

                'D' ->
                    '7'

                _ ->
                    current

        '5' ->
            case letter of
                'R' ->
                    '6'

                'L' ->
                    '4'

                'U' ->
                    '2'

                'D' ->
                    '8'

                _ ->
                    current

        '6' ->
            case letter of
                'L' ->
                    '5'

                'U' ->
                    '3'

                'D' ->
                    '9'

                _ ->
                    current

        '7' ->
            case letter of
                'R' ->
                    '8'

                'U' ->
                    '4'

                _ ->
                    current

        '8' ->
            case letter of
                'R' ->
                    '9'

                'L' ->
                    '7'

                'U' ->
                    '5'

                _ ->
                    current

        '9' ->
            case letter of
                'L' ->
                    '8'

                'U' ->
                    '6'

                _ ->
                    current

        _ ->
            current


move2 : Char -> Char -> Char
move2 current letter =
    case current of
        '1' ->
            case letter of
                'D' ->
                    '3'

                _ ->
                    current

        '2' ->
            case letter of
                'R' ->
                    '3'

                'D' ->
                    '6'

                _ ->
                    current

        '3' ->
            case letter of
                'R' ->
                    '4'

                'L' ->
                    '2'

                'U' ->
                    '1'

                'D' ->
                    '7'

                _ ->
                    current

        '4' ->
            case letter of
                'L' ->
                    '3'

                'D' ->
                    '8'

                _ ->
                    current

        '5' ->
            case letter of
                'R' ->
                    '6'

                _ ->
                    current

        '6' ->
            case letter of
                'R' ->
                    '7'

                'L' ->
                    '5'

                'U' ->
                    '2'

                'D' ->
                    'A'

                _ ->
                    current

        '7' ->
            case letter of
                'R' ->
                    '8'

                'L' ->
                    '6'

                'U' ->
                    '3'

                'D' ->
                    'B'

                _ ->
                    current

        '8' ->
            case letter of
                'R' ->
                    '9'

                'L' ->
                    '7'

                'U' ->
                    '4'

                'D' ->
                    'C'

                _ ->
                    current

        '9' ->
            case letter of
                'L' ->
                    '8'

                _ ->
                    current

        'A' ->
            case letter of
                'R' ->
                    'B'

                'U' ->
                    '6'

                _ ->
                    current

        'B' ->
            case letter of
                'R' ->
                    'C'

                'L' ->
                    'A'

                'U' ->
                    '7'

                'D' ->
                    'D'

                _ ->
                    current

        'C' ->
            case letter of
                'L' ->
                    'B'

                'U' ->
                    '8'

                _ ->
                    current

        'D' ->
            case letter of
                'U' ->
                    'B'

                _ ->
                    current

        _ ->
            current


init : Char
init =
    '5'


parse : String -> List String
parse input =
    Regex.find Regex.All (Regex.regex "([RLUD]+)") input
        |> List.map .match
