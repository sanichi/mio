module Y16D08 exposing (answers)

import Array exposing (Array)
import Regex
import Util


answers : String -> String
answers input =
    let
        instructions =
            parse input

        screen =
            decode instructions initialScreen

        a1 =
            count screen

        a2 =
            display screen
    in
        Util.join a1 a2


decode : List Instruction -> Screen -> Screen
decode instructions screen =
    case instructions of
        [] ->
            screen

        instruction :: rest ->
            screen
                |> step instruction
                |> decode rest


step : Instruction -> Screen -> Screen
step instruction screen =
    case instruction of
        Rect x y ->
            rect x y screen

        Row x y ->
            rotateRow x y screen

        Col x y ->
            rotateCol x y screen

        Invalid ->
            screen


rect : Int -> Int -> Screen -> Screen
rect x y screen =
    if y <= 0 then
        screen
    else
        let
            newRow =
                screen
                    |> Array.get (y - 1)
                    |> Maybe.withDefault Array.empty
                    |> Array.toList
                    |> List.drop x
                    |> (++) (List.repeat x True)
                    |> Array.fromList

            newScreen =
                Array.set (y - 1) newRow screen
        in
            rect x (y - 1) newScreen


rotateRow : Int -> Int -> Screen -> Screen
rotateRow y r screen =
    let
        oldRow =
            screen
                |> Array.get y
                |> Maybe.withDefault Array.empty
                |> Array.toList

        len =
            List.length oldRow

        x =
            r % len

        newRight =
            List.take (len - x) oldRow

        newLeft =
            List.drop (len - x) oldRow

        newRow =
            Array.fromList (newLeft ++ newRight)
    in
        Array.set y newRow screen


rotateCol : Int -> Int -> Screen -> Screen
rotateCol x r screen =
    screen
        |> flipScreen
        |> rotateRow x r
        |> flipScreen


flipScreen : Screen -> Screen
flipScreen screen =
    let
        newRowLen =
            screen
                |> Array.get 0
                |> Maybe.withDefault Array.empty
                |> Array.length
    in
        List.range 0 (newRowLen - 1)
            |> List.map (flipRow screen)
            |> Array.fromList


flipRow : Screen -> Int -> Array Bool
flipRow screen y =
    screen
        |> Array.map (Array.get y)
        |> Array.map (Maybe.withDefault False)


count : Screen -> String
count screen =
    let
        count row =
            row
                |> Array.toList
                |> List.filter identity
                |> List.length
    in
        screen
            |> Array.toList
            |> List.map count
            |> List.sum
            |> toString


display : Screen -> String
display screen =
    let
        boolToString bool =
            if bool then
                "#"
            else
                "."

        rowToString row =
            row
                |> Array.map boolToString
                |> Array.toList
                |> String.concat
    in
        screen
            |> Array.toList
            |> List.map rowToString
            |> String.join "|"


type alias Screen =
    Array (Array Bool)


initialScreen : Screen
initialScreen =
    Array.repeat 6 (Array.repeat 50 False)


type Instruction
    = Rect Int Int
    | Row Int Int
    | Col Int Int
    | Invalid


parse : String -> List Instruction
parse input =
    input
        |> Regex.find Regex.All (Regex.regex "(rect |rotate (?:row y|column x)=)(\\d+)(?:x| by )(\\d+)")
        |> List.map .submatches
        |> List.map parseInstruction


parseInstruction : List (Maybe String) -> Instruction
parseInstruction submatches =
    let
        ( string, i, j ) =
            case submatches of
                [ Just s, Just p, Just q ] ->
                    ( s, (String.toInt p |> Result.withDefault 0), (String.toInt q |> Result.withDefault 0) )

                _ ->
                    ( "", 0, 0 )
    in
        case string of
            "rect " ->
                Rect i j

            "rotate row y=" ->
                Row i j

            "rotate column x=" ->
                Col i j

            _ ->
                Invalid



-- .##..####.#....####.#.....##..#...#####..##...###.
-- #..#.#....#....#....#....#..#.#...##....#..#.#....
-- #....###..#....###..#....#..#..#.#.###..#....#....
-- #....#....#....#....#....#..#...#..#....#.....##..
-- #..#.#....#....#....#....#..#...#..#....#..#....#.
-- .##..#....####.####.####..##....#..#.....##..###..
