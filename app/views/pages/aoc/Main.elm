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
    17


initModel : Model
initModel =
    { years =
        [ { year = 2015, days = List.range 1 25 }
        , { year = 2016, days = List.range 1 17 }
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
                    getAnswer model part data

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


getAnswer : Model -> Int -> String -> String
getAnswer model part data =
    case model.year of
        2015 ->
            Y15.answer model.day part data

        2016 ->
            Y16.answer model.day part data

        _ ->
            ""



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
                |> List.map (viewYearOption model.year)

        dayOptions =
            model.years
                |> List.filter (\y -> y.year == model.year)
                |> List.map .days
                |> List.head
                |> Maybe.withDefault []
                |> List.map (viewDayOption model.year model.day)

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
                            [ viewAnswer model 1
                            , viewAnswer model 2
                            , viewLinks model
                            , viewNote model
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


viewYearOption : Int -> Int -> Html Msg
viewYearOption chosen year =
    let
        str =
            toString year

        txt =
            "Year " ++ str
    in
        option [ value str, chosen == year |> selected ] [ text txt ]


viewDayOption : Int -> Int -> Int -> Html Msg
viewDayOption year chosen day =
    let
        str =
            toString day

        pad =
            if String.length str == 1 then
                "0" ++ str
            else
                str

        speedSymbol =
            [ 1, 2 ]
                |> List.map (speed year day)
                |> List.maximum
                |> Maybe.withDefault 0
                |> speedIndicator

        failedSymbol =
            [ 1, 2 ]
                |> List.map (failed year day)
                |> List.foldl (||) False
                |> failedIndicator

        txt =
            "Day " ++ pad ++ " " ++ failedSymbol ++ " " ++ speedSymbol
    in
        option [ value str, chosen == day |> selected ] [ text txt ]


viewAnswer : Model -> Int -> Html Msg
viewAnswer model part =
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

        noSolution =
            failed model.year model.day part

        display =
            if noSolution then
                let
                    data =
                        model.data
                            |> Maybe.withDefault ""
                in
                    getAnswer model part data |> text
            else if thinking then
                img [ src "/images/loader.gif" ] []
            else
                case answer of
                    Nothing ->
                        let
                            time =
                                speed model.year model.day part

                            decoration =
                                speedIndicator time

                            words =
                                "Get Anwser " ++ decoration

                            colour =
                                if time == 0 then
                                    "success"
                                else if time == 1 then
                                    "info"
                                else if time == 2 then
                                    "warning"
                                else
                                    "danger"
                        in
                            span [ class ("btn btn-" ++ colour ++ " btn-xs"), Events.onClick (Prepare part) ] [ text words ]

                    Just ans ->
                        if String.length ans > 32 then
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


speedIndicator : Int -> String
speedIndicator time =
    case time of
        0 ->
            "⚡️"

        1 ->
            "⏳"

        2 ->
            "☕️"

        3 ->
            "🐌"

        _ ->
            "☠️"


failedIndicator : Bool -> String
failedIndicator failed =
    if failed then
        "✘"
    else
        "✔︎"


viewLinks : Model -> Html Msg
viewLinks model =
    tr []
        [ td [ class "text-center", colspan 2 ]
            [ probLink model
            , (text " • ")
            , codeLink model
            ]
        ]


probLink : Model -> Html Msg
probLink model =
    let
        year =
            model.year |> toString

        day =
            model.day |> toString

        scheme =
            "https://"

        domain =
            "adventofcode.com/"

        path =
            year ++ "/day/"

        file =
            day

        link =
            scheme ++ domain ++ path ++ file
    in
        a [ href link, target "external" ] [ text "Problem" ]


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
        a [ href link, target "external2" ] [ text "Code" ]


viewNote : Model -> Html Msg
viewNote model =
    let
        note =
            getNote model.year model.day
                |> Maybe.withDefault ""

        display =
            if note == "" then
                "none"
            else
                "table-row"
    in
        tr [ style [ ( "display", display ) ] ]
            [ td [ colspan 2 ] [ text note ] ]



-- HELPERS


toInt : String -> Int
toInt str =
    str
        |> String.toInt
        |> Result.withDefault 0


speed : Int -> Int -> Int -> Int
speed year day part =
    let
        key =
            [ year, day, part ]
                |> List.map toString
                |> String.join "-"
    in
        case key of
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

            "2015-25-1" ->
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

            "2016-14-1" ->
                2

            "2016-14-2" ->
                4

            "2016-15-1" ->
                1

            "2016-15-2" ->
                2

            "2016-16-2" ->
                4

            _ ->
                0


failed : Int -> Int -> Int -> Bool
failed year day part =
    let
        key =
            [ year, day, part ]
                |> List.map toString
                |> String.join "-"
    in
        case key of
            "2015-12-2" ->
                True

            "2015-22-1" ->
                True

            "2015-22-2" ->
                True

            "2016-11-1" ->
                True

            "2016-11-2" ->
                True

            _ ->
                False


getNote : Int -> Int -> Maybe String
getNote year day =
    let
        key =
            [ year, day ]
                |> List.map toString
                |> String.join "-"
    in
        case key of
            "2015-12" ->
                Just "For part 2 I couldn't see any way to filter out the \"red\" parts of the object in Elm so did it in Perl instead."

            "2015-22" ->
                Just "I found this problem highly annoying as there were so many fiddly details to take care of. After many iteratons of a Perl 5 program eventually produced the right answers, I couldn't face trying to redo it all in Elm."

            "2016-11" ->
                Just "I didn't have much of a clue about this one so quickly admitted defeat and spent my time on other things that day."

            "2016-14" ->
                Just "I left part 2 running for nearly 24 hours and it still hadn't finished. So, giving up on that, I wrote a Perl 5 program based on the same algorithm and it only took 20 seconds! I estimate MD5 digests are roughly 100 times faster in Perl 5 than in Elm, so that's not the whole story since 100 times 20 seconds is only about half an hour."

            "2016-16" ->
                Just "The Elm program for part 2 crashed my browser window after a few minutes (presumably out of memory) so instead I wrote a Perl 5 program which got the answer in less than a minute while using almost 3GB of memory."

            _ ->
                Nothing
