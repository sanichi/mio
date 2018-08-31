module Y15D25 exposing (answer)

import Regex exposing (findAtMost)
import Util exposing (onlyOnePart, regex)


answer : Int -> String -> String
answer part input =
    if part == 1 then
        let
            target =
                parse input

            model =
                search target start
        in
        String.fromInt model.code

    else
        Util.onlyOnePart


parse : String -> Target
parse input =
    let
        numbers =
            input
                |> findAtMost 1 (regex "code at row (\\d+), column (\\d+)")
                |> List.map .submatches
                |> List.head
                |> Maybe.withDefault [ Just "1", Just "1" ]
                |> List.map (Maybe.withDefault "1")
                |> List.map String.toInt

        ( row, col ) =
            case numbers of
                [ Just r, Just c ] ->
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
                model.code * 252533 |> modBy 33554393
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
