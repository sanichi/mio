module Y20D07 exposing (answer)

import Dict exposing (Dict)
import Regex exposing (Match)
import Set exposing (Set)
import Util


answer : Int -> String -> String
answer part input =
    let
        lines =
            parse input

        bag =
            "shiny gold"
    in
    if part == 1 then
        lines
            |> ancestors
            |> count1 bag
            |> String.fromInt

    else
        lines
            |> descendants
            |> count2 bag
            |> String.fromInt


type alias Line =
    { parent : String
    , children : List ( String, Int )
    }


type alias Bags =
    Dict String Int


type alias Data =
    Dict String Bags


count1 : String -> Data -> Int
count1 child data =
    count1_ child data Set.empty |> Set.size


count1_ : String -> Data -> Set String -> Set String
count1_ child data soFar =
    let
        parents =
            data
                |> Dict.get child
                |> Maybe.withDefault Dict.empty
                |> Dict.keys
    in
    count1__ parents data soFar


count1__ : List String -> Data -> Set String -> Set String
count1__ parents data soFar =
    case parents of
        parent :: rest ->
            let
                nextFar =
                    if Set.member parent soFar then
                        soFar

                    else
                        let
                            grandparents =
                                data
                                    |> Dict.get parent
                                    |> Maybe.withDefault Dict.empty
                                    |> Dict.keys
                        in
                        soFar
                            |> Set.insert parent
                            |> count1__ grandparents data
            in
            count1__ rest data nextFar

        _ ->
            soFar


count2 : String -> Data -> Int
count2 parent data =
    count2_ parent 1 data - 1


count2_ : String -> Int -> Data -> Int
count2_ parent number data =
    let
        children =
            data
                |> Dict.get parent
                |> Maybe.withDefault Dict.empty
                |> Dict.toList
    in
    children
        |> List.map
            (\( child, num ) ->
                count2_ child num data
            )
        |> List.sum
        |> (*) number
        |> (+) number


ancestors : List Line -> Data
ancestors lines =
    ancestors_ lines Dict.empty


ancestors_ : List Line -> Data -> Data
ancestors_ lines soFar =
    case lines of
        line :: rest ->
            soFar
                |> ancestors__ line.children line.parent
                |> ancestors_ rest

        _ ->
            soFar


ancestors__ : List ( String, Int ) -> String -> Data -> Data
ancestors__ children parent soFar =
    case children of
        ( child, number ) :: rest ->
            let
                parents =
                    soFar
                        |> Dict.get child
                        |> Maybe.withDefault Dict.empty
                        |> Dict.insert parent number
            in
            soFar
                |> Dict.insert child parents
                |> ancestors__ rest parent

        _ ->
            soFar


descendants : List Line -> Data
descendants lines =
    descendants_ lines Dict.empty


descendants_ : List Line -> Data -> Data
descendants_ lines soFar =
    case lines of
        line :: rest ->
            soFar
                |> Dict.insert line.parent (Dict.fromList line.children)
                |> descendants_ rest

        _ ->
            soFar


parse : String -> List Line
parse input =
    input
        |> Regex.find (Util.regex "(\\w+ \\w+) bags contain ([^.]+)\\.")
        |> List.filterMap parseLine


parseLine : Match -> Maybe Line
parseLine match =
    case match.submatches of
        [ Just parent, Just list ] ->
            let
                children =
                    parseChildren list
            in
            Just (Line parent children)

        _ ->
            Nothing


parseChildren : String -> List ( String, Int )
parseChildren list =
    list
        |> Regex.find (Util.regex "([1-9]\\d*) (\\w+ \\w+) bag")
        |> List.map .submatches
        |> List.filterMap
            (\m ->
                case m of
                    [ Just numberStr, Just child ] ->
                        let
                            number =
                                String.toInt numberStr |> Maybe.withDefault 0
                        in
                        Just ( child, number )

                    _ ->
                        Nothing
            )


example1 : String
example1 =
    """
        light red bags contain 1 bright white bag, 2 muted yellow bags.
        dark orange bags contain 3 bright white bags, 4 muted yellow bags.
        bright white bags contain 1 shiny gold bag.
        muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
        shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
        dark olive bags contain 3 faded blue bags, 4 dotted black bags.
        vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
        faded blue bags contain no other bags.
        dotted black bags contain no other bags.
    """


example2 : String
example2 =
    """
        shiny gold bags contain 2 dark red bags.
        dark red bags contain 2 dark orange bags.
        dark orange bags contain 2 dark yellow bags.
        dark yellow bags contain 2 dark green bags.
        dark green bags contain 2 dark blue bags.
        dark blue bags contain 2 dark violet bags.
        dark violet bags contain no other bags.
    """
