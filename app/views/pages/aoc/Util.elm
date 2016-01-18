module Util
  ( combinations
  , join
  , permutations
  ) where


join : String -> String -> String
join p1 p2 =
  p1 ++ " | " ++ p2


combinations : Int -> List a -> List (List a)
combinations n list =
  if n < 0 || n > (List.length list)
    then [ ]
    else combo n list


combo : Int -> List a -> List (List a)
combo n list =
  if n == 0
    then [ [ ] ]
    else
      if n == (List.length list)
        then [ list ]
        else
          case list of
            [ ] -> [ ]
            x :: xs ->
              let
                c1 = combinations (n - 1) xs |> List.map ((::) x)
                c2 = combinations n xs
              in
                c1 ++ c2

{-
  The remaining functions are all from:
  https://github.com/circuithub/elm-list-extra/blob/master/src/List/Extra.elm
-}

permutations : List a -> List (List a)
permutations xs' =
  case xs' of
    [] -> [[]]
    xs ->
      let
        f (y, ys) = List.map ((::) y) (permutations ys)
      in
        List.concatMap f (select xs)


select : List a -> List (a, List a)
select xs =
  case xs of
    []      -> []
    x :: xs -> (x, xs) :: List.map (\(y, ys) -> (y, x :: ys)) (select xs)
