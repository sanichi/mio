module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Ports


-- MAIN


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Year =
    { year : Int
    , days : List Int
    }


type alias Model =
    { years : List Year
    , year : Int
    , day : Int
    , data : String
    }


defaultYear : Int
defaultYear =
    2015


defaultDay : Int
defaultDay =
    1


initialModel : Model
initialModel =
    { years =
        [ { year = 2015, days = List.range 1 25 }
        , { year = 2016, days = List.range 1 12 }
        ]
    , year = defaultYear
    , day = defaultDay
    , data = ""
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, getData initialModel.year initialModel.day )



-- UPDATE


type Msg
    = SelectYear Int
    | SelectDay Int
    | NewData String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectYear year ->
            let
                ( newYear, newDay ) =
                    newProblem year model.day model
            in
                { model | year = newYear, day = newDay } ! [ getData newYear newDay ]

        SelectDay day ->
            let
                ( newYear, newDay ) =
                    newProblem model.year day model
            in
                { model | year = newYear, day = newDay } ! [ getData newYear newDay ]

        NewData data ->
            { model | data = data } ! []


newProblem : Int -> Int -> Model -> ( Int, Int )
newProblem year day model =
    let
        year_ =
            model.years
                |> List.filter (\y -> y.year == year)
                |> List.head

        newYear =
            case year_ of
                Just y ->
                    y.year

                Nothing ->
                    defaultYear

        newDay =
            case year_ of
                Just y ->
                    if List.member day y.days then
                        day
                    else
                        y.days
                            |> List.head
                            |> Maybe.withDefault defaultDay

                Nothing ->
                    defaultDay
    in
        ( newYear, newDay )



-- VIEW


view : Model -> Html Msg
view model =
    let
        yearOptions =
            model.years
                |> List.map .year
                |> List.map (viewOption "Year" model.year)

        dayOptions =
            model.years
                |> List.filter (\y -> y.year == model.year)
                |> List.map .days
                |> List.head
                |> Maybe.withDefault []
                |> List.map (viewOption "Day" model.day)

        onYearChange =
            toInt >> SelectYear |> Events.onInput

        onDayChange =
            toInt >> SelectDay |> Events.onInput
    in
        div []
            [ div [ class "row" ]
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
            , hr [] []
            , div [ class "row" ]
                [ div [ class "col-xs-12" ]
                    [ pre [] [ text model.data ]
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



-- COMMANDS & SUBSCRIPTIONS


getData : Int -> Int -> Cmd msg
getData year day =
    Ports.getData ( year, day )


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.newData NewData



-- HELPERS


toInt : String -> Int
toInt str =
    str
        |> String.toInt
        |> Result.withDefault 0
