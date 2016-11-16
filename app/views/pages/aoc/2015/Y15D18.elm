module Y15D18 exposing (..)

import Array exposing (Array)
import Regex exposing (HowMany(All), find, regex)
import String
import Util exposing (join)


answers : String -> String
answers input =
    let
        model =
            parseInput input

        nm =
            100

        m1 =
            steps nm model

        m2 =
            stick model |> steps nm

        p1 =
            count m1 |> toString

        p2 =
            count m2 |> toString
    in
        join p1 p2


steps : Int -> Model -> Model
steps n model =
    if n <= 0 then
        model
    else
        step model |> steps (n - 1)


step : Model -> Model
step model =
    let
        start =
            ( 0, 0 )

        oldModel =
            model
    in
        sweep oldModel model start


sweep : Model -> Model -> Cell -> Model
sweep oldModel model cell =
    if outside model cell then
        model
    else
        let
            v =
                newVal oldModel cell

            model_ =
                { model | lights = Array.set (index model cell) v model.lights }

            nextCell =
                next model_ cell
        in
            sweep oldModel model_ nextCell


newVal : Model -> Cell -> Bool
newVal model cell =
    if model.stuck && corner model cell then
        True
    else
        let
            n =
                neighbours model cell
        in
            if query model cell then
                n == 2 || n == 3
            else
                n == 3


neighbours : Model -> Cell -> Int
neighbours model ( r, c ) =
    let
        ds =
            [ ( -1, -1 )
            , ( 0, -1 )
            , ( 1, -1 )
            , ( -1, 0 )
            , ( 1, 0 )
            , ( -1, 1 )
            , ( 0, 1 )
            , ( 1, 1 )
            ]
    in
        List.map (\( dr, dc ) -> ( r + dr, c + dc )) ds
            |> List.map (query model)
            |> List.filter identity
            |> List.length


query : Model -> Cell -> Bool
query model cell =
    if outside model cell then
        False
    else
        Array.get (index model cell) model.lights |> Maybe.withDefault False


index : Model -> Cell -> Int
index model ( r, c ) =
    r * model.size + c


corner : Model -> Cell -> Bool
corner model ( r, c ) =
    (r == 0 || r == model.maxIndex) && (c == 0 || c == model.maxIndex)


next : Model -> Cell -> Cell
next model ( r, c ) =
    if c >= model.maxIndex then
        ( r + 1, 0 )
    else
        ( r, c + 1 )


outside : Model -> Cell -> Bool
outside model ( r, c ) =
    r > model.maxIndex || r < 0 || c > model.maxIndex || c < 0


count : Model -> Int
count model =
    Array.toList model.lights
        |> List.filter identity
        |> List.length


stick : Model -> Model
stick model =
    let
        a =
            model.lights
                |> Array.set (index model ( 0, 0 )) True
                |> Array.set (index model ( 0, model.maxIndex )) True
                |> Array.set (index model ( model.maxIndex, 0 )) True
                |> Array.set (index model ( model.maxIndex, model.maxIndex )) True
    in
        { model | lights = a, stuck = True }


parseInput : String -> Model
parseInput input =
    let
        a =
            find All (regex "[#.]") input
                |> List.map .match
                |> List.map (\s -> s == "#")
                |> List.foldl Array.push Array.empty

        s =
            Array.length a |> toFloat |> sqrt |> ceiling

        m =
            s - 1
    in
        Model a s m False


debug : Model -> String
debug model =
    let
        chars =
            Array.toList model.lights
                |> List.map
                    (\b ->
                        if b then
                            "#"
                        else
                            "."
                    )
                |> String.join ""

        lines =
            find All (regex (".{" ++ toString model.size ++ "}")) chars
                |> List.map .match
    in
        (String.join "\n" lines) ++ "\n"


type alias Model =
    { lights : Array Bool
    , size : Int
    , maxIndex : Int
    , stuck : Bool
    }


initModel : Model
initModel =
    { lights = Array.empty
    , size = 0
    , maxIndex = 0
    , stuck = False
    }


type alias Cell =
    ( Int, Int )
