module Y17D03 exposing (answer)

import Char


answer : Int -> String -> String
answer part input =
    let
        num =
            parse input
    in
        if part == 1 then
            num
                |> manhattan
                |> toString
        else
            "TODO"


manhattan : Int -> Int
manhattan num =
    let
        level =
            findLevel 0 num

        upper =
            (2 * level + 1) ^ 2
    in
        spiralDown num level upper ( level, -level ) ( -1, 0 )


spiralDown : Int -> Int -> Int -> Position -> Direction -> Int
spiralDown num level upper ( x, y ) ( dx, dy ) =
    if upper <= num then
        (abs x) + (abs y)
    else
        let
            x_ =
                x + dx

            y_ =
                y + dy

            upper_ =
                upper - 1

            ( dx_, dy_ ) =
                case ( dx, dy ) of
                    ( -1, 0 ) ->
                        if x_ <= -level then
                            ( 0, 1 )
                        else
                            ( dx, dy )

                    ( 0, 1 ) ->
                        if y_ >= level then
                            ( 1, 0 )
                        else
                            ( dx, dy )

                    ( 1, 0 ) ->
                        if x_ >= level then
                            ( 0, -1 )
                        else
                            ( dx, dy )

                    _ ->
                        if y_ <= 0 then
                            ( -1, 0 )
                        else
                            ( dx, dy )
        in
            spiralDown num level upper_ ( x_, y_ ) ( dx_, dy_ )


findLevel : Int -> Int -> Int
findLevel level num =
    let
        width =
            2 * level + 1

        corner =
            width ^ 2
    in
        if num <= corner then
            level
        else
            findLevel (level + 1) num


parse : String -> Int
parse input =
    input
        |> String.filter Char.isDigit
        |> String.toInt
        |> Result.withDefault 1


type alias Position =
    ( Int, Int )


type alias Direction =
    ( Int, Int )



-- https://github.com/pierrebeitz/advent-of-code/blob/master/2017/Day03.elm#L48
