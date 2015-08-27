module Game where

import Share exposing (capturePillProb, capturePillCol, defPillCol, defPillRad, hWidth, hHeight)
import Pill exposing (Pill, defaultPill, newPill, updatePill, collision, outOfBounds)
import Player exposing (Player, defaultPlayer, updatePlayer)
import Random exposing (Seed, initialSeed, generate, float)
import Time exposing (Time)

type alias Game =
  { player : Pill
  , pills : List Pill
  , seed : Seed
  }


defaultGame : Game
defaultGame =
  { player = defaultPlayer
  , pills = []
  , seed = initialSeed 12345
  }


type Event = Tick (Time, (Int, Int)) | Add


updateGame : Event -> Game -> Game
updateGame event ({player, pills} as game) =
  case event of
    Tick (t, mp) ->
      let
        unculled = List.filter (not << outOfBounds) pills
        untouched = List.filter (not << collision player) unculled
      in
        { game
        | pills  <- List.map (updatePill t) untouched
        , player <- updatePlayer mp player
        }
    Add ->
      let
        (x, seed') = generate (float (defPillRad - hWidth) (hWidth - defPillRad)) game.seed
        (p, seed'') = generate (float 0 1) seed'
        c = if p < capturePillProb then capturePillCol else defPillCol
      in
        { game
        | pills <- (newPill x c) :: game.pills
        , seed <- seed''
        }
