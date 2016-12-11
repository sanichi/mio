module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events


-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = (always Sub.none)
        }



-- MODEL


type alias Year =
    { year : Int
    , days : List Int
    }


type alias Model =
    { years : List Year
    , selectedYear : Int
    , selectedDay : Int
    }


initialModel : Model
initialModel =
    { years =
        [ { year = 2015, days = List.range 1 25 }
        , { year = 2016, days = List.range 3 11 }
        ]
    , selectedYear = 2016
    , selectedDay = 11
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



-- UPDATE


type Msg
    = SelectYear Int
    | SelectDay Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectYear year ->
            let
                year_ =
                    model.years
                        |> List.filter (\y -> y.year == year)
                        |> List.head

                selectedYear =
                    case year_ of
                        Just _ ->
                            year

                        Nothing ->
                            model.selectedYear

                selectedDay =
                    case year_ of
                        Just y ->
                            y.days
                                |> List.head
                                |> Maybe.withDefault 0

                        Nothing ->
                            model.selectedDay
            in
                ( { model | selectedYear = selectedYear, selectedDay = selectedDay }, Cmd.none )

        SelectDay day ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        yearOptions =
            model.years
                |> List.map .year
                |> List.map (viewOption "Year" model.selectedYear)

        dayOptions =
            model.years
                |> List.filter (\y -> y.year == model.selectedYear)
                |> List.map .days
                |> List.head
                |> Maybe.withDefault []
                |> List.map (viewOption "Day" model.selectedDay)

        onYearChange =
            Events.onInput (\x -> toInt x |> SelectYear)

        onDayChange =
            Events.onInput (\x -> toInt x |> SelectDay)
    in
        div [ class "row" ]
            [ div [ class "col-xs-12" ]
                [ Html.form [ class "form-horizontal", attribute "role" "form" ]
                    [ div [ class "form-group" ]
                        [ div [ class "col-xs-1 col-sm-2 col-md-3" ] []
                        , div [ class "col-xs-4 col-sm-3 col-md-2" ]
                            [ select [ class "form-control input-sm", attribute "size" "1", onYearChange ] yearOptions ]
                        , div [ class "col-xs-2 col-sm-2 col-md-2" ] []
                        , div [ class "col-xs-4 col-sm-3 col-md-2" ]
                            [ select [ class "form-control input-sm", attribute "size" "1", onDayChange ] dayOptions ]
                        ]
                    ]
                ]
            ]


viewOption : String -> Int -> Int -> Html Msg
viewOption prefix sel opt =
    let
        val =
            toString opt

        txt =
            prefix ++ " " ++ val
    in
        option [ value val, sel == opt |> selected ] [ text txt ]



-- HELPERS


toInt : String -> Int
toInt str =
    str
        |> String.toInt
        |> Result.withDefault 0
