module Y15D03 where

import Array exposing (Array)
import Dict exposing (Dict)
import String


part1 : String -> String
part1 input =
  christmas 1 input


part2 : String -> String
part2 input =
  christmas 2 input


christmas : Int -> String -> String
christmas n input =
  let
    model = deliver (initModel n) input
  in
    case model.err of
      Just err ->
        err
      Nothing ->
        Dict.keys model.visited |> List.length |> toString


type alias Santa =
  { stop : Bool
  , x : Int
  , y : Int
  , err : Maybe String
  }


initSanta : Santa
initSanta =
  { stop = False
  , x = 0
  , y = 0
  , err = Nothing
  }


errorSanta : String -> Santa
errorSanta err =
  { stop = True
  , x = 0
  , y = 0
  , err = Just err
  }


type alias Visited =
  Dict String Bool


type alias Model =
  { visited : Visited
  , santas : Array Santa
  , turn : Int
  , err : Maybe String
  }


initModel : Int -> Model
initModel n =
  { visited = visit 0 0 Dict.empty
  , santas = Array.repeat n initSanta
  , turn = 0
  , err = Nothing
  }


deliver : Model -> String -> Model
deliver model instructions =
  if String.isEmpty instructions
    then model
    else
      let
        next = String.uncons instructions
        (char, remaining) = case next of
          Just (c, r) -> (c, r)
          _ -> ('*', "")
        index = model.turn `rem` (Array.length model.santas)
        santa = Array.get index model.santas |> Maybe.withDefault (errorSanta ("illegal index [" ++ (toString index) ++ "]"))
        santa' = updateSanta char santa
      in
        if santa'.stop
          then { model | err = santa.err }
          else
            let
              model' =
                { model
                | visited = visit santa'.x santa'.y model.visited
                , turn = model.turn + 1
                , santas = Array.set index santa' model.santas
                }
            in
              deliver model' remaining


updateSanta : Char -> Santa -> Santa
updateSanta char santa =
  case char of
    '>'  -> { santa | x = santa.x + 1 }
    '<'  -> { santa | x = santa.x - 1 }
    '^'  -> { santa | y = santa.y + 1 }
    'v'  -> { santa | y = santa.y - 1 }
    '\n' -> { santa | stop = True }
    _    -> errorSanta ("illegal instruction [" ++ (toString char) ++ "]")


visit : Int -> Int -> Visited -> Visited
visit x y visited =
  let
    key = (toString x) ++ "|" ++ (toString y)
  in
    Dict.insert key True visited
