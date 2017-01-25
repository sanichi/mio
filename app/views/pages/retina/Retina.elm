module Retina exposing (Retina, init, update, view)

import Dict exposing (Dict)
import Html exposing (Html)
import Svg exposing (rect)
import Svg.Attributes exposing (..)


-- local modules

import Cell exposing (Cell)
import Config
import Messages exposing (Msg(..))


-- model


type alias Retina =
    Dict ( Int, Int ) Cell


init : Retina
init =
    init_ 0 0 Dict.empty


init_ : Int -> Int -> Retina -> Retina
init_ col row retina =
    if row < Config.cells then
        if col < Config.cells then
            let
                cell =
                    Cell.init col row

                newRetina =
                    Dict.insert ( col, row ) cell retina
            in
                init_ (col + 1) row newRetina
        else
            init_ 0 (row + 1) retina
    else
        retina



-- view


view : Retina -> List (Html Msg)
view retina =
    retina
        |> Dict.values
        |> List.map Cell.view



-- update


update : List Float -> Retina -> Retina
update vals retina =
    if List.length vals == Dict.size retina then
        let
            keys =
                Dict.keys retina

            cells =
                Dict.values retina
        in
            cells
                |> List.map2 (\v c -> Cell.update v c) vals
                |> List.map2 (,) keys
                |> Dict.fromList
    else
        retina
