module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Platform.Cmd exposing (none)
import Platform.Sub
import Ports
import Util exposing (unique)
import Y15
import Y16
import Y20
import Y21



-- MAIN


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> subscriptions
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
    , answers : Answers
    , thinks : Thinks
    , help : Bool
    }


type alias Answers =
    ( Maybe String, Maybe String )


type alias Thinks =
    ( Bool, Bool )


type alias Flags =
    { year : String
    , day : String
    }


defaultYear : Int
defaultYear =
    2021


defaultDay : Int
defaultDay =
    21


initModel : Model
initModel =
    { years =
        [ { year = 2015, days = List.range 1 25 }
        , { year = 2016, days = List.range 1 25 }
        , { year = 2020, days = List.range 1 25 }
        , { year = defaultYear, days = List.range 1 defaultDay }
        ]
    , year = defaultYear
    , day = defaultDay
    , data = ""
    , answers = ( Nothing, Nothing )
    , thinks = ( False, False )
    , help = False
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        year =
            flags.year
                |> String.toInt
                |> Maybe.withDefault defaultYear

        day =
            flags.day
                |> String.toInt
                |> Maybe.withDefault defaultDay

        model =
            newProblem year day
    in
    ( model, getData model )



-- UPDATE


type Msg
    = SelectYear Int
    | SelectDay Int
    | GotData String
    | DoPause Int
    | DonePause Int
    | GotRuby ( Int, String )
    | ShowHelp
    | HideHelp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectYear year ->
            let
                newModel =
                    newProblem year model.day
            in
            ( newModel, getData newModel )

        SelectDay day ->
            let
                newModel =
                    newProblem model.year day
            in
            ( newModel, getData newModel )

        GotData data ->
            ( { model | data = data }, none )

        DoPause part ->
            if useRuby model.year model.day part then
                ( { model | thinks = thinking part }, getRuby model part )

            else
                ( { model | thinks = thinking part }, doPause part )

        DonePause part ->
            let
                answer =
                    getAnswer model part model.data
            in
            ( gotAnswer part answer model, none )

        GotRuby ( part, answer ) ->
            ( gotAnswer part answer model, none )

        ShowHelp ->
            ( { model | help = True }, none )

        HideHelp ->
            ( { model | help = False }, none )


gotAnswer : Int -> String -> Model -> Model
gotAnswer part answer model =
    let
        ( answer1, answer2 ) =
            model.answers

        answers =
            if part == 1 then
                ( Just answer, answer2 )

            else
                ( answer1, Just answer )
    in
    { model | answers = answers, thinks = ( False, False ) }


newProblem : Int -> Int -> Model
newProblem year day =
    let
        year1 =
            initModel.years
                |> List.filter (\y -> y.year == year)
                |> List.head

        newYear =
            case year1 of
                Just y ->
                    y.year

                Nothing ->
                    defaultYear

        year2 =
            initModel.years
                |> List.filter (\y -> y.year == newYear)
                |> List.head

        newDay =
            case year2 of
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
    { initModel | year = newYear, day = newDay }


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

        2020 ->
            Y20.answer model.day part data

        2021 ->
            Y21.answer model.day part data

        _ ->
            ""



-- COMMANDS & SUBSCRIPTIONS


getData : Model -> Cmd Msg
getData model =
    Ports.getData ( model.year, model.day )


getRuby : Model -> Int -> Cmd Msg
getRuby model part =
    Ports.getRuby [ model.year, model.day, part ]


doPause : Int -> Cmd Msg
doPause part =
    Ports.doPause part


subscriptions : Sub Msg
subscriptions =
    Platform.Sub.batch
        [ Ports.gotData GotData
        , Ports.gotRuby GotRuby
        , Ports.donePause DonePause
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
    in
    div []
        [ Html.form [ class "row g-3" ]
            [ div [ class "offset-1 col-5 offset-sm-2 col-sm-4 offset-md-3 col-md-3 offset-lg-4 col-lg-2" ]
                [ select [ class "form-select", onYearChange ] yearOptions ]
            , div [ class "col-5 col-sm-4 col-md-3 col-lg-2" ]
                [ select [ class "form-select", onDayChange ] dayOptions ]
            ]
        , hr [] []
        , div [ class "row" ]
            [ div [ class "offset-sm-1 col-sm-10 offset-md-2 col-md-8 offset-lg-3 col-lg-6" ]
                [ table [ class "table table-bordered" ]
                    [ thead [] [ viewHeader ]
                    , tbody []
                        [ viewAnswer model 1
                        , viewAnswer model 2
                        ]
                    ]
                ]
            ]
        , div [ class "row" ]
            [ div [ class "offset-sm-1 col-sm-10 offset-md-2 col-md-8 offset-lg-3 col-lg-6" ]
                [ table [ class "table table-bordered" ]
                    [ tbody []
                        [ viewLinks model
                        , viewNote model
                        ]
                    ]
                ]
            ]
        , hr [] []
        , viewHelp model.help
        , hr [] []
        , div [ class "row" ]
            [ div [ class "col" ]
                [ pre [] [ text model.data ]
                ]
            ]
        ]


viewYearOption : Int -> Int -> Html Msg
viewYearOption chosen year =
    let
        str =
            String.fromInt year

        txt =
            "Year " ++ str
    in
    option [ value str, chosen == year |> selected ] [ text txt ]


viewDayOption : Int -> Int -> Int -> Html Msg
viewDayOption year chosen day =
    let
        str =
            String.fromInt day

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


viewHeader : Html Msg
viewHeader =
    tr [ class "d-flex" ]
        [ td [ class "col-2 text-center" ]
            [ text "Part" ]
        , td [ class "col-10 text-center" ]
            [ text "Answer" ]
        ]


viewAnswer : Model -> Int -> Html Msg
viewAnswer model part =
    let
        answer =
            if part == 1 then
                Tuple.first model.answers

            else
                Tuple.second model.answers

        busy =
            if part == 1 then
                Tuple.first model.thinks

            else
                Tuple.second model.thinks

        noSolution =
            failed model.year model.day part

        display =
            if noSolution then
                model.data
                    |> getAnswer model part
                    |> text

            else if busy then
                img [ src "/images/loader.gif" ] []

            else
                case answer of
                    Nothing ->
                        let
                            time =
                                speed model.year model.day part

                            colour =
                                speedColour time

                            symbol =
                                speedIndicator time
                        in
                        span [ class ("btn btn-" ++ colour ++ " btn-sm"), Events.onClick (DoPause part) ] [ text symbol ]

                    Just ans ->
                        if String.length ans > 32 then
                            pre [] [ text ans ]

                        else
                            text ans
    in
    tr [ class "d-flex" ]
        [ td [ class "col-2 text-center" ]
            [ String.fromInt part |> text ]
        , td [ class "col-10 text-center" ]
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
            "🐌"

        3 ->
            "☕️"

        4 ->
            "☠️"

        _ ->
            "⛔️"


speedColour : Int -> String
speedColour time =
    case time of
        0 ->
            "success"

        1 ->
            "info"

        2 ->
            "primary"

        3 ->
            "warning"

        4 ->
            "danger"

        _ ->
            "dark"


speedDescription : Int -> String
speedDescription time =
    case time of
        0 ->
            "Answer should be returned instantly"

        1 ->
            "Won‘t take more than a few seconds"

        2 ->
            "Will take more like a minute"

        3 ->
            "You should have time to get a coffee"

        4 ->
            "May take many hours or run out of memory"

        _ ->
            "Not done yet"


viewHelp : Bool -> Html Msg
viewHelp show =
    let
        btnText txt =
            txt ++ " Button Decriptions" |> text
    in
    if show then
        let
            trows =
                List.map viewIcon [ 0, 1, 2, 3, 4, 5 ]
        in
        div [ class "row" ]
            [ div [ class "offset-1 col-10 offset-lg-2 col-lg-8" ]
                [ p [ class "text-center" ]
                    [ button [ type_ "button", class "btn btn-sm btn-secondary", Events.onClick HideHelp ] [ btnText "Hide" ] ]
                , table [ class "table table-bordered" ]
                    [ tbody [] trows ]
                ]
            ]

    else
        p [ class "text-center" ]
            [ button [ type_ "button", class "btn btn-sm btn-secondary", Events.onClick ShowHelp ] [ btnText "Show" ] ]


viewIcon : Int -> Html Msg
viewIcon time =
    let
        colour =
            speedColour time

        symbol =
            speedIndicator time

        klass =
            "btn btn-sm btn-" ++ colour

        description =
            speedDescription time
    in
    tr [ class "d-flex" ]
        [ td [ class "col-2 text-center" ]
            [ span [ class klass ] [ text symbol ] ]
        , td [ class "col-10" ]
            [ text description ]
        ]


failedIndicator : Bool -> String
failedIndicator failedFlag =
    if failedFlag then
        "✘"

    else
        "✔︎"


viewLinks : Model -> Html Msg
viewLinks model =
    let
        links =
            probLink model
                :: codeLinks model
                |> List.intersperse (text " • ")
    in
    tr []
        [ td [ class "text-center" ] links ]


probLink : Model -> Html Msg
probLink model =
    let
        year =
            model.year |> String.fromInt

        day =
            model.day |> String.fromInt

        link =
            "https://adventofcode.com/" ++ year ++ "/day/" ++ day
    in
    a [ href link, target "external" ] [ text "Problem" ]


codeLinks : Model -> List (Html Msg)
codeLinks model =
    let
        year =
            String.fromInt model.year

        day =
            String.fromInt model.day

        prefix =
            "https://bitbucket.org/sanichi/mio/src/main/app/"
    in
    [ 1, 2 ]
        |> List.map (useRuby model.year model.day)
        |> unique
        |> List.map
            (\b ->
                if b then
                    rubyLink prefix year day

                else
                    elmLink prefix year day
            )


elmLink : String -> String -> String -> Html Msg
elmLink prefix year day =
    let
        shortYear =
            String.right 2 year

        paddedDay =
            if String.length day == 2 then
                day

            else
                "0" ++ day

        link =
            prefix ++ "views/pages/aoc/" ++ year ++ "/Y" ++ shortYear ++ "D" ++ paddedDay ++ ".elm"
    in
    a [ href link, target "external2" ] [ text "Elm" ]


rubyLink : String -> String -> String -> Html Msg
rubyLink prefix year day =
    let
        link =
            prefix ++ "models/aoc/y" ++ year ++ "d" ++ day ++ ".rb"
    in
    a [ href link, target "external2" ] [ text "Ruby" ]


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
    tr [ style "display" display ]
        [ td [] [ text note ] ]



-- HELPERS


toInt : String -> Int
toInt str =
    str
        |> String.toInt
        |> Maybe.withDefault 0


speed : Int -> Int -> Int -> Int
speed year day part =
    let
        key =
            [ year, day, part ]
                |> List.map String.fromInt
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

        "2016-17-2" ->
            2

        "2016-18-2" ->
            1

        "2016-22-1" ->
            1

        "2016-24-1" ->
            2

        "2016-24-2" ->
            2

        "2020-1-2" ->
            1

        "2020-11-1" ->
            1

        "2020-11-2" ->
            1

        "2020-15-2" ->
            2

        "2020-17-2" ->
            1

        "2020-20-2" ->
            1

        "2020-22-2" ->
            1

        "2020-23-2" ->
            2

        "2020-24-2" ->
            1

        "2020-25-1" ->
            1

        "2021-12-2" ->
            1

        "2021-15-2" ->
            5

        "2021-17-1" ->
            1

        "2021-17-2" ->
            1

        "2021-18-2" ->
            1

        "2021-19-1" ->
            5

        "2021-19-2" ->
            5

        "2021-20-2" ->
            2

        "2021-21-2" ->
            3

        _ ->
            0


useRuby : Int -> Int -> Int -> Bool
useRuby year day part =
    let
        key =
            [ year, day, part ]
                |> List.map String.fromInt
                |> String.join "-"
    in
    case key of
        "2020-20-2" ->
            True

        "2021-1-1" ->
            True

        "2021-4-1" ->
            True

        "2021-4-2" ->
            True

        "2021-5-1" ->
            True

        "2021-5-2" ->
            True

        "2021-6-1" ->
            True

        "2021-6-2" ->
            True

        "2021-7-1" ->
            True

        "2021-7-2" ->
            True

        "2021-8-1" ->
            True

        "2021-8-2" ->
            True

        "2021-9-1" ->
            True

        "2021-9-2" ->
            True

        "2021-10-1" ->
            True

        "2021-10-2" ->
            True

        "2021-11-1" ->
            True

        "2021-11-2" ->
            True

        "2021-12-1" ->
            True

        "2021-12-2" ->
            True

        "2021-13-1" ->
            True

        "2021-13-2" ->
            True

        "2021-14-1" ->
            True

        "2021-14-2" ->
            True

        "2021-15-1" ->
            True

        "2021-15-2" ->
            True

        "2021-16-1" ->
            True

        "2021-16-2" ->
            True

        "2021-17-1" ->
            True

        "2021-17-2" ->
            True

        "2021-18-1" ->
            True

        "2021-18-2" ->
            True

        "2021-19-1" ->
            True

        "2021-19-2" ->
            True

        "2021-20-1" ->
            True

        "2021-20-2" ->
            True

        "2021-21-1" ->
            True

        "2021-21-2" ->
            True

        _ ->
            False


getNote : Int -> Int -> Maybe String
getNote year day =
    let
        key =
            [ year, day ]
                |> List.map String.fromInt
                |> String.join "-"
    in
    case key of
        "2015-12" ->
            Just "For part 2 I couldn‘t see any way to filter out the \"red\" parts of the object in Elm so did it in Perl instead."

        "2015-22" ->
            Just "I found this problem highly annoying as there were so many fiddly details to take care of. After many iteratons of a Perl 5 program eventually produced the right answers, I couldn‘t face trying to redo it all in Elm."

        "2016-11" ->
            Just "I didn‘t have much of a clue about this one so quickly admitted defeat and spent my time on other things that day."

        "2016-14" ->
            Just "I left part 2 running for nearly 24 hours and it still hadn‘t finished. So, giving up on that, I wrote a Perl 5 program based on the same algorithm and it only took 20 seconds! I estimate MD5 digests are roughly 100 times faster in Perl 5 than in Elm, so that‘s not the whole story since 100 times 20 seconds is only about half an hour."

        "2016-16" ->
            Just "The Elm program for part 2 crashed my browser window after a few minutes (presumably out of memory) so instead I wrote a Perl 5 program which got the answer in less than a minute while using almost 3GB of memory."

        "2016-23" ->
            Just "There was a strange error after converting from 0.18 to 0.19 which I couldn‘t figure out so I abandoned this one even though it had been working."

        "2020-13" ->
            Just "Elm can‘t handle 64-bit integers and could only solve the toy examples. For the proper part 2 problem, a Chinese Remainder algorithm from another language (I picked Ruby) had to be used."

        "2020-14" ->
            Just "Had to avoid Elm for this one because it involves 64-bit integers. A quick Ruby script did the job."

        "2020-20" ->
            Just "I couldn‘t figure out part 2 and used Github user Sharparam‘s ruby solution."

        "2021-14" ->
            Just "I have to admit to needing help for part 2 (link in code)."

        "2021-15" ->
            Just "I'm getting the right answer for part 2 with the example but not my input."

        _ ->
            Nothing


failed : Int -> Int -> Int -> Bool
failed year day part =
    let
        key =
            [ year, day, part ]
                |> List.map String.fromInt
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
