module Y15D19 exposing (answer)

import Regex exposing (Match, Regex, find)
import Set exposing (Set)
import Util exposing (regex)


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> molecules

    else
        input
            |> parse
            |> askalski


type alias Model =
    { rules : List Rule
    , molecule : String
    , replacements : Set String
    }


type alias Rule =
    ( String, String )


molecules : Model -> String
molecules model =
    let
        model_ =
            iterateRules model
    in
    Set.size model_.replacements |> String.fromInt


askalski : Model -> String
askalski model =
    let
        atoms =
            count atomRgx model

        bracs =
            count bracRgx model

        comas =
            count comaRgx model
    in
    atoms - bracs - 2 * comas - 1 |> String.fromInt


parse : String -> Model
parse input =
    let
        rules =
            find ruleRgx input
                |> List.map .submatches
                |> List.map extractRule

        molecule =
            find moleRgx input
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
        [ Just from, Just to ] ->
            ( from, to )

        _ ->
            ( "", "" )


extractMolecule : Maybe (List (Maybe String)) -> String
extractMolecule submatches =
    case submatches of
        Nothing ->
            ""

        Just list ->
            case list of
                [ Just m ] ->
                    m

                _ ->
                    ""


iterateRules : Model -> Model
iterateRules model =
    case model.rules of
        [] ->
            model

        rule :: rules ->
            let
                from =
                    Tuple.first rule

                to =
                    Tuple.second rule

                matches =
                    find (regex from) model.molecule

                replacements_ =
                    addToReplacements matches from to model.molecule model.replacements

                model_ =
                    { rules = rules
                    , molecule = model.molecule
                    , replacements = replacements_
                    }
            in
            iterateRules model_


addToReplacements : List Match -> String -> String -> String -> Set String -> Set String
addToReplacements matches from to molecule replacements =
    case matches of
        [] ->
            replacements

        match :: rest ->
            let
                left =
                    String.slice 0 match.index molecule

                right =
                    String.slice (match.index + String.length from) -1 molecule

                replacement =
                    left ++ to ++ right

                replacements_ =
                    Set.insert replacement replacements
            in
            addToReplacements rest from to molecule replacements_


count : Regex -> Model -> Int
count rgx model =
    find rgx model.molecule |> List.length


ruleRgx : Regex
ruleRgx =
    regex "(e|[A-Z][a-z]?) => ((?:[A-Z][a-z]?)+)"


moleRgx : Regex
moleRgx =
    regex "((?:[A-Z][a-z]?){10,})"


atomRgx : Regex
atomRgx =
    regex "[A-Z][a-z]?"


bracRgx : Regex
bracRgx =
    regex "(Ar|Rn)"


comaRgx : Regex
comaRgx =
    regex "Y"
