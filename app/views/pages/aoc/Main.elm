module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Platform.Sub
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
    , thinks : Thinks
    }


type alias Answers =
    ( Maybe String, Maybe String )


type alias Thinks =
    ( Bool, Bool )


defaultYear : Int
defaultYear =
    2016


defaultDay : Int
defaultDay =
    13


initModel : Model
initModel =
    { years =
        [ { year = 2015, days = List.range 1 25 }
        , { year = 2016, days = List.range 1 13 }
        ]
    , year = defaultYear
    , day = defaultDay
    , data = Nothing
    , answers = initAnswers
    , thinks = initThinks
    }


initAnswers : Answers
initAnswers =
    ( Nothing, Nothing )


initThinks : Thinks
initThinks =
    ( False, False )


init : ( Model, Cmd Msg )
init =
    ( initModel, getData initModel.year initModel.day )



-- UPDATE


type Msg
    = SelectYear Int
    | SelectDay Int
    | NewData String
    | Answer Int
    | Prepare Int


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

        Prepare part ->
            { model | thinks = thinking part } ! [ prepareAnswer part ]

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
                { model | answers = answers, thinks = initThinks } ! []


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


thinking : Int -> Thinks
thinking part =
    if part == 1 then
        ( True, False )
    else
        ( False, True )



-- COMMANDS & SUBSCRIPTIONS


getData : Int -> Int -> Cmd Msg
getData year day =
    Ports.getData ( year, day )


prepareAnswer : Int -> Cmd Msg
prepareAnswer part =
    Ports.prepareAnswer part


subscriptions : Model -> Sub Msg
subscriptions model =
    Platform.Sub.batch
        [ Ports.newData NewData
        , Ports.startAnswer Answer
        ]



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
                            , codeLink model
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

        thinking =
            if part == 1 then
                Tuple.first model.thinks
            else
                Tuple.second model.thinks

        display =
            if thinking then
                img [ src "/images/loader.gif" ] []
            else
                case answer of
                    Nothing ->
                        let
                            time =
                                slow model.year model.day part

                            words =
                                "Get Anwser"
                                    :: List.repeat time "🕰"
                                    |> String.join " "

                            btnType =
                                if time == 0 then
                                    "success"
                                else
                                    "danger"
                        in
                            span [ class ("btn btn-" ++ btnType ++ " btn-xs"), Events.onClick (Prepare part) ] [ text words ]

                    Just ans ->
                        if String.length ans > 25 then
                            pre [] [ text ans ]
                        else
                            text ans
    in
        tr []
            [ th [ class "col-xs-6 text-center" ]
                [ "Part " ++ name |> text ]
            , td [ class "col-xs-6 text-center" ]
                [ display ]
            ]


codeLink : Model -> Html Msg
codeLink model =
    let
        year =
            model.year |> toString

        shortYear =
            String.right 2 year

        day =
            model.day |> toString

        paddedDay =
            if model.day > 9 then
                day
            else
                "0" ++ day

        scheme =
            "https://"

        domain =
            "bitbucket.org/"

        path =
            "sanichi/sni_mio_app/src/master/app/views/pages/aoc/" ++ year ++ "/"

        file =
            "Y" ++ shortYear ++ "D" ++ paddedDay ++ ".elm"

        link =
            scheme ++ domain ++ path ++ file
    in
        tr []
            [ td [ class "col-xs-12 text-center", colspan 2 ]
                [ a [ href link, target "external" ] [ text "Code" ] ]
            ]



-- HELPERS


toInt : String -> Int
toInt str =
    str
        |> String.toInt
        |> Result.withDefault 0


slow : Int -> Int -> Int -> Int
slow year day part =
    let
        faster =
            [ year, day, part ]
                |> List.map toString
                |> String.join "-"
    in
        case faster of
            "2015-4-1" ->
                2

            "2015-4-2" ->
                3

            "2015-6-1" ->
                2

            "2015-6-2" ->
                3

            "2015-10-1" ->
                1

            "2015-10-2" ->
                2

            "2015-11-1" ->
                1

            "2015-11-2" ->
                2

            "2015-13-1" ->
                1

            "2015-13-2" ->
                2

            "2015-15-1" ->
                2

            "2015-15-2" ->
                2

            "2015-17-1" ->
                2

            "2015-17-2" ->
                2

            "2015-18-1" ->
                2

            "2015-18-2" ->
                2

            "2015-20-1" ->
                2

            "2015-20-2" ->
                2

            "2015-24-1" ->
                2

            "2015-24-2" ->
                1

            "2016-5-1" ->
                3

            "2016-5-2" ->
                3

            "2016-9-1" ->
                3

            "2016-9-2" ->
                3

            "2016-12-1" ->
                1

            "2016-12-2" ->
                2

            _ ->
                0
