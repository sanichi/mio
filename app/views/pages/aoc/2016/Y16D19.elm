module Y16D19 exposing (answer)


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> stealLeft
            |> toString
    else
        input
            |> parse
            |> stealAcross
            |> toString


stealLeft : Int -> Int
stealLeft num =
    let
        thresh =
            num
                |> toFloat
                |> logBase 2
                |> floor
                |> (^) 2
    in
        2 * (num - thresh) + 1


stealAcross : Int -> Int
stealAcross num =
    let
        thresh =
            num
                |> toFloat
                |> logBase 3
                |> floor
                |> (^) 3
    in
        if num == thresh then
            num
        else if num <= 2 * thresh then
            num - thresh
        else
            2 * num - 3 * thresh


parse : String -> Int
parse input =
    input
        |> String.dropRight 1
        |> String.toInt
        |> Result.withDefault 1
