module Y15D03 exposing (answer)

import Array exposing (Array)
import Dict exposing (Dict)


answer : Int -> String -> String
answer part input =
    if part == 1 then
        christmas 1 input

    else
        christmas 2 input


christmas : Int -> String -> String
christmas n input =
    let
        model =
            deliver (initModel n) input
    in
    case model.err of
        Just err ->
            err

        Nothing ->
            Dict.keys model.visited |> List.length |> String.fromInt


type alias Santa =
    { stop : Bool
    , x : Int
    , y : Int
    , err : Maybe String
    }


initSanta : Santa
initSanta =
    { stop = False
    , x = 0
    , y = 0
    , err = Nothing
    }


errorSanta : String -> Santa
errorSanta err =
    { stop = True
    , x = 0
    , y = 0
    , err = Just err
    }


type alias Visited =
    Dict String Bool


type alias Model =
    { visited : Visited
    , santas : Array Santa
    , turn : Int
    , err : Maybe String
    }


initModel : Int -> Model
initModel n =
    { visited = visit 0 0 Dict.empty
    , santas = Array.repeat n initSanta
    , turn = 0
    , err = Nothing
    }


deliver : Model -> String -> Model
deliver model instructions =
    if String.isEmpty instructions then
        model

    else
        let
            next =
                String.uncons instructions

            ( char, remaining ) =
                case next of
                    Just ( c, r ) ->
                        ( c, r )

                    _ ->
                        ( '*', "" )

            index =
                remainderBy (Array.length model.santas) model.turn

            santa =
                Array.get index model.santas |> Maybe.withDefault (errorSanta ("illegal index [" ++ String.fromInt index ++ "]"))

            santa_ =
                updateSanta char santa
        in
        if santa_.stop then
            { model | err = santa.err }

        else
            let
                model_ =
                    { model
                        | visited = visit santa_.x santa_.y model.visited
                        , turn = model.turn + 1
                        , santas = Array.set index santa_ model.santas
                    }
            in
            deliver model_ remaining


updateSanta : Char -> Santa -> Santa
updateSanta char santa =
    case char of
        '>' ->
            { santa | x = santa.x + 1 }

        '<' ->
            { santa | x = santa.x - 1 }

        '^' ->
            { santa | y = santa.y + 1 }

        'v' ->
            { santa | y = santa.y - 1 }

        '\n' ->
            { santa | stop = True }

        _ ->
            errorSanta ("illegal instruction [" ++ String.fromChar char ++ "]")


visit : Int -> Int -> Visited -> Visited
visit x y visited =
    let
        key =
            String.fromInt x ++ "|" ++ String.fromInt y
    in
    Dict.insert key True visited
