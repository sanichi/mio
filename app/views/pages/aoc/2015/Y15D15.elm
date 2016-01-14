module Y15D15 where

import Regex exposing (HowMany(AtMost), find, regex)
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    model = parseInput input
    p1 = List.length model |> toString
    p2 = List.length model |> toString
  in
    join p1 p2


parseInput : String -> Model
parseInput input =
  String.split "\n" input
    |> List.filter (\l -> l /= "")
    |> List.foldl parseLine [ ]


parseLine : String -> Model -> Model
parseLine line model =
  let
    rgx =
      "^(\\w+): "
        ++ "capacity (-?\\d+), "
        ++ "durability (-?\\d+), "
        ++ "flavor (-?\\d+), "
        ++ "texture (-?\\d+), "
        ++ "calories (-?\\d+)$"
    matches = find (AtMost 1) (regex rgx) line |> List.map .submatches
  in
    case matches of
      [ [ Just nm, Just cp1, Just du1, Just fl1, Just tx1, Just cl1 ] ] ->
        let
          cp2 = parseInt cp1
          du2 = parseInt du1
          fl2 = parseInt fl1
          tx2 = parseInt tx1
          cl2 = parseInt cl1
        in
          Ingredient nm cp2 du2 fl2 tx2 cl2 :: model
      _ -> model


parseInt : String -> Int
parseInt s =
  String.toInt s |> Result.withDefault 0


type alias Model = List Ingredient


type alias Ingredient =
  { name       : String
  , capacity   : Int
  , durability : Int
  , flavor     : Int
  , texture    : Int
  , calories   : Int
  }
