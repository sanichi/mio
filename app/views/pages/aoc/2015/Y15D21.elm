module Y15D21 exposing (..)

import Array exposing (Array)
import Regex
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    boss = parseInput input
    p1 = search boss lowest  0 initIndex |> toString
    p2 = search boss highest 0 initIndex |> toString
  in
    join p1 p2


search : Fighter -> (Bool -> Int -> Int -> Bool) -> Int -> Maybe Index -> Int
search boss candidate best index =
  case index of
    Nothing -> best
    Just i ->
      let
        player = fighterFromIndex i
        nextBest =
          if candidate (winner player boss) player.cost best
            then player.cost
            else best
      in
        search boss candidate nextBest (nextIndex i)


lowest : Bool -> Int -> Int -> Bool
lowest pwin pcost best =
  pwin && (best == 0 || pcost < best)


highest : Bool -> Int -> Int -> Bool
highest pwin pcost best =
  not pwin && pcost > best


fighterFromIndex : Index -> Fighter
fighterFromIndex i =
  let
    weapon = Array.get i.w  weapons |> Maybe.withDefault [0, 0, 0]
    armor  = Array.get i.a  armors  |> Maybe.withDefault [0, 0, 0]
    ring1  = Array.get i.r1 rings   |> Maybe.withDefault [0, 0, 0]
    ring2  = Array.get i.r2 rings   |> Maybe.withDefault [0, 0, 0]
  in
    let
      totals = List.map4 (\w a r1 r2 -> w + a + r1 + r2) weapon armor ring1 ring2
    in
      case totals of
        [ c, d, a ] -> Fighter 100 d a c True
        _           -> Fighter 0   0 0 0 True


nextIndex : Index -> Maybe Index
nextIndex i =
  if i.r2 < 7
    then Just { i | r2 = i.r2 + 1 }
    else
      if i.r1 < 6
        then Just { i | r1 = i.r1 + 1, r2 = i.r1 + 2 }
        else
          if i.a < 5
            then Just { i | a = i.a + 1, r1 = 0, r2 = 1 }
            else
              if i.w < 4
                then Just { i | w = i.w + 1, a = 0, r1 = 0, r2 = 1 }
                else Nothing


winner : Fighter -> Fighter -> Bool
winner attacker defender =
  if attacker.hitp <= 0
    then defender.player
    else
      let
        damage  = attacker.damage - defender.armor
        hitp    = defender.hitp - if damage < 1 then 1 else damage
        damaged = { defender | hitp = hitp }
      in
        winner damaged attacker


weapons : Array (List Int)
weapons =
  Array.fromList
    [ [ 8, 4, 0]
    , [10, 5, 0]
    , [25, 6, 0]
    , [40, 7, 0]
    , [74, 8, 0]
    ]


armors : Array (List Int)
armors =
  Array.fromList
    [ [  0, 0, 0]
    , [ 13, 0, 1]
    , [ 31, 0, 2]
    , [ 53, 0, 3]
    , [ 75, 0, 4]
    , [102, 0, 5]
    ]


rings : Array (List Int)
rings =
  Array.fromList
    [ [  0, 0, 0]
    , [  0, 0, 0]
    , [ 25, 1, 0]
    , [ 50, 2, 0]
    , [100, 3, 0]
    , [ 20, 0, 1]
    , [ 40, 0, 2]
    , [ 80, 0, 3]
    ]


parseInput : String -> Fighter
parseInput input =
  let
    ns =
      Regex.find (Regex.All) (Regex.regex "\\d+") input
        |> List.map .match
        |> List.map String.toInt
  in
    case ns of
      [ Ok h, Ok d, Ok a ] -> Fighter h d a 0 False
      _                    -> Fighter 0 0 0 0 False


type alias Fighter =
  { hitp   : Int
  , damage : Int
  , armor  : Int
  , cost   : Int
  , player : Bool
  }


type alias Index =
  { w  : Int
  , a  : Int
  , r1 : Int
  , r2 : Int
  }


initIndex : Maybe Index
initIndex =
  Just (Index 0 0 0 1)
