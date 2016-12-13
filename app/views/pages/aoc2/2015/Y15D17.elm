module Y15D17 exposing (answer)

import Regex exposing (HowMany(All), find, regex)
import Util


answer : Int -> String -> String
answer part input =
    let
        model =
            parse input

        number =
            combos (List.length model) 150 model

        select =
            if part == 1 then
                Tuple.first
            else
                Tuple.second
    in
        number
            |> select
            |> toString


combos : Int -> Int -> Model -> ( Int, Int )
combos n total model =
    if n == 0 then
        ( 0, 0 )
    else
        let
            p =
                Util.combinations n model
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


parse : String -> Model
parse input =
    find All (regex "[1-9]\\d*") input
        |> List.map .match
        |> List.map String.toInt
        |> List.map (Result.withDefault 0)
        |> List.filter (\i -> i > 0)


type alias Model =
    List Int
