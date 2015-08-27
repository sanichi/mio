module Pill where

import Color exposing (Color)
import Globals exposing (defaultPillCol, defaultPillRad, defaultPillVel, hWidth, hHeight)
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
  , vel = (0, -defaultPillVel)
  , rad = defaultPillRad
  , col = defaultPillCol
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
