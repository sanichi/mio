module Model exposing
  ( init
  , render
  , Model
  )


import Svg exposing (..)
import Svg.Attributes exposing (..)
import XY


type alias Cell = List Bool
type alias Model =
  { dim   : Int
  , cells : List Cell
  }


init_cell : Int -> Cell
init_cell dim =
  List.repeat dim True


init : Model
init =
  let
    d = 5
  in
    { dim = d
    , cells = List.repeat (d * d) (init_cell d)
    }


render_cell : Int -> Cell -> Svg msg
render_cell index cell =
  let
    d = List.length cell
    s = XY.cell_size d |> toString
    xy = XY.cell_xy d index
    i = fst xy |> toString
    j = snd xy |> toString
  in
    rect [ x i, y j, width s, height s, class "cell" ] []


render : Model -> List (Svg msg)
render model =
  List.indexedMap render_cell model.cells
