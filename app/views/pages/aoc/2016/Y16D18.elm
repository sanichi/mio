module Y16D18 exposing (answer)

import Regex


answer : Int -> String -> String
answer part input =
    let
        num =
            if part == 1 then
                40
            else
                400000
    in
        input
            |> parse
            |> count num 0
            |> toString


count : Int -> Int -> Row -> Int
count num total row =
    let
        rowCount =
            row
                |> List.filter not
                |> List.length

        newTotal =
            total + rowCount
    in
        if num <= 1 then
            newTotal
        else
            let
                newRow =
                    nextRow True row

                newNum =
                    num - 1
            in
                count newNum newTotal newRow


nextRow : Bool -> Row -> Row
nextRow start row =
    case row of
        [] ->
            []

        [ t1 ] ->
            let
                t =
                    isTrap False t1 False
            in
                [ t ]

        [ t1, t2 ] ->
            if start then
                let
                    t =
                        isTrap False t1 t2
                in
                    t :: nextRow False row
            else
                let
                    t =
                        isTrap t1 t2 False
                in
                    [ t ]

        t1 :: t2 :: t3 :: rest ->
            if start then
                let
                    t =
                        isTrap False t1 t2
                in
                    t :: nextRow False row
            else
                let
                    t =
                        isTrap t1 t2 t3
                in
                    t :: nextRow start (t2 :: t3 :: rest)


isTrap : Bool -> Bool -> Bool -> Bool
isTrap t1 t2 t3 =
    case ( t1, t2, t3 ) of
        ( True, True, False ) ->
            True

        ( False, True, True ) ->
            True

        ( True, False, False ) ->
            True

        ( False, False, True ) ->
            True

        _ ->
            False


type alias Row =
    List Bool


parse : String -> Row
parse input =
    input
        |> Regex.find (Regex.AtMost 1) (Regex.regex "\\S+")
        |> List.map .match
        |> List.head
        |> Maybe.withDefault ""
        |> String.toList
        |> List.map
            (\c ->
                if c == '^' then
                    True
                else
                    False
            )
