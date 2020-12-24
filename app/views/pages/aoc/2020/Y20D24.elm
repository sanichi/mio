module Y20D24 exposing (answer)

import Dict exposing (Dict)
import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        list =
            parse input
    in
    if part == 1 then
        list
            |> renovate
            |> count
            |> String.fromInt

    else
        list
            |> renovate
            |> flip 100
            |> count
            |> String.fromInt


type alias Step =
    String


type alias Walk =
    List Step


type alias Position =
    { x : Int
    , y : Int
    , z : Int
    }


type alias Key =
    String


type alias Tile =
    Bool


white : Tile
white =
    True


black : Tile
black =
    False


type alias Tiles =
    Dict Key Tile


count : Tiles -> Int
count tiles =
    tiles
        |> Dict.values
        |> List.filter (\t -> t == black)
        |> List.length


renovate : List Walk -> Tiles
renovate walks =
    renovate_ walks Dict.empty


renovate_ : List Walk -> Tiles -> Tiles
renovate_ walks tiles =
    case walks of
        walk :: rest ->
            let
                position =
                    walk
                        |> follow
                        |> toKey

                tile =
                    tiles
                        |> Dict.get position
                        |> Maybe.withDefault white
                        |> not
            in
            tiles
                |> Dict.insert position tile
                |> renovate_ rest

        _ ->
            tiles


flip : Int -> Tiles -> Tiles
flip days tiles =
    if days <= 0 then
        tiles

    else
        let
            expanded =
                expand tiles

            positions =
                Dict.keys expanded

            tiles_ =
                flip_ positions expanded Dict.empty
        in
        flip (days - 1) tiles_


flip_ : List Key -> Tiles -> Tiles -> Tiles
flip_ positions oldTiles tiles =
    case positions of
        position :: rest ->
            let
                tile =
                    oldTiles
                        |> Dict.get position
                        |> Maybe.withDefault white

                blacks =
                    position
                        |> nearby
                        |> List.map (\p -> Dict.get p oldTiles)
                        |> List.map (Maybe.withDefault white)
                        |> List.filter (\t -> t == black)
                        |> List.length

                tile_ =
                    if tile == black && (blacks == 0 || blacks > 2) then
                        white

                    else if tile == white && blacks == 2 then
                        black

                    else
                        tile
            in
            tiles
                |> Dict.insert position tile_
                |> flip_ rest oldTiles

        _ ->
            tiles


expand : Tiles -> Tiles
expand tiles =
    let
        blacks =
            Dict.filter (\position tile -> tile == black) tiles

        positions =
            Dict.keys blacks
    in
    expand_ positions tiles


expand_ : List Key -> Tiles -> Tiles
expand_ positions tiles =
    case positions of
        position :: rest ->
            let
                neighbours =
                    nearby position
            in
            tiles
                |> expand__ neighbours
                |> expand_ rest

        _ ->
            tiles


expand__ : List Key -> Tiles -> Tiles
expand__ positions tiles =
    case positions of
        position :: rest ->
            let
                tiles_ =
                    if Dict.member position tiles then
                        tiles

                    else
                        Dict.insert position white tiles
            in
            expand__ rest tiles_

        _ ->
            tiles


follow : Walk -> Position
follow walk =
    Position 0 0 0 |> follow_ walk


follow_ : Walk -> Position -> Position
follow_ walk p =
    case walk of
        step :: steps ->
            let
                d =
                    case step of
                        "e" ->
                            Position 1 -1 0

                        "w" ->
                            Position -1 1 0

                        "ne" ->
                            Position 1 0 -1

                        "nw" ->
                            Position 0 1 -1

                        "se" ->
                            Position 0 -1 1

                        "sw" ->
                            Position -1 0 1

                        _ ->
                            Position 0 0 0
            in
            Position (p.x + d.x) (p.y + d.y) (p.z + d.z) |> follow_ steps

        _ ->
            p


nearby : Key -> List Key
nearby position =
    let
        coordinates =
            position
                |> String.split "|"
                |> List.map String.toInt

        positions =
            case coordinates of
                [ Just x, Just y, Just z ] ->
                    [ Position (x + 1) (y - 1) z
                    , Position (x - 1) (y + 1) z
                    , Position (x + 1) y (z - 1)
                    , Position x (y + 1) (z - 1)
                    , Position x (y - 1) (z + 1)
                    , Position (x - 1) y (z + 1)
                    ]

                _ ->
                    []
    in
    List.map toKey positions


toKey : Position -> Key
toKey p =
    [ p.x, p.y, p.z ]
        |> List.map String.fromInt
        |> String.join "|"


parse : String -> List Walk
parse input =
    input
        |> Regex.split (Util.regex "\\n")
        |> List.map String.trim
        |> List.filter (\l -> String.length l > 0)
        |> List.map parseSteps


parseSteps : String -> Walk
parseSteps input =
    input
        |> Regex.find (Util.regex "e|w|ne|nw|se|sw")
        |> List.map .match


example : String
example =
    """
sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew
    """
