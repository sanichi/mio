module Y20D21 exposing (answer)

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
        part1 data

    else
        part2 data


type alias Allergen =
    String


type alias Ingredient =
    String


type alias Allergen2Ingredient =
    Dict Allergen Ingredient


type alias Allergen2Ingredients =
    Dict Allergen (Set Ingredient)


type alias Data =
    { a2i : Allergen2Ingredient
    , foods : List (Set Ingredient)
    }


part1 : Data -> String
part1 data =
    let
        allIngredients =
            data.foods
                |> List.foldl (\a b -> Set.union a b) Set.empty

        ingredientsWithAlergens =
            data.a2i
                |> Dict.values
                |> Set.fromList

        ingredientsWithoutAlergens =
            ingredientsWithAlergens
                |> Set.diff allIngredients
                |> Set.toList
    in
    ingredientsWithoutAlergens
        |> List.map
            (\ingredient ->
                data.foods
                    |> List.filter (\ingredients -> Set.member ingredient ingredients)
                    |> List.length
            )
        |> List.sum
        |> String.fromInt


part2 : Data -> String
part2 data =
    data.a2i
        |> Dict.toList
        |> List.sortBy (\( alergen, _ ) -> alergen)
        |> List.map Tuple.second
        |> String.join ","


parse : String -> Data
parse input =
    let
        pairs =
            input
                |> Regex.split (Util.regex "\\n")
                |> List.map (Regex.find (Util.regex "^([a-z]+(?: [a-z]+)*) \\(contains ([a-z]+(?:, [a-z]+)*)\\)$"))
                |> List.filterMap List.head
                |> List.map .submatches
                |> List.filterMap
                    (\m ->
                        case m of
                            [ Just ingredients, Just alergens ] ->
                                Just ( ingredients, alergens )

                            _ ->
                                Nothing
                    )

        a2is =
            build pairs Dict.empty

        a2i =
            reduce a2is Dict.empty

        foods =
            pairs
                |> List.map Tuple.first
                |> List.map (String.split " ")
                |> List.map Set.fromList
    in
    Data a2i foods


build : List ( String, String ) -> Allergen2Ingredients -> Allergen2Ingredients
build pairs a2is =
    case pairs of
        ( ingredients, alergens ) :: rest ->
            let
                ingredients_ =
                    ingredients
                        |> String.split " "
                        |> Set.fromList

                alergens_ =
                    alergens
                        |> String.split ", "

                a2is_ =
                    List.foldl (update ingredients_) a2is alergens_
            in
            build rest a2is_

        _ ->
            a2is


update : Set String -> String -> Allergen2Ingredients -> Allergen2Ingredients
update ingredients alergen a2is =
    let
        ingredients_ =
            if Dict.member alergen a2is then
                a2is
                    |> Dict.get alergen
                    |> Maybe.withDefault Set.empty
                    |> Set.intersect ingredients

            else
                ingredients
    in
    Dict.insert alergen ingredients_ a2is


reduce : Allergen2Ingredients -> Allergen2Ingredient -> Allergen2Ingredient
reduce a2is a2i =
    let
        certain =
            a2is
                |> Dict.filter (\_ ingredients -> Set.size ingredients == 1)
                |> Dict.toList
                |> List.map
                    (\( alergen, ingredients ) ->
                        let
                            ingredient =
                                ingredients
                                    |> Set.toList
                                    |> List.head
                                    |> Maybe.withDefault "ingredient"
                        in
                        ( alergen, ingredient )
                    )
                |> Dict.fromList
    in
    if Dict.size certain == 0 then
        a2i

    else
        let
            a2i_ =
                a2i
                    |> Dict.union certain

            done =
                certain
                    |> Dict.values
                    |> Set.fromList

            a2is_ =
                a2is
                    |> Dict.map (\_ ingredients -> Set.diff ingredients done)
        in
        reduce a2is_ a2i_



-- example : String
-- example =
--     """
-- mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
-- trh fvjkl sbzzf mxmxvkd (contains dairy)
-- sqjhc fvjkl (contains soy)
-- sqjhc mxmxvkd sbzzf (contains fish)
--     """
