module Y20D03 exposing (answer)

import Array exposing (Array)
import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        forrest =
            parse input
    in
    if part == 1 then
        ( 3, 1 )
            |> count forrest
            |> String.fromInt

    else
        [ ( 1, 1 ), ( 3, 1 ), ( 5, 1 ), ( 7, 1 ), ( 1, 2 ) ]
            |> List.map (count forrest)
            |> List.product
            |> String.fromInt


type alias Row =
    Array Int


type alias Forrest =
    { rows : Array Row
    , width : Int
    , height : Int
    }


count : Forrest -> ( Int, Int ) -> Int
count forrest ( dx, dy ) =
    count_ forrest ( dx, dy ) ( 0, 0 ) 0


count_ : Forrest -> ( Int, Int ) -> ( Int, Int ) -> Int -> Int
count_ forrest ( dx, dy ) ( x, y ) t =
    if y >= forrest.height then
        t

    else
        let
            dt =
                case Array.get y forrest.rows of
                    Just row ->
                        case Array.get (modBy forrest.width x) row of
                            Just tree ->
                                tree

                            _ ->
                                0

                    Nothing ->
                        0
        in
        count_ forrest ( dx, dy ) ( x + dx, y + dy ) (t + dt)


parse : String -> Forrest
parse input =
    let
        list =
            input
                |> Regex.find (Util.regex "[.#]+")
                |> List.map .match
                |> List.map parseRow

        rows =
            Array.fromList list

        width =
            case list of
                first :: rest ->
                    Array.length first

                _ ->
                    0

        height =
            List.length list
    in
    Forrest rows width height


parseRow : String -> Row
parseRow row =
    row
        |> String.split ""
        |> List.map
            (\c ->
                if c == "#" then
                    1

                else
                    0
            )
        |> Array.fromList


example : String
example =
    """
        ..##.......
        #...#...#..
        .#....#..#.
        ..#.#...#.#
        .#...##..#.
        ..#.##.....
        .#.#.#....#
        .#........#
        #.##...#...
        #...##....#
        .#..#...#.#
    """
