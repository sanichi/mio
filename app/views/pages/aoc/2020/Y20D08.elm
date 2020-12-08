module Y20D08 exposing (answer)

import Array exposing (Array)
import Dict exposing (Dict)
import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        console =
            parse input
    in
    if part == 1 then
        console
            |> execute
            |> .acc
            |> String.fromInt

    else
        console
            |> repair 0
            |> String.fromInt


type alias Instruction =
    { op : String
    , arg : Int
    }


type alias Console =
    { i : Int
    , acc : Int
    , mem : Dict Int Bool
    , ops : Array Instruction
    }


type alias Result =
    { ok : Bool
    , acc : Int
    }


execute : Console -> Result
execute c =
    if c.i == Array.length c.ops then
        Result True c.acc

    else if Dict.member c.i c.mem then
        Result False c.acc

    else
        let
            ( op, arg ) =
                case Array.get c.i c.ops of
                    Just inst ->
                        ( inst.op, inst.arg )

                    Nothing ->
                        ( "err", 0 )

            acc =
                case op of
                    "acc" ->
                        c.acc + arg

                    _ ->
                        c.acc

            mem =
                Dict.insert c.i True c.mem

            i =
                case op of
                    "jmp" ->
                        c.i + arg

                    _ ->
                        c.i + 1
        in
        if op == "err" then
            Result False 0

        else
            execute (Console i acc mem c.ops)


repair : Int -> Console -> Int
repair i c =
    if i >= Array.length c.ops then
        0

    else
        let
            ( op, arg ) =
                case Array.get i c.ops of
                    Just inst ->
                        ( inst.op, inst.arg )

                    Nothing ->
                        ( "err", 0 )
        in
        case op of
            "jmp" ->
                let
                    try =
                        execute { c | ops = Array.set i (Instruction "nop" arg) c.ops }
                in
                if try.ok then
                    try.acc

                else
                    repair (i + 1) c

            "nop" ->
                let
                    try =
                        execute { c | ops = Array.set i (Instruction "jmp" arg) c.ops }
                in
                if try.ok then
                    try.acc

                else
                    repair (i + 1) c

            _ ->
                repair (i + 1) c


parse : String -> Console
parse input =
    input
        |> Regex.find (Util.regex "(nop|acc|jmp) ([-+]\\d+)")
        |> List.map .submatches
        |> List.filterMap
            (\m ->
                case m of
                    [ Just op, Just str ] ->
                        let
                            arg =
                                case String.toInt str of
                                    Just num ->
                                        num

                                    _ ->
                                        0
                        in
                        Just (Instruction op arg)

                    _ ->
                        Nothing
            )
        |> Array.fromList
        |> Console 0 0 Dict.empty


example : String
example =
    """
        nop +0
        acc +1
        jmp +4
        acc +3
        jmp -3
        acc -99
        acc +1
        jmp -4
        acc +6
    """
