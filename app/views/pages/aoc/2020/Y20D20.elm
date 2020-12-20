module Y20D20 exposing (answer)

import Dict exposing (Dict)
import Regex
import Set exposing (Set)
import Util


answer : Int -> String -> String
answer part input =
    let
        data =
            parse input
    in
    if part == 1 then
        data
            |> product
            |> String.fromInt

    else
        "working on it"


type alias Images =
    Dict Int (List String)


type alias Edges =
    Dict Int (Set String)


type alias Stats =
    Dict String (Set Int)


type alias Counts =
    Dict Int Int


type alias Data =
    { images : Images
    , edges : Edges
    , stats : Stats
    , counts : Counts
    }


product : Data -> Int
product data =
    data.counts
        |> Dict.filter (\id num -> num == 4)
        |> Dict.toList
        |> List.map Tuple.first
        |> List.product


parse : String -> Data
parse input =
    let
        lines =
            input
                |> Regex.split (Util.regex "\\n")
                |> List.map String.trim
                |> List.filter (\e -> String.length e > 0)
    in
    let
        images =
            parse_ lines Nothing Dict.empty

        edges =
            Dict.map edgesFromImages images

        stats =
            statsFromEdges (Dict.toList edges) Dict.empty

        counts =
            countsFromStats (Dict.toList stats) Dict.empty
    in
    Data images edges stats counts


parse_ : List String -> Maybe Int -> Images -> Images
parse_ lines mid images =
    case lines of
        line :: rest ->
            let
                idMatches =
                    Regex.find (Util.regex "^Tile ([1-9]\\d*):$") line
            in
            if List.length idMatches == 1 then
                let
                    id =
                        idMatches
                            |> List.map .submatches
                            |> List.head
                            |> Maybe.withDefault []
                            |> List.head
                            |> Maybe.withDefault (Just "0")
                            |> Maybe.withDefault "0"
                            |> String.toInt
                            |> Maybe.withDefault 0
                in
                parse_ rest (Just id) images

            else
                let
                    rowMatches =
                        Regex.find (Util.regex "^([.#]{10})$") line
                in
                if List.length rowMatches == 1 then
                    let
                        row =
                            rowMatches
                                |> List.map .submatches
                                |> List.head
                                |> Maybe.withDefault []
                                |> List.head
                                |> Maybe.withDefault (Just "")
                                |> Maybe.withDefault ""

                        id =
                            Maybe.withDefault 0 mid

                        images_ =
                            if id > 0 && String.length row == 10 then
                                let
                                    rows =
                                        images
                                            |> Dict.get id
                                            |> Maybe.withDefault []
                                in
                                Dict.insert id (row :: rows) images

                            else
                                images
                    in
                    parse_ rest mid images_

                else
                    parse_ rest mid images

        _ ->
            images


edgesFromImages : Int -> List String -> Set String
edgesFromImages id rows =
    let
        top =
            rows
                |> List.head

        bottom =
            rows
                |> List.reverse
                |> List.head

        left =
            rows
                |> List.map String.toList
                |> List.map List.head
                |> List.filterMap identity
                |> String.fromList
                |> Just

        right =
            rows
                |> List.map String.toList
                |> List.map List.reverse
                |> List.map List.head
                |> List.filterMap identity
                |> String.fromList
                |> Just

        combined =
            [ top, bottom, left, right ]
                |> List.filterMap identity

        reversed =
            List.map String.reverse combined
    in
    Set.fromList (combined ++ reversed)


statsFromEdges : List ( Int, Set String ) -> Stats -> Stats
statsFromEdges pairs stats =
    case pairs of
        ( id, edges ) :: rest ->
            stats
                |> statsFromEdges_ id (Set.toList edges)
                |> statsFromEdges rest

        _ ->
            stats


statsFromEdges_ : Int -> List String -> Stats -> Stats
statsFromEdges_ id edges stats =
    case edges of
        edge :: rest ->
            let
                ids =
                    stats
                        |> Dict.get edge
                        |> Maybe.withDefault Set.empty
                        |> Set.insert id
            in
            stats
                |> Dict.insert edge ids
                |> statsFromEdges_ id rest

        _ ->
            stats


countsFromStats : List ( String, Set Int ) -> Counts -> Counts
countsFromStats pairs counts =
    case pairs of
        ( edge, ids ) :: rest ->
            if Set.size ids == 1 then
                let
                    id =
                        ids
                            |> Set.toList
                            |> List.head
                            |> Maybe.withDefault 0

                    count =
                        counts
                            |> Dict.get id
                            |> Maybe.withDefault 0
                in
                counts
                    |> Dict.insert id (count + 1)
                    |> countsFromStats rest

            else
                countsFromStats rest counts

        _ ->
            counts


example : String
example =
    """
Tile 2311:
..##.#..#.
##..#.....
#...##..#.
####.#...#
##.##.###.
##...#.###
.#.#.#..##
..#....#..
###...#.#.
..###..###

Tile 1951:
#.##...##.
#.####...#
.....#..##
#...######
.##.#....#
.###.#####
###.##.##.
.###....#.
..#.#..#.#
#...##.#..

Tile 1171:
####...##.
#..##.#..#
##.#..#.#.
.###.####.
..###.####
.##....##.
.#...####.
#.##.####.
####..#...
.....##...

Tile 1427:
###.##.#..
.#..#.##..
.#.##.#..#
#.#.#.##.#
....#...##
...##..##.
...#.#####
.#.####.#.
..#..###.#
..##.#..#.

Tile 1489:
##.#.#....
..##...#..
.##..##...
..#...#...
#####...#.
#..#.#.#.#
...#.#.#..
##.#...##.
..##.##.##
###.##.#..

Tile 2473:
#....####.
#..#.##...
#.##..#...
######.#.#
.#...#.#.#
.#########
.###.#..#.
########.#
##...##.#.
..###.#.#.

Tile 2971:
..#.#....#
#...###...
#.#.###...
##.##..#..
.#####..##
.#..####.#
#..#.#..#.
..####.###
..#.#.###.
...#.#.#.#

Tile 2729:
...#.#.#.#
####.#....
..#.#.....
....#..#.#
.##..##.#.
.#.####...
####.#.#..
##.####...
##..#.##..
#.##...##.

Tile 3079:
#.#.#####.
.#..######
..#.......
######....
####.#..#.
.#...#.##.
#.#####.##
..#.###...
..#.......
..#.###...
    """
