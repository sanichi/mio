module Y15D19 where

import Regex exposing (HowMany(All), Match, Regex, find, regex, replace)
import Set exposing (Set)
import String


part1 : String -> String
part1 input =
  prepare input molecules


part2 : String -> String
part2 input =
  prepare input askalski


type alias Model =
  { rules        : List Rule
  , molecule     : String
  , replacements : Set String
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
  let
    model' = iterateRules model
  in
    Set.size model'.replacements |> toString


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
    , replacements = Set.empty
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


iterateRules : Model -> Model
iterateRules model =
  case model.rules of
    [] -> model
    rule :: rules ->
      let
        from = fst rule
        to = snd rule
        matches = find All (regex from) model.molecule
        replacements' = addToReplacements matches from to model.molecule model.replacements
        model' =
          { rules = rules
          , molecule = model.molecule
          , replacements = replacements'
          }
      in
        iterateRules model'


addToReplacements : List Match -> String -> String -> String -> Set String -> Set String
addToReplacements matches from to molecule replacements =
  case matches of
    [ ] ->
      replacements
    match :: rest ->
      let
        left = String.slice 0 match.index molecule
        right = String.slice (match.index + String.length from) -1 molecule
        replacement = left ++ to ++ right
        replacements' = Set.insert replacement replacements
      in
        addToReplacements rest from to molecule replacements'


count : Regex -> Model -> Int
count rgx model =
  find All rgx model.molecule |> List.length


ruleRgx = regex "(e|[A-Z][a-z]?) => ((?:[A-Z][a-z]?)+)"
moleRgx = regex "((?:[A-Z][a-z]?){10,})"
atomRgx = regex "[A-Z][a-z]?"
bracRgx = regex "(Ar|Rn)"
comaRgx = regex "Y"
