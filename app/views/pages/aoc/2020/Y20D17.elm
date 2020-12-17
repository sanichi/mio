module Y20D17 exposing (answer)

import Dict exposing (Dict)
import Regex
import Util


type alias Active =
    Dict String Bool


type alias Cube =
    { active : Active
    , width : Int
    , height : Int
    }


answer : Int -> String -> String
answer part input =
    let
        cube =
            parse input
    in
    if part == 1 then
        cube
            |> cycle 3 0
            |> count
            |> String.fromInt

    else
        cube
            |> cycle 4 0
            |> count
            |> String.fromInt


count : Cube -> Int
count cube =
    Dict.size cube.active


cycle : Int -> Int -> Cube -> Cube
cycle dim n cube =
    if n >= 6 then
        cube

    else
        let
            wuus =
                wRange dim n
        in
        cube
            |> cycleWuus n wuus cube.active
            |> cycle dim (n + 1)


cycleWuus : Int -> List Int -> Active -> Cube -> Cube
cycleWuus n wuus active cube =
    case wuus of
        w :: rest ->
            let
                zeds =
                    zRange n
            in
            cube
                |> cycleZeds n w zeds active
                |> cycleWuus n rest active

        _ ->
            cube


cycleZeds : Int -> Int -> List Int -> Active -> Cube -> Cube
cycleZeds n w zeds active cube =
    case zeds of
        z :: rest ->
            let
                rows =
                    yRange n cube
            in
            cube
                |> cycleRows n w z rows active
                |> cycleZeds n w rest active

        _ ->
            cube


cycleRows : Int -> Int -> Int -> List Int -> Active -> Cube -> Cube
cycleRows n w z rows active cube =
    case rows of
        y :: rest ->
            let
                cols =
                    xRange n cube
            in
            cube
                |> cycleCols w z y cols active
                |> cycleRows n w z rest active

        _ ->
            cube


cycleCols : Int -> Int -> Int -> List Int -> Active -> Cube -> Cube
cycleCols w z y cols active cube =
    case cols of
        x :: rest ->
            let
                n =
                    neighbours x y z w active

                i =
                    index [ x, y, z, w ]

                cube_ =
                    if Dict.member i active then
                        if n == 2 || n == 3 then
                            cube

                        else
                            { cube | active = Dict.remove i cube.active }

                    else if n == 3 then
                        { cube | active = Dict.insert i True cube.active }

                    else
                        cube
            in
            cycleCols w z y rest active cube_

        _ ->
            cube


