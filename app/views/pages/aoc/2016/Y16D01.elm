module Y16D01 exposing (answers)

import Regex
import Util


answers : String -> String
answers input =
    let
        steps =
            parse input

        a1 =
            updates steps init |> blocks |> toString

        a2 =
            revisits steps [] init |> blocks |> toString
    in
        Util.join a1 a2


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
    Position 0 0


type alias Model =
    { d : Direction
    , p : Position
    }


init : Model
init =
    Model North origin


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
                        Model East { p | x = p.x + step.n }

                    East ->
                        Model South { p | y = p.y - step.n }

                    South ->
                        Model West { p | x = p.x - step.n }

                    West ->
                        Model North { p | y = p.y + step.n }

            Left ->
                case model.d of
                    North ->
                        Model West { p | x = p.x - step.n }

                    East ->
                        Model North { p | y = p.y + step.n }

                    South ->
                        Model East { p | x = p.x + step.n }

                    West ->
                        Model South { p | y = p.y - step.n }

            None ->
                case model.d of
                    North ->
                        Model North { p | y = p.y + step.n }

                    East ->
                        Model East { p | x = p.x + step.n }

                    South ->
                        Model South { p | y = p.y - step.n }

                    West ->
                        Model West { p | x = p.x - step.n }


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
                            revisits (Step None (step.n - 1) :: rest) newVisits newModel

        [] ->
            model


blocks : Model -> Int
blocks model =
    abs model.p.x + abs model.p.y


parse : String -> List Step
parse input =
    Regex.find Regex.All (Regex.regex "([RL])([1-9][0-9]*)") input
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
                                String.toInt n_ |> Result.withDefault 1
                        in
                            Step r n

                    _ ->
                        Step Right 1
            )
