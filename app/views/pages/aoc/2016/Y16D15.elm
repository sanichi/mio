module Y16D15 exposing (answer)

import Regex exposing (find)
import Util exposing (regex)


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> search
            |> String.fromInt

    else
        input
            |> parse
            |> push (Disc 7 11 0)
            |> search
            |> String.fromInt


search : Maze -> Time
search maze =
    let
        shiftedMaze =
            initShift 1 [] maze
    in
    search_ 0 shiftedMaze


search_ : Time -> Maze -> Time
search_ time maze =
    if open maze then
        time

    else
        maze
            |> advance
            |> search_ (time + 1)


open : Maze -> Bool
open maze =
    List.all (\d -> d.position == 0) maze


advance : Maze -> Maze
advance maze =
    List.map (rotate 1) maze


rotate : Time -> Disc -> Disc
rotate time disc =
    { disc | position = modBy disc.positions (disc.position + time) }


initShift : Time -> Maze -> Maze -> Maze
initShift time maze initMaze =
    case initMaze of
        [] ->
            maze

        disc :: rest ->
            let
                newDisc =
                    rotate time disc

                newMaze =
                    push newDisc maze

                newTime =
                    time + 1
            in
            initShift newTime newMaze rest


parse : String -> Maze
parse input =
    input
        |> find (regex "Disc #(\\d+) has (\\d+) positions; at time=0, it is at position (\\d+).")
        |> List.map .submatches
        |> List.map (List.map (Maybe.withDefault ""))
        |> List.map (List.map String.toInt)
        |> List.map (List.map (Maybe.withDefault 0))
        |> List.map toDisc


toDisc : List Int -> Disc
toDisc numbers =
    case numbers of
        [ a, b, c ] ->
            Disc a b c

        _ ->
            invalid


type alias Disc =
    { number : Int
    , positions : Int
    , position : Int
    }


type alias Maze =
    List Disc


type alias Time =
    Int


invalid : Disc
invalid =
    { number = 0
    , positions = 1
    , position = 0
    }


push : a -> List a -> List a
push item list =
    list
        |> List.reverse
        |> (\l -> item :: l)
        |> List.reverse
