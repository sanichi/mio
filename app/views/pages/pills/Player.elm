module Player where

import Color exposing (black)
import Globals exposing (defaultPlayerCol)
import Mouse
import Pill exposing (Pill, defaultPill)
import Signal exposing (..)
import Time exposing (Time)
import Window


type alias Player = Pill


defaultPlayer : Player
defaultPlayer =
  { defaultPill
  | col <- defaultPlayerCol
  , pos <- (0, 0)
  }


updatePlayer : (Int, Int) -> Player -> Player
updatePlayer (x, y) p =
  { p | pos <- (toFloat x, toFloat y) }


relative : (Int, Int) -> (Int, Int) -> (Int, Int)
relative (ox, oy) (x, y) =
  (x - ox, oy - y)


center : (Int, Int) -> (Int, Int)
center (w, h) =
  (w // 2, h // 2)


mouseSignal : Signal Time -> Signal (Int, Int)
mouseSignal delta =
  sampleOn delta (relative <~ (map center Window.dimensions) ~ Mouse.position)
