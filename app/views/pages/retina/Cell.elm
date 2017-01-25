module Cell exposing (Cell, init, view, update)

import Html exposing (Html)
import Svg exposing (rect)
import Svg.Attributes exposing (..)


-- local modules

import Config
import Messages exposing (Msg(..))


-- model


type alias Cell =
    { col : Int
    , row : Int
    , val : Float
    }


init : Int -> Int -> Cell
init col row =
    Cell col row 0.0



-- view


view : Cell -> Html Msg
view cell =
    let
        i =
            cell.col * Config.cellSize |> toString

        j =
            cell.row * Config.cellSize |> toString

        v =
            cell.val * 256.0 |> floor |> toString

        c =
            "rgb(" ++ v ++ ", " ++ v ++ ", " ++ v ++ ")"

        s =
            toString Config.cellSize
    in
        rect [ class "cell", x i, y j, fill c, stroke c, width s, height s ] []



-- update


update : Float -> Cell -> Cell
update val cell =
    { cell | val = val }
