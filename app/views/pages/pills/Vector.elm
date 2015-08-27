module Vector where

type alias Vector =
  (Float, Float)


vAdd : Vector -> Vector -> Vector
vAdd (x1, y1) (x2, y2) =
  (x1 + x2, y1 + y2)


vSub : Vector -> Vector -> Vector
vSub (x1, y1) (x2, y2) =
  (x1 - x2, y1 - y2)


vMul : Float -> Vector -> Vector
vMul f (x, y) =
  (f * x, f * y)


vLen : Vector -> Float
vLen (x, y) =
  sqrt (x^2 + y^2)
