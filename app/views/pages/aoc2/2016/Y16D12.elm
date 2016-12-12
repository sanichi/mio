module Y16D12 exposing (answers)

import Array exposing (Array)
import Dict exposing (Dict)
import Regex
import Util


answers : String -> String
answers input =
    let
        state =
            input
                |> parse
                |> initState

        a1 =
            state
                |> process
                |> get "a"
                |> toString

        a2 =
            { state | registers = set "c" state 1 }
                |> process
                |> get "a"
                |> toString
    in
        Util.join a1 a2


process : State -> State
process state =
    let
        maybeInstruction =
            Array.get state.index state.instructions
    in
        case maybeInstruction of
            Nothing ->
                state

            Just instruction ->
                if instruction == Invalid then
                    state
                else
                    let
                        registers =
                            case instruction of
                                Cpn val reg ->
                                    set reg state val

                                Cpr from to ->
                                    get from state
                                        |> set to state

                                Inc reg ->
                                    get reg state
                                        |> (+) 1
                                        |> set reg state

                                Dec reg ->
                                    get reg state
                                        |> (+) -1
                                        |> set reg state

                                _ ->
                                    state.registers

                        index =
                            let
                                default =
                                    state.index + 1
                            in
                                case instruction of
                                    Jnz reg jmp ->
                                        if get reg state == 0 || jmp == 0 then
                                            default
                                        else
                                            state.index + jmp

                                    Jiz int jmp ->
                                        if int == 0 || jmp == 0 then
                                            default
                                        else
                                            state.index + jmp

                                    _ ->
                                        default
                    in
                        process { state | registers = registers, index = index }


get : String -> State -> Int
get reg state =
    state.registers
        |> Dict.get reg
        |> Maybe.withDefault 0


set : String -> State -> Int -> Dict String Int
set reg state val =
    state.registers
        |> Dict.insert reg val


initState : Array Instruction -> State
initState instructions =
    { index = 0
    , instructions = instructions
    , registers = Dict.fromList [ ( "a", 0 ), ( "b", 0 ), ( "c", 0 ), ( "d", 0 ) ]
    }


type alias State =
    { index : Int
    , instructions : Array Instruction
    , registers : Dict String Int
    }


type Instruction
    = Cpn Int String
    | Cpr String String
    | Inc String
    | Dec String
    | Jnz String Int
    | Jiz Int Int
    | Invalid


parse : String -> Array Instruction
parse input =
    input
        |> Regex.find Regex.All (Regex.regex "cpy ([abcd]|-?\\d+) ([abcd])|inc ([abcd])|dec ([abcd])|jnz ([abcd]|-?\\d+) (-?\\d+)")
        |> List.map .submatches
        |> List.map parseMatches
        |> Array.fromList


parseMatches : List (Maybe String) -> Instruction
parseMatches matches =
    case matches of
        [ Just numOrReg, Just reg, Nothing, Nothing, Nothing, Nothing ] ->
            case String.toInt numOrReg of
                Ok num ->
                    Cpn num reg

                Err _ ->
                    Cpr numOrReg reg

        [ Nothing, Nothing, Just reg, Nothing, Nothing, Nothing ] ->
            Inc reg

        [ Nothing, Nothing, Nothing, Just reg, Nothing, Nothing ] ->
            Dec reg

        [ Nothing, Nothing, Nothing, Nothing, Just numOrReg, Just num ] ->
            let
                jmp =
                    num
                        |> String.toInt
                        |> Result.withDefault 0
            in
                case String.toInt numOrReg of
                    Ok num ->
                        Jiz num jmp

                    Err _ ->
                        Jnz numOrReg jmp

        _ ->
            Invalid
