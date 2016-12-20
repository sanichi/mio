module Y16D20 exposing (answer)

import Regex


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> lowest 0
            |> toString
    else
        input
            |> parse
            |> allowed 4294967296
            |> toString


lowest : Int -> List Block -> Int
lowest num blocks =
    case blocks of
        [] ->
            num

        block :: rest ->
            if num < block.lower then
                num
            else
                lowest (block.upper + 1) rest


allowed : Int -> List Block -> Int
allowed remaining blocks =
    case blocks of
        [] ->
            remaining

        block :: rest ->
            let
                newRemaining =
                    remaining - (size block)
            in
                allowed newRemaining rest


type alias Block =
    { lower : Int
    , upper : Int
    }


invalid : Block
invalid =
    Block 0 0


notInvalid : Block -> Bool
notInvalid block =
    block /= invalid


parse : String -> List Block
parse input =
    input
        |> Regex.find Regex.All (Regex.regex "(\\d+)-(\\d+)")
        |> List.map .submatches
        |> List.map (List.map (Maybe.withDefault ""))
        |> List.map (List.map String.toInt)
        |> List.map (List.map (Result.withDefault 0))
        |> List.map toBlock
        |> List.filter notInvalid
        |> List.sortBy .lower
        |> compact


toBlock : List Int -> Block
toBlock list =
    case list of
        [ l, u ] ->
            if l <= u then
                Block l u
            else
                invalid

        _ ->
            invalid


compact : List Block -> List Block
compact blocks =
    case blocks of
        [] ->
            blocks

        [ _ ] ->
            blocks

        b1 :: b2 :: rest ->
            if overlap b1 b2 then
                let
                    b =
                        merge b1 b2
                in
                    compact (b :: rest)
            else
                b1 :: compact (b2 :: rest)


overlap : Block -> Block -> Bool
overlap b1 b2 =
    b2.lower <= b1.upper


merge : Block -> Block -> Block
merge b1 b2 =
    if b2.upper <= b1.upper then
        b1
    else
        Block b1.lower b2.upper


size : Block -> Int
size block =
    block.upper - block.lower + 1
