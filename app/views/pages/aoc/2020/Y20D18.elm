module Y20D18 exposing (answer)

import Regex
import Util


answer : Int -> String -> String
answer part input =
    input
        |> parse
        |> List.map (reduce part)
        |> List.sum
        |> String.fromInt


type Term
    = Plus Int
    | Mult Int


reduce : Int -> String -> Int
reduce part expression =
    let
        replacePluses m =
            String.fromInt (eval m.match)

        reducedPluses =
            if part == 1 then
                expression

            else
                Regex.replace (Util.regex "[1-9]\\d*( \\+ [1-9]\\d*)+") replacePluses expression

        replaceBrackets m =
            case m.submatches of
                [ Just expr ] ->
                    String.fromInt (eval expr)

                _ ->
                    "0"

        reducedBrackets =
            Regex.replace (Util.regex "\\(([^()]+)\\)") replaceBrackets reducedPluses

        finished =
            if part == 1 then
                not (String.contains "(" reducedBrackets)

            else
                not (String.contains "(" reducedBrackets || String.contains "+" reducedBrackets)
    in
    if finished then
        eval reducedBrackets

    else
        reduce part reducedBrackets


eval : String -> Int
eval expression =
    let
        terms =
            expression
                |> Regex.find (Util.regex "(\\+|\\*) ([1-9]\\d*)")
                |> List.map .submatches
                |> List.filterMap
                    (\m ->
                        case m of
                            [ Just op, Just num_ ] ->
                                let
                                    num =
                                        num_
                                            |> String.toInt
                                            |> Maybe.withDefault 0
                                in
                                if op == "+" then
                                    Just (Plus num)

                                else
                                    Just (Mult num)

                            _ ->
                                Nothing
                    )

        val =
            expression
                |> Regex.find (Util.regex "^[1-9]\\d*")
                |> List.map .match
                |> List.head
                |> Maybe.withDefault "0"
                |> String.toInt
                |> Maybe.withDefault 0
    in
    eval_ val terms


eval_ : Int -> List Term -> Int
eval_ val terms =
    case terms of
        term :: rest ->
            case term of
                Plus num ->
                    eval_ (val + num) rest

                Mult num ->
                    eval_ (val * num) rest

        _ ->
            val


parse : String -> List String
parse input =
    input
        |> Regex.split (Util.regex "\\n")
        |> List.map String.trim
        |> List.filter (\e -> String.length e > 0)



-- example : String
-- example =
--     """
--         1 + 2 * 3 + 4 * 5 + 6
--         1 + (2 * 3) + (4 * (5 + 6))
--         2 * 3 + (4 * 5)
--         5 + (8 * 3 + 9 + 3 * 4 * 3)
--         5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))
--         ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2
--     """
