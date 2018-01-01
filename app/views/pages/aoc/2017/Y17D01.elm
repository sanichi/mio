module Y17D01 exposing (answer)

import Array exposing (Array)
import Char


answer : Int -> String -> String
answer part input =
    let
        array =
            parse input
    in
        if part == 1 then
            sum 0 0 1 array |> toString
        else
            let
                delta =
                    (Array.length array) // 2
            in
                sum 0 0 delta array |> toString


sum : Int -> Int -> Int -> Array Char -> Int
sum total index delta array =
    if index >= (Array.length array) then
        total
    else
        let
            len =
                Array.length array

            index_ =
                index + delta

            index2 =
                if index_ >= len then
                    index_ - len
                else
                    index_

            char1 =
                Array.get index array

            char2 =
                Array.get index2 array
        in
            case ( char1, char2 ) of
                ( Just c1, Just c2 ) ->
                    let
                        total_ =
                            if c1 == c2 then
                                total + (Char.toCode c1) - 48
                            else
                                total
                    in
                        sum total_ (index + 1) delta array

                _ ->
                    total


parse : String -> Array Char
parse string =
    string
        |> String.filter Char.isDigit
        |> String.toList
        |> Array.fromList
