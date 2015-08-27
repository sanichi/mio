import Color exposing (lightGray)
import Game exposing (Game, defaultGame, updateGame)
import Share exposing (addSeconds, frameRate, height, width)
import Graphics.Collage exposing (collage)
import Graphics.Element exposing (Element, color, container, middle)
import Player exposing (mouseSignal)
import Pill exposing (Pill, defaultPill, viewPill)
import Signal exposing (..)
import Time exposing (Time, fps, inSeconds, every, second)
import Window


render : (Int, Int) -> Game -> Element
render (w, h) game =
  let
    player = viewPill game.player
    pills = List.map viewPill game.pills
  in
    collage width height (player :: pills)
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
    , map (always Game.Add) (every (second * addSeconds))
    ]


main : Signal Element
main =
  render <~ Window.dimensions ~ foldp updateGame defaultGame events
