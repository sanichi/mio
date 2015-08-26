module Game where

import Globals exposing (hHeight)
import Pill exposing (Pill, defaultPill, updatePill, collision)
import Player exposing (Player, defaultPlayer, updatePlayer)
import Time exposing (Time)

type alias Game =
  { player : Pill
  , pills : List Pill
  }


defaultGame : Game
defaultGame =
  { player = defaultPlayer
  , pills = List.map (\i -> { defaultPill | pos <- (i * 50, hHeight) }) [0..3]
  }


updateGame : (Time, (Int, Int)) -> Game -> Game
updateGame (t, mp) ({player, pills} as game) =
  let
    untouched = List.filter (not << collision player) pills
  in
    { game
    | pills  <- List.map (updatePill t) untouched
    , player <- updatePlayer mp player
    }
