module Point where

type alias Point = (Float, Float)

average : Point -> Point -> Point
average p1 p2 =
  let
    x = ((fst p1) + (fst p2)) / 2.0
    y = ((snd p1) + (snd p2)) / 2.0
  in
    (x, y)
