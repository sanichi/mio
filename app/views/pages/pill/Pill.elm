module Pill where

import Color exposing (Color, lightRed)
import Graphics.Collage exposing (Form, circle, filled, move)
import Time exposing (Time)


type alias Vector =
  (Float, Float)


vAdd : Vector -> Vector -> Vector
vAdd (x1, y1) (x2, y2) =
  (x1 + x2, y1 + y2)


vMul : Float -> Vector -> Vector
vMul f (x, y) =
  (f * x, f * y)


type alias Pill =
  { pos: Vector
  , vel: Vector
  , rad: Float
  , col: Color
  }


defaultPill : Pill
defaultPill =
  { pos = (0, 0)
  , vel = (0, -10)
  , rad = 15
  , col = lightRed
  }


updatePill : Time -> Pill -> Pill
updatePill t p =
  { p | pos <- vAdd p.pos <| vMul t p.vel }


viewPill : Pill -> Form
viewPill {rad, col, pos} =
  circle rad
    |> filled col
    |> move pos
