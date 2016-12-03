module Y15D17 exposing (answers)

import Regex exposing (HowMany(All), find, regex)
import Tuple exposing (first, second)
import Util exposing (combinations, join)


answers : String -> String
answers input =
    let
        model =
            parseInput input

        number =
            combos (List.length model) 150 model

        p1 =
            first number |> toString

        p2 =
            second number |> toString
    in
        join p1 p2


combos : Int -> Int -> Model -> ( Int, Int )
combos n total model =
    if n == 0 then
        ( 0, 0 )
    else
        let
            p =
                combinations n model
                    |> List.filter (\c -> List.sum c == total)
                    |> List.length

            ( q, r ) =
                combos (n - 1) total model
        in
            ( p + q
            , if r == 0 then
                p
              else
                r
            )


parseInput : String -> Model
parseInput input =
    find All (regex "[1-9]\\d*") input
        |> List.map .match
        |> List.map String.toInt
        |> List.map (Result.withDefault 0)
        |> List.filter (\i -> i > 0)


type alias Model =
    List Int
