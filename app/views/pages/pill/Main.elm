import Color exposing (lightGray)
import Game exposing (Game, defaultGame, updateGame)
import Graphics.Collage exposing (collage)
import Graphics.Element exposing (Element, color, container, middle)
import Player exposing (mouseSignal)
import Pill exposing (Pill, viewPill)
import Signal exposing (..)
import Time exposing (Time, fps, inSeconds)
import Window


render : (Int, Int) -> Game -> Element
render (w, h) game =
  let
    player = viewPill game.player
    pill = viewPill game.pill
  in
    collage 400 400 [ player, pill ]
      |> color lightGray
      |> container w h middle


delta : Signal Time
delta = fps 30


input : Signal (Time, (Int, Int))
input =
  (,) <~ map inSeconds delta ~ mouseSignal delta


main : Signal Element
main =
  render <~ Window.dimensions ~ foldp updateGame defaultGame input
