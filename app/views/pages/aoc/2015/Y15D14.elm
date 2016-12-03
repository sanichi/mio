module Y15D14 exposing (answers)

import Regex
import Util exposing (join)


answers : String -> String
answers input =
    let
        model =
            parseInput input

        time =
            2503

        p1 =
            maxDistance time model

        p2 =
            bestScore time model
    in
        join p1 p2


maxDistance : Int -> Model -> String
maxDistance time model =
    List.map (distance time) model
        |> List.maximum
        |> Maybe.withDefault 0
        |> toString


bestScore : Int -> Model -> String
bestScore time model =
    score 0 time model
        |> List.map .score
        |> List.maximum
        |> Maybe.withDefault 0
        |> toString


distance : Int -> Reindeer -> Int
distance t r =
    let
        cyc =
            r.time + r.rest

        tmp =
            rem t cyc

        rdr =
            if tmp > r.time then
                r.time
            else
                tmp
    in
        ((t // cyc) * r.time + rdr) * r.speed


score : Int -> Int -> Model -> Model
score t time model =
    if t >= time then
        model
    else
        let
            t_ =
                t + 1

            model1 =
                List.map (\r -> { r | km = distance t_ r }) model

            maxDst =
                List.map .km model1 |> List.maximum |> Maybe.withDefault 0

            model2 =
                List.map
                    (\r ->
                        { r
                            | score =
                                r.score
                                    + (if r.km == maxDst then
                                        1
                                       else
                                        0
                                      )
                        }
                    )
                    model1
        in
            score t_ time model2


parseInput : String -> Model
parseInput input =
    String.split "\n" input
        |> List.filter (\l -> l /= "")
        |> List.foldl parseLine []


parseLine : String -> Model -> Model
parseLine line model =
    let
        matches =
            Regex.find (Regex.AtMost 1) (Regex.regex "^(\\w+) can fly (\\d+) km/s for (\\d+) seconds, but then must rest for (\\d+) seconds\\.$") line |> List.map .submatches
    in
        case matches of
            [ [ Just n1, Just s1, Just t1, Just r1 ] ] ->
                let
                    s2 =
                        String.toInt s1 |> Result.withDefault 0

                    t2 =
                        String.toInt t1 |> Result.withDefault 0

                    r2 =
                        String.toInt r1 |> Result.withDefault 0

                    reindeer =
                        { name = n1, speed = s2, time = t2, rest = r2, km = 0, score = 0 }
                in
                    reindeer :: model

            _ ->
                model


type alias Model =
    List Reindeer


type alias Reindeer =
    { name : String
    , speed : Int
    , time : Int
    , rest : Int
    , km : Int
    , score : Int
    }
