module Y15D23 exposing (answer)

import Array exposing (Array)
import Dict exposing (Dict)
import Regex exposing (findAtMost)
import Util exposing (regex)


answer : Int -> String -> String
answer part input =
    let
        init =
            parse input

        model =
            if part == 1 then
                init

            else
                { init | registers = Dict.insert "a" 1 init.registers }
    in
    run model |> get "b" |> String.fromInt


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
                                        + (if remainderBy 2 (get r model) == 0 then
                                            j

                                           else
                                            1
                                          )
                            }

                        Jio r j ->
                            { model
                                | i =
                                    model.i
                                        + (if get r model == 1 then
                                            j

                                           else
                                            1
                                          )
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


parse : String -> Model
parse input =
    String.split "\n" input
        |> List.filter (\l -> l /= "")
        |> List.foldl parseLine initModel


parseLine : String -> Model -> Model
parseLine line model =
    let
        rx =
            regex "^([a-z]{3})\\s+(a|b)?,?\\s*\\+?(-?\\d*)?"

        sm =
            findAtMost 1 rx line |> List.map .submatches
    in
    case sm of
        [ [ name, reg, jmp ] ] ->
            let
                n =
                    Maybe.withDefault "" name

                r =
                    Maybe.withDefault "" reg

                j =
                    Maybe.withDefault "" jmp |> String.toInt |> Maybe.withDefault 0

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
