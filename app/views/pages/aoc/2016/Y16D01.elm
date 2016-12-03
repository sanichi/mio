module Y16D01 exposing (answers)

import Regex
import Util


answers : String -> String
answers input =
    let
        steps =
            parse input

        a1 =
            updates steps init |> blocks

        a2 =
            revisits steps [] init |> blocks
    in
        Util.join (toString a1) (toString a2)


type Rotation
    = Left
    | Right
    | None


type Direction
    = North
    | East
    | South
    | West


type alias Step =
    { r : Rotation
    , n : Int
    }


type alias Position =
    { x : Int
    , y : Int
    }


origin : Position
origin =
    { x = 0
    , y = 0
    }


type alias Model =
    { d : Direction
    , p : Position
    }


init : Model
init =
    { d = North
    , p = origin
    }


update : Step -> Model -> Model
update step model =
    let
        d =
            model.d

        p =
            model.p
    in
        case step.r of
            Right ->
                case d of
                    North ->
                        { d = East
                        , p = { p | x = p.x + step.n }
                        }

                    East ->
                        { d = South
                        , p = { p | y = p.y - step.n }
                        }

                    South ->
                        { d = West
                        , p = { p | x = p.x - step.n }
                        }

                    West ->
                        { d = North
                        , p = { p | y = p.y + step.n }
                        }

            Left ->
                case model.d of
                    North ->
                        { d = West
                        , p = { p | x = p.x - step.n }
                        }

                    East ->
                        { d = North
                        , p = { p | y = p.y + step.n }
                        }

                    South ->
                        { d = East
                        , p = { p | x = p.x + step.n }
                        }

                    West ->
                        { d = South
                        , p = { p | y = p.y - step.n }
                        }

            None ->
                case model.d of
                    North ->
                        { d = North
                        , p = { p | y = p.y + step.n }
                        }

                    East ->
                        { d = East
                        , p = { p | x = p.x + step.n }
                        }

                    South ->
                        { d = South
                        , p = { p | y = p.y - step.n }
                        }

                    West ->
                        { d = West
                        , p = { p | x = p.x - step.n }
                        }


updates : List Step -> Model -> Model
updates steps model =
    case steps of
        step :: rest ->
            update step model |> updates rest

        [] ->
            model


revisits : List Step -> List Position -> Model -> Model
revisits steps visits model =
    case steps of
        step :: rest ->
            let
                newModel =
                    update { step | n = 1 } model
            in
                if List.member newModel.p visits then
                    newModel
                else
                    let
                        newVisits =
                            newModel.p :: visits
                    in
                        if step.n <= 1 then
                            revisits rest newVisits newModel
                        else
                            revisits ({ step | r = None, n = step.n - 1 } :: rest) newVisits newModel

        [] ->
            model


blocks : Model -> Int
blocks model =
    abs model.p.x + abs model.p.y


parse : String -> List Step
parse input =
    Regex.find (Regex.All) (Regex.regex "([RL])([1-9][0-9]*)") input
        |> List.map .submatches
        |> List.map
            (\m ->
                case m of
                    [ Just r_, Just n_ ] ->
                        let
                            r =
                                if r_ == "R" then
                                    Right
                                else
                                    Left

                            n =
                                String.toInt n_ |> Result.toMaybe |> Maybe.withDefault 1
                        in
                            { r = r, n = n }

                    _ ->
                        { r = Right, n = 1 }
            )
