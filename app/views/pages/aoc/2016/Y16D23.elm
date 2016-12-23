module Y16D23 exposing (answer)

import Array exposing (Array)
import Dict exposing (Dict)
import Regex


answer : Int -> String -> String
answer part input =
    let
        state =
            input
                |> parse
                |> initState
    in
        if part == 1 then
            state
                |> process
                |> get "a"
                |> toString
        else
            { state | registers = set "a" state 12 }
                |> process
                |> get "a"
                |> toString


process : State -> State
process state =
    if state.index < 0 || state.index >= Array.length state.instructions then
        state
    else
        let
            instruction =
                state.instructions
                    |> Array.get state.index
                    |> Maybe.withDefault Invalid

            index =
                let
                    ( test, shift ) =
                        case instruction of
                            JnzRR reg1 reg2 ->
                                ( get reg1 state, get reg2 state )

                            JnzRI reg jmp ->
                                ( get reg state, jmp )

                            JnzIR int reg ->
                                ( int, get reg state )

                            JnzII int jmp ->
                                ( int, jmp )

                            _ ->
                                ( 0, 0 )
                in
                    if test == 0 || shift == 0 then
                        state.index + 1
                    else
                        state.index + shift

            instructions =
                let
                    indexToToggle =
                        case instruction of
                            TglI jmp ->
                                state.index + jmp

                            TglR reg ->
                                state.index + get reg state

                            _ ->
                                Array.length state.instructions

                    instructionToToggle =
                        state.instructions
                            |> Array.get indexToToggle
                            |> Maybe.withDefault Invalid
                in
                    if instructionToToggle == Invalid then
                        state.instructions
                    else
                        let
                            toggledInstruction =
                                toggle instructionToToggle
                        in
                            Array.set indexToToggle toggledInstruction state.instructions

            registers =
                case instruction of
                    CpyI val reg ->
                        set reg state val

                    CpyR source target ->
                        get source state
                            |> set target state

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
        in
            State index instructions registers
                |> process


get : String -> State -> Int
get reg state =
    state.registers
        |> Dict.get reg
        |> Maybe.withDefault 0


set : String -> State -> Int -> Dict String Int
set reg state val =
    state.registers
        |> Dict.insert reg val


toggle : Instruction -> Instruction
toggle instruction =
    case instruction of
        CpyI int reg ->
            JnzIR int reg

        CpyR reg1 reg2 ->
            JnzRR reg1 reg2

        Dec reg ->
            Inc reg

        Inc reg ->
            Dec reg

        JnzII int1 int2 ->
            Invalid

        JnzRI reg int ->
            Invalid

        JnzIR int reg ->
            CpyI int reg

        JnzRR reg1 reg2 ->
            CpyR reg1 reg2

        TglI int ->
            Invalid

        TglR reg ->
            Inc reg

        Invalid ->
            Invalid


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
    | JnzII Int Int
    | JnzRI String Int
    | JnzIR Int String
    | JnzRR String String
    | TglI Int
    | TglR String
    | Invalid


initState : Array Instruction -> State
initState instructions =
    { index = 0
    , instructions = instructions
    , registers = Dict.fromList [ ( "a", 7 ), ( "b", 0 ), ( "c", 0 ), ( "d", 0 ) ]
    }


parse : String -> Array Instruction
parse input =
    input
        |> Regex.find Regex.All (Regex.regex "(cpy) ([abcd]|-?\\d+) ([abcd])|(inc) ([abcd])|(dec) ([abcd])|(jnz) ([abcd]|-?\\d+) ([abcd]|-?\\d+)|(tgl) ([abcd]|-?\\d+)")
        |> List.map .submatches
        |> List.map (List.map (Maybe.withDefault ""))
        |> List.map (List.filter (\m -> m /= ""))
        |> List.map toInstruction
        |> Array.fromList


toInstruction : List String -> Instruction
toInstruction matches =
    case matches of
        [ "cpy", numOrReg, reg ] ->
            case String.toInt numOrReg of
                Ok num ->
                    CpyI num reg

                Err _ ->
                    CpyR numOrReg reg

        [ "inc", reg ] ->
            Inc reg

        [ "dec", reg ] ->
            Dec reg

        [ "jnz", numOrReg1, numOrReg2 ] ->
            let
                maybeNum1 =
                    numOrReg1
                        |> String.toInt

                maybeNum2 =
                    numOrReg2
                        |> String.toInt
            in
                case ( maybeNum1, maybeNum2 ) of
                    ( Ok num1, Ok num2 ) ->
                        JnzII num1 num2

                    ( Ok num1, Err _ ) ->
                        JnzIR num1 numOrReg2

                    ( Err _, Ok num2 ) ->
                        JnzRI numOrReg1 num2

                    ( Err _, Err _ ) ->
                        JnzRR numOrReg1 numOrReg2

        [ "tgl", numOrReg ] ->
            case String.toInt numOrReg of
                Ok num ->
                    TglI num

                Err _ ->
                    TglR numOrReg

        _ ->
            Invalid
