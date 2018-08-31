module Y16D12 exposing (answer)

import Array exposing (Array)
import Dict exposing (Dict)
import Regex exposing (find)
import Util exposing (regex)


answer : Int -> String -> String
answer part input =
    let
        c =
            if part == 1 then
                0

            else
                1
    in
    input
        |> parse
        |> initState c
        |> process
        |> get "a"
        |> String.fromInt


process : State -> State
process state =
    let
        instruction =
            state.instructions
                |> Array.get state.index
                |> Maybe.withDefault Invalid
    in
    if instruction == Invalid then
        state

    else
        let
            registers =
                case instruction of
                    CpyI int reg ->
                        set reg state int

                    CpyR reg1 reg2 ->
                        get reg1 state
                            |> set reg2 state

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
                    JnzR reg jmp ->
                        if get reg state == 0 || jmp == 0 then
                            default

                        else
                            state.index + jmp

                    JnzI int jmp ->
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


initState : Int -> Array Instruction -> State
initState c instructions =
    { index = 0
    , instructions = instructions
    , registers = Dict.fromList [ ( "a", 0 ), ( "b", 0 ), ( "c", c ), ( "d", 0 ) ]
    }


type alias State =
    { index : Int
    , instructions : Array Instruction
    , registers : Dict String Int
    }


type Instruction
    = CpyI Int String
    | CpyR String String
    | Dec String
    | Inc String
    | JnzI Int Int
    | JnzR String Int
    | Invalid


parse : String -> Array Instruction
parse input =
    input
        |> find (regex "cpy ([abcd]|-?\\d+) ([abcd])|inc ([abcd])|dec ([abcd])|jnz ([abcd]|-?\\d+) (-?\\d+)")
        |> List.map .submatches
        |> List.map parseMatches
        |> Array.fromList


parseMatches : List (Maybe String) -> Instruction
parseMatches matches =
    case matches of
        [ Just numOrReg, Just reg, Nothing, Nothing, Nothing, Nothing ] ->
            case String.toInt numOrReg of
                Just num ->
                    CpyI num reg

                Nothing ->
                    CpyR numOrReg reg

        [ Nothing, Nothing, Just reg, Nothing, Nothing, Nothing ] ->
            Inc reg

        [ Nothing, Nothing, Nothing, Just reg, Nothing, Nothing ] ->
            Dec reg

        [ Nothing, Nothing, Nothing, Nothing, Just numOrReg, Just num ] ->
            let
                jmp =
                    num
                        |> String.toInt
                        |> Maybe.withDefault 0
            in
            case String.toInt numOrReg of
                Just nm ->
                    JnzI nm jmp

                Nothing ->
                    JnzR numOrReg jmp

        _ ->
            Invalid
