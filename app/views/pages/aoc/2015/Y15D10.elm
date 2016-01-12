module Y15D10 where

import Regex exposing (HowMany(All,AtMost), Match, find, regex, replace)
import String
import Util exposing (join)


answers : String -> String
answers input =
  let
    digits = parse input

    digits' = conway 40 digits
    p1 = String.length digits' |> toString

    digits'' = conway 10 digits'
    p2 = String.length digits'' |> toString
  in
    join p1 p2


parse : String -> String
parse input =
  find (AtMost 1) (regex "\\d+") input
    |> List.map .match
    |> List.head
    |> Maybe.withDefault "no secret key found"


conway : Int -> String -> String
conway count digits =
  if count <= 0
    then digits
    else
      let
        digits' = replace All (regex "(\\d)\\1*") mapper digits
      in
        conway (count - 1) digits'


mapper : Match -> String
mapper match =
  let
    length = String.length match.match |> toString
    char = String.left 1 match.match
  in
    length ++ char
