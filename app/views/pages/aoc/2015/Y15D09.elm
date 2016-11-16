module Y15D09 exposing (..)

import Dict exposing (Dict)
import Regex exposing (HowMany(AtMost), find, regex)
import String
import Util exposing (join, permutations)


answers : String -> String
answers input =
    let
        model =
            parseInput input

        extremes =
            extreme model

        p1 =
            List.minimum extremes |> Maybe.withDefault 0 |> toString

        p2 =
            List.maximum extremes |> Maybe.withDefault 0 |> toString
    in
        join p1 p2


extreme : Model -> List Int
extreme model =
    let
        f ( c1, c2 ) =
            Dict.get (key c1 c2) model.distances |> Maybe.withDefault 0
    in
        permutations model.cities
            |> List.map (\perm -> pairs perm)
            |> List.map (\p -> List.map f p |> List.sum)


parseInput : String -> Model
parseInput input =
    String.split "\n" input
        |> List.filter (\l -> l /= "")
        |> List.foldl parseLine initModel


parseLine : String -> Model -> Model
parseLine line model =
    let
        matches =
            find (AtMost 1) (regex "^(\\w+) to (\\w+) = (\\d+)$") line |> List.map .submatches
    in
        case matches of
            [ [ Just c1, Just c2, Just d ] ] ->
                let
                    di =
                        String.toInt d |> Result.withDefault 0

                    distances =
                        model.distances
                            |> Dict.insert (key c1 c2) di
                            |> Dict.insert (key c2 c1) di

                    cities_ =
                        if List.member c1 model.cities then
                            model.cities
                        else
                            c1 :: model.cities

                    cities =
                        if List.member c2 cities_ then
                            cities_
                        else
                            c2 :: cities_
                in
                    { model
                        | distances = distances
                        , cities = cities
                    }

            _ ->
                model


pairs : List a -> List ( a, a )
pairs list =
    case list of
        [] ->
            []

        x :: [] ->
            []

        x :: (y :: rest) ->
            ( x, y ) :: pairs (y :: rest)


key : String -> String -> String
key c1 c2 =
    c1 ++ "|" ++ c2


type alias Model =
    { distances : Dict String Int
    , cities : List String
    }


initModel =
    { distances = Dict.empty
    , cities = []
    }
