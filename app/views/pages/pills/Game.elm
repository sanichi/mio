module Game where

import Graphics.Collage exposing (Form, move, scale, toForm)
import Graphics.Element exposing (centered)
import Pill exposing (Pill, defaultPill, newPill, updatePill, collision, outOfBounds, outsideArea)
import Player exposing (Player, defaultPlayer, updatePlayer)
import Random exposing (Seed, initialSeed, generate, float)
import Share exposing (capturePillProb, capturePillCol, defPillCol, defPillRad, hWidth, hHeight, lineHeight, textCol)
import Text exposing(fromString)
import Time exposing (Time)

type State = Init | Play | Over

type Event = Tick (Time, (Int, Int)) | Add | Click

type alias Game =
  { maxScore : Int
  , player : Pill
  , pills : List Pill
  , seed : Seed
  , score : Int
  , state : State
  }


defaultGame : Game
defaultGame =
  { maxScore = 0
  , player = defaultPlayer
  , pills = []
  , seed = initialSeed 12345
  , score = 0
  , state = Init
  }


updatePlay : Event -> Game -> Game
updatePlay event g =
  case event of
    Tick (t, ((i,j) as mp)) ->
      let
        unculled = List.filter (not << outOfBounds) g.pills
        untouched = List.filter (not << collision g.player) unculled
        hit c = List.filter (\p -> p.col == c && (collision g.player p)) unculled
        captured = hit capturePillCol
        collided = hit defPillCol
        outside = outsideArea (toFloat i, toFloat j)
      in
        if List.isEmpty collided && not outside
          then
            { g
            | pills  <- List.map (updatePill t) untouched
            , player <- updatePlayer mp g.player
            , score <- g.score + (List.length captured)
            }
          else
            { defaultGame
            | maxScore <- max g.maxScore g.score
            , player <- defaultPlayer
            , score <- g.score
            , seed <- g.seed
            , state <- Over
            }
    Add ->
      let
        (x, seed') = generate (float (defPillRad - hWidth) (hWidth - defPillRad)) g.seed
        (p, seed'') = generate (float 0 1) seed'
        c = if p < capturePillProb then capturePillCol else defPillCol
      in
        { g
        | pills <- (newPill x c) :: g.pills
        , seed <- seed''
        }
    Click ->
      g


click : Event -> Bool
click event =
  case event of
    Click -> True
    _     -> False


updateGame : Event -> Game -> Game
updateGame event g =
  case g.state of
    Play -> updatePlay event g
    _ ->
      if click event
        then
          { defaultGame
          | seed <- g.seed
          , maxScore <- g.maxScore
          , state <- Play
          }
        else g


viewGameTexts : Game -> List Form
viewGameTexts g =
  case g.state of
    Init ->
      [ textForm  2 3.0 "Blue PiLL"
      , textForm  1 2.0 "Collect blue pills"
      , textForm  0 2.0 "Avoid red pills"
      , textForm -1 2.0 "Stay inside the square"
      , textForm -2 1.5 "Click to start"
      ]
    Over ->
      [ textForm  2 3.0 "Game Over"
      , textForm  1 2.0 ("Score: " ++ (toString g.score))
      , textForm  0 2.0 ("Best score: " ++ (toString g.maxScore))
      , textForm -1 1.5 "Click to restart"
      ]
    Play -> [textForm 0 3.0 (toString g.score)]

textForm : Int -> Float -> String -> Form
textForm lineNo textScale str =
  str
    |> fromString
    |> Text.color textCol
    |> centered
    |> toForm
    |> scale textScale
    |> move (0, (toFloat lineNo) * lineHeight)
