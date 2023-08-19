module Eras exposing (Model, decrement, increment, init, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..))


type alias Model =
    Int


init : Int -> Model
init year =
    year


increment : Int -> Model -> Model
increment delta year =
    year + delta


decrement : Int -> Model -> Model
decrement delta year =
    if year - delta < minimum then
        minimum

    else
        year - delta


view : Model -> Html Msg
view year =
    let
        style color =
            class <| "btn btn-" ++ color ++ " btn-sm ms-1"

        inc10 =
            [ style "primary", onClick <| ErasIncrement 10 ]

        inc01 =
            [ style "primary", onClick <| ErasIncrement 1 ]

        dec01 =
            if year == minimum then
                [ style "secondary" ]

            else
                [ style "danger", onClick <| ErasDecrement 1 ]

        dec10 =
            if year < minimum + 10 then
                [ style "secondary" ]

            else
                [ style "danger", onClick <| ErasDecrement 10 ]
    in
    div []
        [ button [ class "btn btn-success btn-sm" ] [ text (toEraDisplay year) ]
        , div [ class "float-end" ]
            [ button inc10 [ text "+10" ]
            , button inc01 [ text "+1" ]
            , button dec01 [ text "-1" ]
            , button dec10 [ text "-10" ]
            ]
        ]



-- era data and logic


type alias Era =
    { name : String
    , start : Int
    }


type alias Eras =
    List Era


eras : Eras
eras =
    [ { name = "明治", start = 1868 }
    , { name = "大正", start = 1912 }
    , { name = "昭和", start = 1926 }
    , { name = "平成", start = 1989 }
    , { name = "令和", start = 2019 }
    ]


minimum : Int
minimum =
    case eras of
        [] ->
            0

        first :: _ ->
            first.start


toEraDisplay : Model -> String
toEraDisplay year =
    String.fromInt year ++ " • " ++ toEra eras year


toEra : Eras -> Int -> String
toEra list year =
    case list of
        [] ->
            "error"

        [ last ] ->
            last.name ++ " " ++ String.fromInt (year - last.start + 1)

        first :: second :: rest ->
            if year > second.start then
                toEra (second :: rest) year

            else
                let
                    firstEra =
                        first.name ++ " " ++ String.fromInt (year - first.start + 1)
                in
                if year == second.start then
                    firstEra ++ " • " ++ second.name ++ " 1"

                else
                    firstEra
