module Pill where

import Color exposing (Color)
import Share exposing (defPillCol, defPillRad, defPillVel, hWidth, hHeight)
import Graphics.Collage exposing (Form, circle, filled, move)
import Time exposing (Time)
import Vector exposing (Vector, vAdd, vLen, vMul, vSub)


type alias Pill =
  { pos: Vector
  , vel: Vector
  , rad: Float
  , col: Color
  }


defaultPill : Pill
defaultPill =
  { pos = (0, hHeight)
  , vel = (0, -defPillVel)
  , rad = defPillRad
  , col = defPillCol
  }


newPill : Float -> Color -> Pill
newPill x c =
  { defaultPill
  | pos <- (x, hHeight)
  , col <- c
  }


updatePill : Time -> Pill -> Pill
updatePill t p =
  { p | pos <- vAdd p.pos <| vMul t p.vel }


viewPill : Pill -> Form
viewPill {rad, col, pos} =
  circle rad
    |> filled col
    |> move pos


collision : Pill -> Pill -> Bool
collision p1 p2 =
  (vLen <| vSub p1.pos p2.pos) < (p1.rad + p2.rad)


outOfBounds : Pill -> Bool
outOfBounds p =
  outsideArea p.pos


outsideArea : (Float, Float) -> Bool
outsideArea (x, y) =
  x < -hWidth || x > hWidth || y < -hHeight || y > hHeight
