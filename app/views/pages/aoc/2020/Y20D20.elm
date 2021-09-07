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
        "use ruby - see https://bitbucket.org/sanichi/mio/src/main/app/models/aoc/y2020d20.rb"


type alias Id =
    Int


type alias Edge =
    String


type alias ImageRow =
    String


type alias Image =
    List ImageRow


type alias Images =
    Dict Id Image


type alias Edges =
    Dict Id (Set Edge)


type alias EdgeConnections =
    Dict Edge (Set Id)


type alias ImageConnections =
    Dict Id (Set Id)


type alias Data =
    { images : Images
    , edges : Edges
    , edgeConnections : EdgeConnections
    , imageConnections : ImageConnections
    }


product : Data -> Int
product data =
    data.imageConnections
        |> Dict.filter (\_ ids -> Set.size ids == 2)
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

        edgeConnections =
            edgeConnectionsFromEdges (Dict.toList edges) Dict.empty

        imageConnections =
            imageConnectionsFromEdgeConnections (Dict.toList edgeConnections) Dict.empty
    in
    Data images edges edgeConnections imageConnections


parse_ : List String -> Maybe Id -> Images -> Images
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


edgesFromImages : Id -> Image -> Set Edge
edgesFromImages _ rows =
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


edgeConnectionsFromEdges : List ( Id, Set Edge ) -> EdgeConnections -> EdgeConnections
edgeConnectionsFromEdges pairs edgeConnections =
    case pairs of
        ( id, edges ) :: rest ->
            edgeConnections
                |> edgeConnectionsFromEdges_ id (Set.toList edges)
                |> edgeConnectionsFromEdges rest

        _ ->
            edgeConnections


edgeConnectionsFromEdges_ : Id -> List Edge -> EdgeConnections -> EdgeConnections
edgeConnectionsFromEdges_ id edges edgeConnections =
    case edges of
        edge :: rest ->
            let
                ids =
                    edgeConnections
                        |> Dict.get edge
                        |> Maybe.withDefault Set.empty
                        |> Set.insert id
            in
            edgeConnections
                |> Dict.insert edge ids
                |> edgeConnectionsFromEdges_ id rest

        _ ->
            edgeConnections


imageConnectionsFromEdgeConnections : List ( Edge, Set Id ) -> ImageConnections -> ImageConnections
imageConnectionsFromEdgeConnections pairs imageConnections =
    case pairs of
        ( _, ids ) :: rest ->
            case Set.toList ids of
                [ id1, id2 ] ->
                    let
                        s1 =
                            imageConnections
                                |> Dict.get id1
                                |> Maybe.withDefault Set.empty
                                |> Set.insert id2

                        s2 =
                            imageConnections
                                |> Dict.get id2
                                |> Maybe.withDefault Set.empty
                                |> Set.insert id1

                        imageConnections_ =
                            imageConnections
                                |> Dict.insert id1 s1
                                |> Dict.insert id2 s2
                    in
                    imageConnectionsFromEdgeConnections rest imageConnections_

                _ ->
                    imageConnectionsFromEdgeConnections rest imageConnections

        _ ->
            imageConnections



-- example : String
-- example =
--     """
-- Tile 2311:
-- ..##.#..#.
-- ##..#.....
-- #...##..#.
-- ####.#...#
-- ##.##.###.
-- ##...#.###
-- .#.#.#..##
-- ..#....#..
-- ###...#.#.
-- ..###..###
-- Tile 1951:
-- #.##...##.
-- #.####...#
-- .....#..##
-- #...######
-- .##.#....#
-- .###.#####
-- ###.##.##.
-- .###....#.
-- ..#.#..#.#
-- #...##.#..
-- Tile 1171:
-- ####...##.
-- #..##.#..#
-- ##.#..#.#.
-- .###.####.
-- ..###.####
-- .##....##.
-- .#...####.
-- #.##.####.
-- ####..#...
-- .....##...
-- Tile 1427:
-- ###.##.#..
-- .#..#.##..
-- .#.##.#..#
-- #.#.#.##.#
-- ....#...##
-- ...##..##.
-- ...#.#####
-- .#.####.#.
-- ..#..###.#
-- ..##.#..#.
-- Tile 1489:
-- ##.#.#....
-- ..##...#..
-- .##..##...
-- ..#...#...
-- #####...#.
-- #..#.#.#.#
-- ...#.#.#..
-- ##.#...##.
-- ..##.##.##
-- ###.##.#..
-- Tile 2473:
-- #....####.
-- #..#.##...
-- #.##..#...
-- ######.#.#
-- .#...#.#.#
-- .#########
-- .###.#..#.
-- ########.#
-- ##...##.#.
-- ..###.#.#.
-- Tile 2971:
-- ..#.#....#
-- #...###...
-- #.#.###...
-- ##.##..#..
-- .#####..##
-- .#..####.#
-- #..#.#..#.
-- ..####.###
-- ..#.#.###.
-- ...#.#.#.#
-- Tile 2729:
-- ...#.#.#.#
-- ####.#....
-- ..#.#.....
-- ....#..#.#
-- .##..##.#.
-- .#.####...
-- ####.#.#..
-- ##.####...
-- ##..#.##..
-- #.##...##.
-- Tile 3079:
-- #.#.#####.
-- .#..######
-- ..#.......
-- ######....
-- ####.#..#.
-- .#...#.##.
-- #.#####.##
-- ..#.###...
-- ..#.......
-- ..#.###...
--     """
