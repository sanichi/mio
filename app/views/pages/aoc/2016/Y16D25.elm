module Y16D25 exposing (answer)

import Array exposing (Array)
import Dict exposing (Dict)
import Regex


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> Array.length
            |> toString
    else
        input
            |> parse
            |> Array.get 0
            |> toString


process : State -> State
process state =
    if state.index < 0 || state.index >= Array.length state.instructions then
        state
    else
        let
            maybeMultiplication =
                multiply state
        in
            case maybeMultiplication of
                Just newState ->
                    process newState

                _ ->
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
                        State index state.instructions registers
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


multiply : State -> Maybe State
multiply state =
    let
        getInstruction i =
            state.instructions
                |> Array.get (state.index + i)
                |> Maybe.withDefault Invalid

        possibleMultiplication =
            List.map getInstruction [ 0, 1, 2, 3, 4, 5, 6, 7 ]
    in
        case possibleMultiplication of
            [ CpyR ra rd, CpyI 0 ra2, CpyR rb rc, Inc ra3, Dec rc2, JnzRI rc3 -2, Dec rd2, JnzRI rd3 -5 ] ->
                if ra == ra2 && ra == ra3 && rc == rc2 && rc == rc3 && rd == rd2 && rd == rd3 then
                    let
                        va =
                            get ra state

                        vb =
                            get rb state

                        registers =
                            state.registers
                                |> Dict.insert ra (va * vb)
                                |> Dict.insert rc 0
                                |> Dict.insert rd 0

                        index =
                            state.index + 8
                    in
                        Just { state | index = index, registers = registers }
                else
                    Nothing

            _ ->
                Nothing


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
    | OutI Int
    | OutR String
    | Invalid


initState : Int -> Array Instruction -> State
initState a instructions =
    { index = 0
    , instructions = instructions
    , registers = Dict.fromList [ ( "a", a ), ( "b", 0 ), ( "c", 0 ), ( "d", 0 ) ]
    }


parse : String -> Array Instruction
parse input =
    input
        |> Regex.find Regex.All (Regex.regex "(cpy) ([abcd]|-?\\d+) ([abcd])|(inc) ([abcd])|(dec) ([abcd])|(jnz) ([abcd]|-?\\d+) ([abcd]|-?\\d+)|(out) ([abcd]|-?\\d+)")
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

        [ "out", numOrReg ] ->
            case String.toInt numOrReg of
                Ok num ->
                    OutI num

                Err _ ->
                    OutR numOrReg

        _ ->
            Invalid
