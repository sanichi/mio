module Y15D06 exposing (answers)

import Array exposing (Array)
import Regex
import Tuple exposing (first, second)
import Util exposing (join)


answers : String -> String
answers input =
    let
        instructions =
            parse input

        model =
            process instructions initModel

        p1 =
            first model
                |> Array.toList
                |> List.filter (\l -> l == 1)
                |> List.length
                |> toString

        p2 =
            second model
                |> Array.toList
                |> List.sum
                |> toString
    in
        join p1 p2


parse : String -> List Instruction
parse input =
    let
        rgx =
            Regex.regex "(toggle|turn (?:on|off)) (\\d+),(\\d+) through (\\d+),(\\d+)"
    in
        Regex.find Regex.All rgx input
            |> List.map .submatches
            |> List.map parseInstruction
            |> List.filter (\i -> i /= badInstruction)


process : List Instruction -> Model -> Model
process instructions lights =
    case instructions of
        [] ->
            lights

        instruction :: rest ->
            let
                lights_ =
                    updateRow instruction lights
            in
                process rest lights_


updateRow : Instruction -> Model -> Model
updateRow instruction lights =
    let
        lights_ =
            updateCol instruction lights

        fx =
            first instruction.from

        tx =
            first instruction.to
    in
        if fx == tx then
            lights_
        else
            let
                fy =
                    second instruction.from

                ty =
                    second instruction.to

                instruction_ =
                    { instruction
                        | from = ( fx + 1, fy )
                        , to = ( tx, ty )
                    }
            in
                updateRow instruction_ lights_


updateCol : Instruction -> Model -> Model
updateCol instruction lights =
    let
        lights_ =
            updateCell instruction lights

        fy =
            second instruction.from

        ty =
            second instruction.to
    in
        if fy == ty then
            lights_
        else
            let
                fx =
                    first instruction.from

                tx =
                    first instruction.to

                instruction_ =
                    { instruction
                        | from = ( fx, fy + 1 )
                        , to = ( tx, ty )
                    }
            in
                updateCol instruction_ lights_


updateCell : Instruction -> Model -> Model
updateCell instruction lights =
    let
        k =
            index instruction

        l1 =
            first lights

        l2 =
            second lights

        v1 =
            Array.get k l1 |> Maybe.withDefault 0

        v2 =
            Array.get k l2 |> Maybe.withDefault 0

        v1_ =
            case instruction.action of
                Toggle ->
                    if v1 == 1 then
                        0
                    else
                        1

                On ->
                    1

                Off ->
                    0

        v2_ =
            case instruction.action of
                Toggle ->
                    v2 + 2

                On ->
                    v2 + 1

                Off ->
                    if v2 == 0 then
                        0
                    else
                        v2 - 1
    in
        ( Array.set k v1_ l1, Array.set k v2_ l2 )


index : Instruction -> Int
index instruction =
    let
        x =
            first instruction.from

        y =
            second instruction.from
    in
        x + 1000 * y


parseInstruction : List (Maybe String) -> Instruction
parseInstruction submatches =
    case submatches of
        [ Just a__, Just fx__, Just fy__, Just tx__, Just ty__ ] ->
            let
                a_ =
                    case a__ of
                        "toggle" ->
                            Just Toggle

                        "turn on" ->
                            Just On

                        "turn off" ->
                            Just Off

                        _ ->
                            Nothing

                fx_ =
                    String.toInt fx__

                fy_ =
                    String.toInt fy__

                tx_ =
                    String.toInt tx__

                ty_ =
                    String.toInt ty__
            in
                case ( a_, fx_, fy_, tx_, ty_ ) of
                    ( Just a, Ok fx, Ok fy, Ok tx, Ok ty ) ->
                        if fx >= 0 && fy >= 0 && fx <= tx && fy <= ty && tx < 1000 && ty < 1000 then
                            { action = a, from = ( fx, fy ), to = ( tx, ty ) }
                        else
                            badInstruction

                    _ ->
                        badInstruction

        _ ->
            badInstruction


type Action
    = Toggle
    | On
    | Off


type alias Instruction =
    { action : Action
    , from : ( Int, Int )
    , to : ( Int, Int )
    }


badInstruction =
    { action = Toggle
    , from = ( 1, 1 )
    , to = ( 0, 0 )
    }


type alias Model =
    ( Array Int, Array Int )


initModel =
    ( Array.repeat 1000000 0, Array.repeat 1000000 0 )
