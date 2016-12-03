module Y15D23 exposing (answers)

import Array exposing (Array)
import Dict exposing (Dict)
import Regex
import Util exposing (join)


answers : String -> String
answers input =
    let
        model1 =
            parseInput input

        model2 =
            { model1 | registers = Dict.insert "a" 1 model1.registers }

        p1 =
            run model1 |> get "b" |> toString

        p2 =
            run model2 |> get "b" |> toString
    in
        join p1 p2


run : Model -> Model
run model =
    let
        instruction =
            Array.get model.i model.instructions
    in
        case instruction of
            Nothing ->
                model

            Just inst ->
                let
                    model_ =
                        case inst of
                            Inc r ->
                                { model
                                    | registers = update r (\v -> v + 1) model
                                    , i = model.i + 1
                                }

                            Hlf r ->
                                { model
                                    | registers = update r (\v -> v // 2) model
                                    , i = model.i + 1
                                }

                            Tpl r ->
                                { model
                                    | registers = update r (\v -> v * 3) model
                                    , i = model.i + 1
                                }

                            Jmp j ->
                                { model
                                    | i = model.i + j
                                }

                            Jie r j ->
                                { model
                                    | i =
                                        model.i
                                            + if rem (get r model) 2 == 0 then
                                                j
                                              else
                                                1
                                }

                            Jio r j ->
                                { model
                                    | i =
                                        model.i
                                            + if (get r model) == 1 then
                                                j
                                              else
                                                1
                                }

                            NoOp ->
                                { model
                                    | i = model.i + 1
                                }
                in
                    run model_


update : String -> (Int -> Int) -> Model -> Dict String Int
update name f model =
    let
        value =
            get name model |> f
    in
        Dict.insert name value model.registers


get : String -> Model -> Int
get reg model =
    Dict.get reg model.registers |> Maybe.withDefault 0


parseInput : String -> Model
parseInput input =
    String.split "\n" input
        |> List.filter (\l -> l /= "")
        |> List.foldl parseLine initModel


parseLine : String -> Model -> Model
parseLine line model =
    let
        rx =
            "^([a-z]{3})\\s+(a|b)?,?\\s*\\+?(-?\\d*)?"

        sm =
            Regex.find (Regex.AtMost 1) (Regex.regex rx) line |> List.map .submatches
    in
        case sm of
            [ [ name, reg, jmp ] ] ->
                let
                    n =
                        Maybe.withDefault "" name

                    r =
                        Maybe.withDefault "" reg

                    j =
                        Maybe.withDefault "" jmp |> String.toInt |> Result.withDefault 0

                    i =
                        case n of
                            "inc" ->
                                Inc r

                            "hlf" ->
                                Hlf r

                            "tpl" ->
                                Tpl r

                            "jmp" ->
                                Jmp j

                            "jie" ->
                                Jie r j

                            "jio" ->
                                Jio r j

                            _ ->
                                NoOp
                in
                    { model | instructions = Array.push i model.instructions }

            _ ->
                model


initModel : Model
initModel =
    { instructions = Array.empty
    , registers = Dict.empty
    , i = 0
    }


type alias Model =
    { instructions : Array Instruction
    , registers : Dict String Int
    , i : Int
    }


type Instruction
    = NoOp
    | Inc String
    | Hlf String
    | Tpl String
    | Jmp Int
    | Jie String Int
    | Jio String Int
