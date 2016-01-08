module Y15D04 where

import MD5 exposing (md5)
import Regex
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    key = parse input
    p1 = find "00000" key
    p2 = find "000000" key
  in
    join p1 p2


parse : String -> String
parse input =
  Regex.find (Regex.AtMost 1) (Regex.regex "[a-z]+") input
    |> List.map .match
    |> List.head
    |> Maybe.withDefault "no secret key found"


find : String -> String -> String
find start key =
  recurse 1 start key


recurse : Int -> String -> String -> String
recurse step start key =
  let
    hash = md5 (key ++ (toString step))
  in
    if String.startsWith start hash
      then toString step
      else recurse (step + 1) start key
