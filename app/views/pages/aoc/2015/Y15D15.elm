module Y15D15 where

import Regex exposing (HowMany(AtMost), find, regex)
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    model = parseInput input
    cookie = initCookie model 100
    p1 = highScore model 0 cookie |> toString
    p2 = List.length model |> toString
  in
    join p1 p2


highScore : Model -> Int -> Cookie -> Int
highScore model oldHigh oldCookie =
  let
    newHigh = List.maximum [score model oldCookie, oldHigh] |> Maybe.withDefault oldHigh
    newCookie = next oldCookie
  in
    case newCookie of
      Just cookie -> highScore model newHigh cookie
      Nothing -> newHigh


next : Cookie -> Maybe Cookie
next c =
  case c of
    [ ] ->
      Nothing
    1 :: rest ->
      let
        (n, l) = rollover rest
      in
        if n == 0
          then Nothing
          else
            let
              ones = List.repeat (List.length c - List.length l - 1) 1
            in
              Just (n :: ones ++ l)
    n :: rest ->
      Just (n - 1 :: increment rest)


rollover : List Int -> (Int, List Int)
rollover l =
  case l of
    [ ] -> (0, [ ])
    1 :: rest -> rollover rest
    n :: rest -> (n - 1, increment rest)


increment : List Int -> List Int
increment l =
  case l of
    [ ] -> [ ]
    n :: rest -> n + 1 :: rest


score : Model -> Cookie -> Int
score m c =
  let
    cp = List.map2 (*) (List.map .capacity   m) c |> List.sum
    du = List.map2 (*) (List.map .durability m) c |> List.sum
    fl = List.map2 (*) (List.map .flavor     m) c |> List.sum
    tx = List.map2 (*) (List.map .texture    m) c |> List.sum
  in
    [ cp, du, fl, tx ]
      |> List.map (\s -> if s < 0 then 0 else s)
      |> List.product


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

type alias Cookie =
  List Int

initCookie : Model -> Int -> Cookie
initCookie model total =
  let
    size = List.length model
    first = total - size + 1
    ones = List.repeat (size - 1) 1
  in
    first :: ones
