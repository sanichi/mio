module Y15D05 where

import Regex exposing (HowMany(All), Regex, find, regex)


part1 : String -> String
part1 input =
  parse input nice1


part2 : String -> String
part2 input =
  parse input nice2


parse : String -> (String -> Bool) -> String
parse input nice =
  find All stringRgx input
    |> List.map .match
    |> List.filter nice
    |> List.length
    |> toString


nice1 : String -> Bool
nice1 string =
  let
    vowels = count vowelRgx string
    dubles = count dubleRgx string
    badies = count badieRgx string
  in
    vowels >= 3 && dubles > 0 && badies == 0


nice2 : String -> Bool
nice2 string =
  let
    pairs = count pairsRgx string
    twips = count twipsRgx string
  in
    pairs > 0 && twips > 0


count : Regex -> String -> Int
count rgx string =
  find All rgx string |> List.length


stringRgx = regex "[a-z]{10,}"
vowelRgx  = regex "[aeiou]"
dubleRgx  = regex "(.)\\1"
badieRgx  = regex "(:?ab|cd|pq|xy)"
pairsRgx  = regex "(..).*\\1"
twipsRgx  = regex "(.).\\1"
