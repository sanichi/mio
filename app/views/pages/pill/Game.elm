module Game where

import Pill exposing (Pill, defaultPill, updatePill)
import Player exposing (Player, defaultPlayer, updatePlayer)
import Time exposing (Time)

type alias Game =
  { player : Pill
  , pill : Pill
  }


defaultGame : Game
defaultGame =
  { player = defaultPlayer
  , pill = defaultPill
  }


updateGame : (Time, (Int, Int)) -> Game -> Game
updateGame (t, mp) game =
  { game
  | pill <- updatePill t game.pill
  , player <- updatePlayer mp game.player
  }
