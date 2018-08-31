module Y15D07 exposing (answer)

import Bitwise
import Dict exposing (Dict)


answer : Int -> String -> String
answer part input =
    let
        circuit =
            parseInput input
    in
    if part == 1 then
        circuit
            |> reduce "a"
            |> getVal "a"
            |> String.fromInt

    else
        circuit
            |> Dict.insert "b" (NoOp 3176)
            |> reduce "a"
            |> getVal "a"
            |> String.fromInt


reduce : Wire -> Circuit -> Circuit
reduce wire circuit =
    let
        val =
            Dict.get wire circuit
    in
    case val of
        Nothing ->
            Dict.insert wire (NoOp 0) circuit

        Just action ->
            let
                ( k, circuit_, insert ) =
                    case action of
                        NoOp i ->
                            ( i, circuit, False )

                        Pass w ->
                            let
                                ( i, c ) =
                                    reduce1 w circuit
                            in
                            ( i, c, True )

                        And w1 w2 ->
                            let
                                ( i, j, c ) =
                                    reduce2 w1 w2 circuit
                            in
                            ( Bitwise.and i j, c, True )

                        Or w1 w2 ->
                            let
                                ( i, j, c ) =
                                    reduce2 w1 w2 circuit
                            in
                            ( Bitwise.or i j, c, True )

                        Lshift w i ->
                            let
                                ( j, c ) =
                                    reduce1 w circuit

                                l =
                                    Bitwise.shiftLeftBy i j
                            in
                            ( l, c, True )

                        Rshift w i ->
                            let
                                ( j, c ) =
                                    reduce1 w circuit
                            in
                            ( Bitwise.shiftRightBy i j, c, True )

                        Not w ->
                            let
                                ( i, c ) =
                                    reduce1 w circuit

                                j =
                                    Bitwise.complement i

                                l =
                                    if j < 0 then
                                        maxValue + j + 1

                                    else
                                        j
                            in
                            ( l, c, True )
            in
            if insert then
                Dict.insert wire (NoOp k) circuit_

            else
                circuit_


reduce1 : Wire -> Circuit -> ( Int, Circuit )
reduce1 w circuit =
    let
        i =
            String.toInt w
    in
    case i of
        Just j ->
            ( j, circuit )

        _ ->
            let
                circuit_ =
                    reduce w circuit
            in
            ( getVal w circuit_, circuit_ )


reduce2 : Wire -> Wire -> Circuit -> ( Int, Int, Circuit )
reduce2 w1 w2 circuit =
    let
        i1 =
            String.toInt w1

        i2 =
            String.toInt w2
    in
    case ( i1, i2 ) of
        ( Just j1, Just j2 ) ->
            ( j1, j2, circuit )

        ( Just j1, Nothing ) ->
            let
                circuit_ =
                    reduce w2 circuit
            in
            ( j1, getVal w2 circuit_, circuit_ )

        ( Nothing, Just j2 ) ->
            let
                circuit_ =
                    reduce w1 circuit
            in
            ( getVal w1 circuit_, j2, circuit_ )

        ( Nothing, Nothing ) ->
            let
                circuit_ =
                    reduce w1 circuit

                circuit__ =
                    reduce w2 circuit_
            in
            ( getVal w1 circuit_, getVal w2 circuit__, circuit__ )


getVal : Wire -> Circuit -> Int
getVal wire circuit =
    let
        val =
            Dict.get wire circuit
    in
    case val of
        Nothing ->
            0

        Just action ->
            case action of
                NoOp i ->
                    i

                _ ->
                    0


parseInput : String -> Circuit
parseInput input =
    parseLines (String.split "\n" input) Dict.empty


parseLines : List String -> Circuit -> Circuit
parseLines lines circuit =
    case lines of
        [] ->
            circuit

        connection :: rest ->
            let
                ( wire, action ) =
                    parseConnection connection

                circuit_ =
                    Dict.insert wire action circuit
            in
            if wire == "" && action == NoOp 0 then
                parseLines rest circuit

            else
                parseLines rest circuit_


parseConnection : String -> ( Wire, Action )
parseConnection connection =
    let
        words =
            String.split " " connection
    in
    case words of
        [ from, "->", to ] ->
            ( to, Pass from )

        [ w1, "AND", w2, "->", to ] ->
            ( to, And w1 w2 )

        [ w1, "OR", w2, "->", to ] ->
            ( to, Or w1 w2 )

        [ w, "LSHIFT", i, "->", to ] ->
            ( to, Lshift w (parseInt i) )

        [ w, "RSHIFT", i, "->", to ] ->
            ( to, Rshift w (parseInt i) )

        [ "NOT", w, "->", to ] ->
            ( to, Not w )

        _ ->
            ( connection, NoOp 0 )


parseInt : String -> Int
parseInt i =
    String.toInt i |> Maybe.withDefault 0


maxValue : Int
maxValue =
    65535


type alias Circuit =
    Dict Wire Action


type alias Wire =
    String


type alias WireOrValue =
    String


type Action
    = NoOp Int
    | Pass WireOrValue
    | And WireOrValue WireOrValue
    | Or WireOrValue WireOrValue
    | Lshift WireOrValue Int
    | Rshift WireOrValue Int
    | Not WireOrValue
