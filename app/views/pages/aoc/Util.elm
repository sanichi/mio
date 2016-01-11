module Util where


join : String -> String -> String
join p1 p2 =
  p1 ++ " | " ++ p2


{-|
  The following are all from:
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
