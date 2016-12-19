module Y16D13 exposing (answer)


answer : Int -> String -> String
answer part input =
    let
        fav =
            parse input

        finish =
            Cell 31 39 0
    in
        search part fav finish [ start ] [ start ] |> toString


search : Int -> Int -> Cell -> List Cell -> List Cell -> Int
search part fav finish visited queue =
    case queue of
        [] ->
            0

        cell :: rest ->
            if part == 2 && cell.d == 50 then
                List.length visited
            else
                let
                    neighbours =
                        getNeighbours fav visited cell

                    goal =
                        neighbours
                            |> List.filter (same finish)
                            |> List.head
                            |> Maybe.withDefault start
                in
                    if part == 1 && goal.d > 0 then
                        goal.d
                    else
                        search part fav finish (visited ++ neighbours) (rest ++ neighbours)


type alias Cell =
    { x : Int
    , y : Int
    , d : Int
    }


getNeighbours : Int -> List Cell -> Cell -> List Cell
getNeighbours fav visited cell =
    let
        moves =
            [ ( 1, 0 ), ( 0, 1 ), ( -1, 0 ), ( 0, -1 ) ]

        new old move =
            Cell (old.x + (Tuple.first move)) (old.y + (Tuple.second move)) (old.d + 1)

        inBounds neighbour =
            neighbour.x >= 0 && neighbour.y >= 0

        notSeenBefore neighbour =
            visited
                |> List.any (same neighbour)
                |> not
    in
        moves
            |> List.map (new cell)
            |> List.filter inBounds
            |> List.filter (open fav)
            |> List.filter notSeenBefore


start : Cell
start =
    { x = 1
    , y = 1
    , d = 0
    }


open : Int -> Cell -> Bool
open fav cell =
    let
        x =
            cell.x

        y =
            cell.y

        num =
            x * x + 3 * x + 2 * x * y + y + y * y + fav

        ones =
            num
                |> toBinary
                |> String.toList
                |> List.filter (\c -> c == '1')
                |> List.length
    in
        ones % 2 == 0


toBinary : Int -> String
toBinary num =
    case num of
        0 ->
            "0"

        1 ->
            "1"

        _ ->
            let
                q =
                    num // 2

                r =
                    num % 2
            in
                toBinary q ++ toBinary r


same : Cell -> Cell -> Bool
same c1 c2 =
    c1.x == c2.x && c1.y == c2.y


parse : String -> Int
parse input =
    input
        |> String.dropRight 1
        |> String.toInt
        |> Result.withDefault 0
