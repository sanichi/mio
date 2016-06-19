module XY exposing
  ( cell_size
  , viewBox
  , cell_xy
  )


size : Int
size =
  1000


cell_padding : Float
cell_padding =
  0.4


ij : Int -> Int -> (Int, Int)
ij dim index =
  let
    i = index % dim
    j = index // dim
  in
    (i, j)


cell_xy : Int -> Int -> (Int, Int)
cell_xy dim index =
  let
    (i, j) = ij dim index
    csize = toFloat (cell_size dim)
    x = round (csize * (cell_padding + (toFloat i) * (1.0 + 2.0 * cell_padding)))
    y = round (csize * (cell_padding + (toFloat j) * (1.0 + 2.0 * cell_padding)))
  in
    (x, y)


cell_size : Int -> Int
cell_size dim
  = round (toFloat size / (toFloat dim * (1 + 2 * cell_padding)))


viewBox : String
viewBox =
  "0 0 " ++ toString size ++ " " ++ toString size
