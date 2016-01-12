module Y15D11 where

import Char
import Regex exposing (HowMany(All,AtMost), contains, find, regex)
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    p0 = parse input
    p1 = next p0
    p2 = next p1
  in
    join p1 p2


parse : String -> String
parse input =
  find (AtMost 1) (regex "[a-z]{8}") input
    |> List.map .match
    |> List.head
    |> Maybe.withDefault "no password found"


next : String -> String
next q =
  let
    p = increment q
  in
    if String.startsWith "invalid" p
      then p
      else
        if is_not_confusing p && has_a_straight p && has_enough_pairs p
          then p
          else next p


increment : String -> String
increment p =
  let
    parts =
      find (AtMost 1) (regex "^([a-z]*)([a-y])(z*)$") p
        |> List.map .submatches
        |> List.head
  in
    case parts of
      Just [ Just a, Just b, Just c ] ->
        let
          b1 = String.uncons b
          b2 =
            case b1 of
              Just (char, string) ->
                Char.toCode char
                  |> (+) 1
                  |> Char.fromCode
                  |> String.fromChar
              _ -> ""
          c1 = String.repeat (String.length c) "a"
        in
          if contains (regex "^[b-z]$") b2
            then a ++ b2 ++ c1
            else "invalid (" ++ p ++ ")"
      _ ->
        "invalid (" ++ p ++ ")"


is_not_confusing : String -> Bool
is_not_confusing p =
  contains (regex "[iol]") p |> not


has_a_straight : String -> Bool
has_a_straight p =
  contains (regex "(abc|bcd|cde|def|efg|fgh|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)") p


has_enough_pairs : String -> Bool
has_enough_pairs p =
  contains (regex "(.)\\1.*(.)(?!\\1)\\2") p
