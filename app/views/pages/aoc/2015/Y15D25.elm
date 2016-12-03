module Y15D25 exposing (..)

import Regex exposing (HowMany(AtMost), find, regex)


answer : String -> String
answer input =
    let
        target =
            parse input

        model =
            search target start
    in
        toString model.code


parse : String -> Target
parse input =
    let
        numbers =
            find (AtMost 1) (regex "code at row (\\d+), column (\\d+)") input
                |> List.map .submatches
                |> List.head
                |> Maybe.withDefault [ Just "1", Just "1" ]
                |> List.map (Maybe.withDefault "1")
                |> List.map String.toInt

        ( row, col ) =
            case numbers of
                [ Ok r, Ok c ] ->
                    ( r, c )

                _ ->
                    ( 1, 1 )
    in
        ( row, col )


search : Target -> Model -> Model
search ( row, col ) model =
    if row == model.row && col == model.col then
        model
    else
        let
            ( row_, col_ ) =
                if model.row > 1 then
                    ( model.row - 1, model.col + 1 )
                else
                    ( model.col + 1, 1 )

            code_ =
                model.code * 252533 % 33554393
        in
            search ( row, col ) { code = code_, row = row_, col = col_ }


type alias Target =
    ( Int, Int )


type alias Model =
    { code : Int
    , row : Int
    , col : Int
    }


start : Model
start =
    { code = 20151125
    , row = 1
    , col = 1
    }