neighbours : Int -> Int -> Int -> Int -> Active -> Int
neighbours x y z w active =
    [ [ x - 1, y - 1, z - 1, w - 1 ]
    , [ x - 1, y - 1, z + 0, w - 1 ]
    , [ x - 1, y - 1, z + 1, w - 1 ]
    , [ x - 1, y + 0, z - 1, w - 1 ]
    , [ x - 1, y + 0, z + 0, w - 1 ]
    , [ x - 1, y + 0, z + 1, w - 1 ]
    , [ x - 1, y + 1, z - 1, w - 1 ]
    , [ x - 1, y + 1, z + 0, w - 1 ]
    , [ x - 1, y + 1, z + 1, w - 1 ]
    , [ x + 0, y - 1, z - 1, w - 1 ]
    , [ x + 0, y - 1, z + 0, w - 1 ]
    , [ x + 0, y - 1, z + 1, w - 1 ]
    , [ x + 0, y + 0, z - 1, w - 1 ]
    , [ x + 0, y + 0, z + 0, w - 1 ]
    , [ x + 0, y + 0, z + 1, w - 1 ]
    , [ x + 0, y + 1, z - 1, w - 1 ]
    , [ x + 0, y + 1, z + 0, w - 1 ]
    , [ x + 0, y + 1, z + 1, w - 1 ]
    , [ x + 1, y - 1, z - 1, w - 1 ]
    , [ x + 1, y - 1, z + 0, w - 1 ]
    , [ x + 1, y - 1, z + 1, w - 1 ]
    , [ x + 1, y + 0, z - 1, w - 1 ]
    , [ x + 1, y + 0, z + 0, w - 1 ]
    , [ x + 1, y + 0, z + 1, w - 1 ]
    , [ x + 1, y + 1, z - 1, w - 1 ]
    , [ x + 1, y + 1, z + 0, w - 1 ]
    , [ x + 1, y + 1, z + 1, w - 1 ]
    , [ x - 1, y - 1, z - 1, w + 0 ]
    , [ x - 1, y - 1, z + 0, w + 0 ]
    , [ x - 1, y - 1, z + 1, w + 0 ]
    , [ x - 1, y + 0, z - 1, w + 0 ]
    , [ x - 1, y + 0, z + 0, w + 0 ]
    , [ x - 1, y + 0, z + 1, w + 0 ]
    , [ x - 1, y + 1, z - 1, w + 0 ]
    , [ x - 1, y + 1, z + 0, w + 0 ]
    , [ x - 1, y + 1, z + 1, w + 0 ]
    , [ x + 0, y - 1, z - 1, w + 0 ]
    , [ x + 0, y - 1, z + 0, w + 0 ]
    , [ x + 0, y - 1, z + 1, w + 0 ]
    , [ x + 0, y + 0, z - 1, w + 0 ]
    , [ x + 0, y + 0, z + 1, w + 0 ]
    , [ x + 0, y + 1, z - 1, w + 0 ]
    , [ x + 0, y + 1, z + 0, w + 0 ]
    , [ x + 0, y + 1, z + 1, w + 0 ]
    , [ x + 1, y - 1, z - 1, w + 0 ]
    , [ x + 1, y - 1, z + 0, w + 0 ]
    , [ x + 1, y - 1, z + 1, w + 0 ]
    , [ x + 1, y + 0, z - 1, w + 0 ]
    , [ x + 1, y + 0, z + 0, w + 0 ]
    , [ x + 1, y + 0, z + 1, w + 0 ]
    , [ x + 1, y + 1, z - 1, w + 0 ]
    , [ x + 1, y + 1, z + 0, w + 0 ]
    , [ x + 1, y + 1, z + 1, w + 0 ]
    , [ x - 1, y - 1, z - 1, w + 1 ]
    , [ x - 1, y - 1, z + 0, w + 1 ]
    , [ x - 1, y - 1, z + 1, w + 1 ]
    , [ x - 1, y + 0, z - 1, w + 1 ]
    , [ x - 1, y + 0, z + 0, w + 1 ]
    , [ x - 1, y + 0, z + 1, w + 1 ]
    , [ x - 1, y + 1, z - 1, w + 1 ]
    , [ x - 1, y + 1, z + 0, w + 1 ]
    , [ x - 1, y + 1, z + 1, w + 1 ]
    , [ x + 0, y - 1, z - 1, w + 1 ]
    , [ x + 0, y - 1, z + 0, w + 1 ]
    , [ x + 0, y - 1, z + 1, w + 1 ]
    , [ x + 0, y + 0, z - 1, w + 1 ]
    , [ x + 0, y + 0, z + 0, w + 1 ]
    , [ x + 0, y + 0, z + 1, w + 1 ]
    , [ x + 0, y + 1, z - 1, w + 1 ]
    , [ x + 0, y + 1, z + 0, w + 1 ]
    , [ x + 0, y + 1, z + 1, w + 1 ]
    , [ x + 1, y - 1, z - 1, w + 1 ]
    , [ x + 1, y - 1, z + 0, w + 1 ]
    , [ x + 1, y - 1, z + 1, w + 1 ]
    , [ x + 1, y + 0, z - 1, w + 1 ]
    , [ x + 1, y + 0, z + 0, w + 1 ]
    , [ x + 1, y + 0, z + 1, w + 1 ]
    , [ x + 1, y + 1, z - 1, w + 1 ]
    , [ x + 1, y + 1, z + 0, w + 1 ]
    , [ x + 1, y + 1, z + 1, w + 1 ]
    ]
        |> List.map index
        |> List.filterMap (\i -> Dict.get i active)
        |> List.length


xRange : Int -> Cube -> List Int
xRange n cube =
    List.range (-n - 1) (cube.width + n)


yRange : Int -> Cube -> List Int
yRange n cube =
    List.range (-n - 1) (cube.height + n)


zRange : Int -> List Int
zRange n =
    List.range (-n - 1) (n + 1)


wRange : Int -> Int -> List Int
wRange dim n =
    if dim == 4 then
        List.range (-n - 1) (n + 1)

    else
        [ 0 ]


parse : String -> Cube
parse input =
    let
        rows =
            input
                |> Regex.find (Util.regex "[.#]+")
                |> List.map .match

        height =
            rows
                |> List.length

        width =
            rows
                |> List.head
                |> Maybe.withDefault ""
                |> String.length

        active =
            rows
                |> List.indexedMap (\y r -> ( y, r ))
                |> parseRows Dict.empty
    in
    Cube active width height


parseRows : Active -> List ( Int, String ) -> Active
parseRows active rows =
    case rows of
        ( y, row ) :: rest ->
            let
                active_ =
                    row
                        |> String.toList
                        |> List.indexedMap (\x c -> ( x, c ))
                        |> parseCols y active
            in
            parseRows active_ rest

        _ ->
            active


parseCols : Int -> Active -> List ( Int, Char ) -> Active
parseCols y active cols =
    case cols of
        ( x, col ) :: rest ->
            let
                active_ =
                    if col == '#' then
                        Dict.insert (index [ x, y, 0, 0 ]) True active

                    else
                        active
            in
            parseCols y active_ rest

        _ ->
            active


index : List Int -> String
index xyz =
    xyz
        |> List.map String.fromInt
        |> String.join "-"


example : String
example =
    ".#. ..# ###"
