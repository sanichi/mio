module Y15D20 where

import Dict
import Regex
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    goal = parseInput input
    p1 = house1 goal 1 |> toString
    p2 = 4 |> toString
  in
    join p1 p2


house1 : Int -> Int -> Int
house1 goal house =
  let
    presents =
      factors house
        |> List.map ((*) 10)
        |> List.sum
  in
    if presents >= goal
      then house
      else house1 goal (house + 1)


-- house2 : Int -> Int -> Dict Int Int -> Int
-- house2 goal elf houses =
--   let
--     presents = 11 * elf
--     (newHouses, done) = deliver50 goal elf presents 1
--   in
--     if done
--       then elf
--       else house2 goal (elf + 1) newHouses
--
--
-- deliver50 : Int -> Int -> Int -> Int -> Dict Int Int -> (Dict Int Int, Bool)
-- deliver50 goal elf presents offset houses =
--   if offset > 50
--     then (houses, False)
--     else
--       let
--         house = elf * offset
--         current = Dict.get house houses |> Maybe.withDefault 0
--         updated = current + presents
--         newHouses = Dict.insert house (current + presents) houses
--       in
--         (newHouses, updated >= goal)
-- my $elf = 1;
-- while ($elf < $goal)
-- {
--     my $presents = $elf * 11;
--     for (my $offset=1; $offset<=50; $offset++)
--     {
--         my $house = $elf * $offset;
--         last if $house > $goal;
--         $presents[$house] += $presents;
--     }
--     last if $presents[$elf] >= $goal;
--     $elf++;
-- }


factors : Int -> List Int
factors n =
  fac n 1 (toFloat n |> sqrt) [ ]


fac : Int -> Int -> Float -> List Int -> List Int
fac n i l fs =
  if (toFloat i) > l
    then fs
    else
      let
        fs1 =
          if n `rem` i /= 0
            then fs
            else
              let
                fs2 = i :: fs
                j = n // i
              in
                if j == i
                  then fs2
                  else j :: fs2
      in
        fs1 ++ fac n (i + 1) l fs


parseInput : String -> Int
parseInput input =
  Regex.find (Regex.AtMost 1) (Regex.regex "\\d+") input
    |> List.map .match
    |> List.head
    |> Maybe.withDefault "0"
    |> String.toInt
    |> Result.withDefault 0
