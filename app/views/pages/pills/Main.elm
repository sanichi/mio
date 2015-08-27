import Color exposing (lightGray)
import Game exposing (Game, defaultGame, updateGame, viewGameTexts)
import Graphics.Collage exposing (Form, collage, toForm)
import Graphics.Element exposing (Element, centered, color, container, middle)
import Mouse
import Player exposing (mouseSignal)
import Pill exposing (Pill, defaultPill, viewPill)
import Share exposing (frameRate, height, spawnInterval, width)
import Signal exposing (..)
import Time exposing (Time, fps, inSeconds, every, second)
import Window


render : (Int, Int) -> Game -> Element
render (w, h) g =
  let
    player = viewPill g.player
    pills = List.map viewPill g.pills
    texts = viewGameTexts g
  in
    collage width height ((player :: pills) ++ texts)
      |> color lightGray
      |> container w h middle


delta : Signal Time
delta = fps frameRate


input : Signal (Time, (Int, Int))
input =
  (,) <~ map inSeconds delta ~ mouseSignal delta


events =
  mergeMany
    [ map Game.Tick input
    , map (always Game.Add) (every (second * spawnInterval))
    , map (always Game.Click) Mouse.clicks
    ]


main : Signal Element
main =
  render <~ Window.dimensions ~ foldp updateGame defaultGame events
