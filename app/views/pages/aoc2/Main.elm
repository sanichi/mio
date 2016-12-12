module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Ports
import Y15
import Y16


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
    , data : Maybe String
    , answers : Answers
    }


type alias Answers =
    ( Maybe String, Maybe String )


defaultYear : Int
defaultYear =
    2015


defaultDay : Int
defaultDay =
    1


initModel : Model
initModel =
    { years =
        [ { year = 2015, days = List.range 1 25 }
        , { year = 2016, days = List.range 1 12 }
        ]
    , year = defaultYear
    , day = defaultDay
    , data = Nothing
    , answers = initAnswers
    }


initAnswers : Answers
initAnswers =
    ( Nothing, Nothing )


init : ( Model, Cmd Msg )
init =
    ( initModel, getData initModel.year initModel.day )



-- UPDATE


type Msg
    = SelectYear Int
    | SelectDay Int
    | NewData String
    | Answer Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectYear year ->
            let
                ( newYear, newDay ) =
                    newProblem year model.day model
            in
                { initModel | year = newYear, day = newDay } ! [ getData newYear newDay ]

        SelectDay day ->
            let
                ( newYear, newDay ) =
                    newProblem model.year day model
            in
                { initModel | year = newYear, day = newDay } ! [ getData newYear newDay ]

        NewData data ->
            { model | data = Just data } ! []

        Answer part ->
            let
                data =
                    Maybe.withDefault "" model.data

                answer =
                    case model.year of
                        2015 ->
                            Y15.answer model.day part data

                        2016 ->
                            Y16.answer model.day part data

                        _ ->
                            ""

                answers =
                    if part == 1 then
                        ( Just answer, model.answers |> Tuple.second )
                    else
                        ( model.answers |> Tuple.first, Just answer )
            in
                { model | answers = answers } ! []


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

        data =
            model.data
                |> Maybe.withDefault ""
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
                [ div [ class "col-xs-12 col-sm-offset-1 col-sm-10 col-md-offset-2 col-md-8 col-lg-offset-3 col-lg-6" ]
                    [ table [ class "table table-bordered" ]
                        [ tbody []
                            [ viewAnswer 1 model
                            , viewAnswer 2 model
                            ]
                        ]
                    ]
                ]
            , hr [] []
            , div [ class "row" ]
                [ div [ class "col-xs-12" ]
                    [ pre [] [ text data ]
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


viewAnswer : Int -> Model -> Html Msg
viewAnswer part model =
    let
        name =
            if part == 1 then
                "One"
            else
                "Two"

        answer =
            if part == 1 then
                Tuple.first model.answers
            else
                Tuple.second model.answers

        display =
            case answer of
                Nothing ->
                    span [ class "btn btn-success btn-xs", Events.onClick (Answer part) ] [ text "Get Answer" ]

                Just ans ->
                    text ans
    in
        tr []
            [ th [ class "col-xs-6 text-center" ]
                [ "Part " ++ name |> text ]
            , td [ class "col-xs-6 text-center" ]
                [ display ]
            ]



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
