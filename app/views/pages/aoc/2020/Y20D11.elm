module Y20D11 exposing (answer)

import Array exposing (Array)
import Regex
import Util


answer : Int -> String -> String
answer part input =
    input
        |> parse
        |> choose part
        |> String.fromInt


type Seat
    = Floor
    | Empty
    | Occupied


type alias Row =
    Array Seat


type alias Seats =
    Array Row


type alias Data =
    { seats : Seats
    , changes : Int
    }


choose : Int -> Seats -> Int
choose part seats =
    Data seats 0
        |> shuffle part 0 0 seats
        |> .seats
        |> occupied


shuffle : Int -> Int -> Int -> Seats -> Data -> Data
shuffle part r c seats data =
    case Array.get r seats of
        Just row ->
            case Array.get c row of
                Just seat ->
                    data
                        |> update part r c seat seats
                        |> shuffle part r (c + 1) seats

                Nothing ->
                    shuffle part (r + 1) 0 seats data

        Nothing ->
            if data.changes == 0 then
                data

            else
                shuffle part 0 0 data.seats { data | changes = 0 }


update : Int -> Int -> Int -> Seat -> Seats -> Data -> Data
update part r c seat seats data =
    if seat == Floor then
        data

    else
        let
            number =
                near part r c seats
        in
        case seat of
            Empty ->
                if number == 0 then
                    { data | seats = put r c Occupied data.seats, changes = data.changes + 1 }

                else
                    data

            Occupied ->
                let
                    threshold =
                        if part == 1 then
                            4

                        else
                            5
                in
                if number >= threshold then
                    { data | seats = put r c Empty data.seats, changes = data.changes + 1 }

                else
                    data

            Floor ->
                data


near : Int -> Int -> Int -> Seats -> Int
near part r c seats =
    [ ( 1, 1 ), ( 1, 0 ), ( 1, -1 ), ( 0, 1 ), ( 0, -1 ), ( -1, 1 ), ( -1, 0 ), ( -1, -1 ) ]
        |> List.map
            (\( dr, dc ) ->
                let
                    seat =
                        if part == 1 then
                            get (r + dr) (c + dc) seats

                        else
                            spoke r c dr dc 1 seats
                in
                if seat == Just Occupied then
                    1

                else
                    0
            )
        |> List.sum


spoke : Int -> Int -> Int -> Int -> Int -> Seats -> Maybe Seat
spoke r c dr dc n seats =
    case get (r + n * dr) (c + n * dc) seats of
        Nothing ->
            Nothing

        Just Floor ->
            spoke r c dr dc (n + 1) seats

        Just seat ->
            Just seat


get : Int -> Int -> Seats -> Maybe Seat
get r c seats =
    case Array.get r seats of
        Just row ->
            Array.get c row

        Nothing ->
            Nothing


put : Int -> Int -> Seat -> Seats -> Seats
put r c seat seats =
    case Array.get r seats of
        Just row ->
            Array.set r (Array.set c seat row) seats

        Nothing ->
            seats


occupied : Seats -> Int
occupied seats =
    seats
        |> Array.map occupied_
        |> Array.toList
        |> List.sum


occupied_ : Row -> Int
occupied_ row =
    row
        |> Array.filter (\seat -> seat == Occupied)
        |> Array.length


parse : String -> Seats
parse input =
    input
        |> Regex.find (Util.regex "[.#L]+")
        |> List.map .match
        |> List.map toRow
        |> Array.fromList


toRow : String -> Row
toRow input =
    input
        |> String.toList
        |> List.map
            (\c ->
                case c of
                    '.' ->
                        Floor

                    'L' ->
                        Empty

                    _ ->
                        Occupied
            )
        |> Array.fromList


example : String
example =
    """
        L.LL.LL.LL
        LLLLLLL.LL
        L.L.L..L..
        LLLL.LL.LL
        L.LL.LL.LL
        L.LLLLL.LL
        ..L.L.....
        LLLLLLLLLL
        L.LLLLLL.L
        L.LLLLL.LL
    """
