module Y15D01 exposing (answer)


answer : Int -> String -> String
answer part input =
    if part == 1 then
        count 0 input |> String.fromInt

    else
        position 0 0 input |> String.fromInt


count : Int -> String -> Int
count floor instructions =
    let
        next =
            String.uncons instructions
    in
    case next of
        Just ( '(', remaining ) ->
            count (floor + 1) remaining

        Just ( ')', remaining ) ->
            count (floor - 1) remaining

        _ ->
            floor


position : Int -> Int -> String -> Int
position floor step instructions =
    if floor < 0 then
        step

    else
        let
            next =
                String.uncons instructions
        in
        case next of
            Just ( '(', remaining ) ->
                position (floor + 1) (step + 1) remaining

            Just ( ')', remaining ) ->
                position (floor - 1) (step + 1) remaining

            _ ->
                step
