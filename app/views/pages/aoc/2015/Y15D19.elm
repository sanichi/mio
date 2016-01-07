module Y15D19 where

import Regex exposing (Regex, HowMany(All), regex, find)
import String


part1 : String -> String
part1 input =
  prepare input molecules


part2 : String -> String
part2 input =
  prepare input askalski


type alias Model =
  { rules    : List Rule
  , molecule : String
  }


type alias Rule =
  (String, String)


prepare : String -> (Model -> String) -> String
prepare input analyser =
  let
    model = parse input
  in
    analyser model


molecules : Model -> String
molecules model =
  "PART 1"


askalski : Model -> String
askalski model =
  let
    atoms = count atomRgx model
    bracs = count bracRgx model
    comas = count comaRgx model
  in
    atoms - bracs - 2 * comas - 1 |> toString


parse : String -> Model
parse input =
  let
    rules =
      find All ruleRgx input
        |> List.map .submatches
        |> List.map extractRule
    molecule =
      find All moleRgx input
        |> List.map .submatches
        |> List.head
        |> extractMolecule
  in
    { rules = rules
    , molecule = molecule
    }


extractRule : List (Maybe String) -> Rule
extractRule submatches =
  case submatches of
    [ Just from, Just to ] -> (from, to)
    _                      -> ("", "")


extractMolecule : Maybe (List (Maybe String)) -> String
extractMolecule submatches =
  case submatches of
    Nothing -> ""
    Just list ->
      case list of
        [ Just m ] -> m
        _ -> ""

count : Regex -> Model -> Int
count rgx model =
  find All rgx model.molecule |> List.length


ruleRgx = regex "(e|[A-Z][a-z]?) => ((?:[A-Z][a-z]?)+)"
moleRgx = regex "((?:[A-Z][a-z]?){10,})"
atomRgx = regex "[A-Z][a-z]?"
bracRgx = regex "(Ar|Rn)"
comaRgx = regex "Y"
