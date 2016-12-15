module Y16D15 exposing (answer)

import Regex


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> List.length
            |> toString
    else
        input
            |> parse
            |> List.any (\d -> d == invalid)
            |> toString


parse : String -> List Disc
parse input =
    input
        |> Regex.find Regex.All (Regex.regex "Disc #(\\d+) has (\\d+) positions; at time=0, it is at position (\\d+).")
        |> List.map .submatches
        |> List.map (List.map (Maybe.withDefault ""))
        |> List.map (List.map String.toInt)
        |> List.map (List.map (Result.withDefault 0))
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


invalid : Disc
invalid =
    { number = 0
    , positions = 0
    , position = 0
    }
