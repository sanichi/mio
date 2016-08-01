module Model
    exposing
        ( init
        , render
        , Model
        )

import Svg exposing (..)
import Svg.Attributes exposing (..)
import XY


type alias Cell =
    List Bool


type alias Model =
    { dim : Int
    , cells : List Cell
    }


init_cell : Int -> Cell
init_cell dim =
    List.repeat dim True


init : Model
init =
    let
        d =
            5
    in
        { dim = d
        , cells = List.repeat (d * d) (init_cell d)
        }


render_cell : Int -> Cell -> Svg msg
render_cell index cell =
    let
        d =
            List.length cell

        s =
            XY.cell_size d |> toString

        xy =
            XY.cell_xy d index

        i =
            fst xy |> toString

        j =
            snd xy |> toString

        t =
            "translate(" ++ i ++ "," ++ j ++ ")"

        boundary =
            rect [ width s, height s, class "cell" ] []

        numbers =
            render_numbers d cell
    in
        g [ transform t ] (boundary :: numbers)


render_numbers : Int -> Cell -> List (Svg msg)
render_numbers d cell =
    case cell of
        b :: rest ->
            let
                i =
                    d - List.length cell + 1

                w =
                    (XY.cell_size d |> toFloat) / (toFloat d)

                x =
                    (toFloat i - 0.5) * w |> round |> toString

                y =
                    (XY.cell_size d |> toFloat) / 2.0 |> round |> toString
            in
                render_number i ( x, y ) b :: render_numbers d rest

        [] ->
            []


render_number : Int -> ( String, String ) -> Bool -> Svg msg
render_number i xy b =
    text' [ fst xy |> x, snd xy |> y, textAnchor "middle", alignmentBaseline "middle", fontSize "25" ] [ toString i |> text ]


render : Model -> List (Svg msg)
render model =
    List.indexedMap render_cell model.cells
