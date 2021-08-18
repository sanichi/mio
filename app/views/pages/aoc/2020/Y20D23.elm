module Y20D23 exposing (answer)

import Dict exposing (Dict)


answer : Int -> String -> String
answer part input =
    let
        cups =
            parse input
    in
    if part == 1 then
        cups
            |> move 100
            |> after1

    else
        cups
            |> extend 1000000
            |> move 10000000
            |> stars1


type alias Cups =
    { current : Int
    , size : Int
    , next : Dict Int Int
    }


move : Int -> Cups -> Cups
move n cups =
    if n == 0 then
        cups

    else
        let
            c1 =
                get cups.current cups.next

            c2 =
                get c1 cups.next

            c3 =
                get c2 cups.next

            current =
                get c3 cups.next

            d1 =
                destination cups.current cups.size [ c1, c2, c3 ]

            d2 =
                get d1 cups.next

            next =
                cups.next
                    |> Dict.insert d1 c1
                    |> Dict.insert c3 d2
                    |> Dict.insert cups.current current
        in
        move (n - 1) { cups | current = current, next = next }


after1 : Cups -> String
after1 cups =
    after1_ 1 cups ""


after1_ : Int -> Cups -> String -> String
after1_ cup cups after =
    let
        next =
            get cup cups.next
    in
    if next == 1 then
        after

    else
        after1_ next cups (after ++ String.fromInt next)


extend : Int -> Cups -> Cups
extend size cups =
    let
        last =
            cups.next
                |> Dict.toList
                |> List.filter (\( _, c2 ) -> c2 == cups.current)
                |> List.map Tuple.first
                |> List.head
                |> Maybe.withDefault 0

        first =
            cups.size + 1

        next =
            Dict.insert last first cups.next

        list =
            List.range first size
    in
    link list { cups | next = next }


stars1 : Cups -> String
stars1 cups =
    let
        c1 =
            get 1 cups.next

        c2 =
            get c1 cups.next
    in
    String.fromInt (c1 * c2)


destination : Int -> Int -> List Int -> Int
destination current max excluded =
    let
        d =
            if current > 1 then
                current - 1

            else
                max
    in
    if List.member d excluded then
        destination d max excluded

    else
        d


get : Int -> Dict Int Int -> Int
get k d =
    Maybe.withDefault 0 (Dict.get k d)


parse : String -> Cups
parse input =
    let
        list =
            input
                |> String.trim
                |> String.split ""
                |> List.filterMap String.toInt

        current =
            list
                |> List.head
                |> Maybe.withDefault 0
    in
    link list (Cups current 0 Dict.empty)


link : List Int -> Cups -> Cups
link list cups =
    case list of
        c1 :: c2 :: rest ->
            link (c2 :: rest) { cups | next = Dict.insert c1 c2 cups.next, size = cups.size + 1 }

        [ last ] ->
            { cups | next = Dict.insert last cups.current cups.next, size = cups.size + 1 }

        _ ->
            cups



-- example : String
-- example =
--     "389125467"
