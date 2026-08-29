module Model exposing
    ( Cross
    , Model
    , changeBegin
    , changeCross
    , crossPoint
    , debugMsg
    , init
    , inWindow
    , toggleStation
    , updateCross
    , windowIndices
    )

import Array
import Data exposing (Data, Point, Series)
import Preferences exposing (Preferences)
import Station exposing (Stations)
import Transform exposing (Transform)


type alias Cross =
    { station : Int
    , point : Int
    }


type alias Model =
    { stations : Stations
    , data : Data
    , begin : Int
    , transform : Transform
    , cross : Maybe Cross
    , debug : Bool
    }


init : Preferences -> Model
init preferences =
    let
        stations =
            Station.combine preferences.stationNames preferences.stationColours

        data =
            Data.combine (Array.length stations) preferences.stations preferences.dates preferences.prices

        begin =
            preferences.begin

        transform =
            Transform.fromData stations data begin

        model =
            Model stations data begin transform Nothing preferences.debug
    in
    { model | cross = latestCross model }


debugMsg : Model -> String
debugMsg model =
    String.join " | "
        [ String.fromInt (Array.length model.stations) ++ " stations"
        , String.fromInt (List.length (everyPoint model.data)) ++ " points"
        , String.fromInt model.begin ++ "m"
        , String.fromInt model.transform.dLow ++ ".." ++ String.fromInt model.transform.dHgh
        , String.fromInt (round model.transform.pLow) ++ ".." ++ String.fromInt (round model.transform.pHgh)
        ]


changeBegin : Int -> Model -> Model
changeBegin begin model =
    reframe { model | begin = begin }


toggleStation : Int -> Model -> Model
toggleStation index model =
    reframe { model | stations = Station.toggle index model.stations }


{-| Snap the selection to whichever visible point is nearest, on screen, to
where the user clicked.
-}
changeCross : ( Int, Int ) -> Model -> Model
changeCross ( x, y ) model =
    let
        distance ( cross, point ) =
            let
                ( px, py ) =
                    Transform.transform model.transform point
            in
            ( (px - x) ^ 2 + (py - y) ^ 2, cross )

        nearest =
            selectable model
                |> List.map distance
                |> List.sortBy Tuple.first
                |> List.head
                |> Maybe.map Tuple.second
    in
    case nearest of
        Just cross ->
            { model | cross = Just cross }

        Nothing ->
            model


{-| Move the selection along the current station's line, or up and down the
legend to another station, staying put when there is nowhere to go.
-}
updateCross : ( Int, Int ) -> Model -> Model
updateCross ( dPoint, dStation ) model =
    case model.cross of
        Nothing ->
            { model | cross = latestCross model }

        Just cross ->
            let
                moved =
                    if dStation /= 0 then
                        stepStation dStation cross model

                    else
                        stepPoint dPoint cross model
            in
            { model | cross = Just moved }


crossPoint : Model -> Maybe Point
crossPoint model =
    model.cross
        |> Maybe.andThen (\c -> Data.pointAt c.station c.point model.data)


inWindow : Transform -> Point -> Bool
inWindow t point =
    point.rata >= t.dLow && point.rata <= t.dHgh


{-| The positions in a station's series that fall inside the date window.
-}
windowIndices : Transform -> Series -> List Int
windowIndices t series =
    series
        |> Array.toIndexedList
        |> List.filter (\( _, point ) -> inWindow t point)
        |> List.map Tuple.first



-- Helpers


{-| Recompute the scales after something changed which stations or dates are
covered, keeping the current selection if it is still visible.
-}
reframe : Model -> Model
reframe model =
    let
        transform =
            Transform.fromData model.stations model.data model.begin

        reframed =
            { model | transform = transform }
    in
    if stillVisible reframed then
        reframed

    else
        { reframed | cross = latestCross reframed }


stillVisible : Model -> Bool
stillVisible model =
    case model.cross of
        Nothing ->
            False

        Just cross ->
            isShown cross.station model.stations
                && (Data.pointAt cross.station cross.point model.data
                        |> Maybe.map (inWindow model.transform)
                        |> Maybe.withDefault False
                   )


{-| Every point that could be selected, paired with the selection that would
reach it: those belonging to a shown station and lying inside the window.
-}
selectable : Model -> List ( Cross, Point )
selectable model =
    model.data
        |> Array.toIndexedList
        |> List.filter (\( station, _ ) -> isShown station model.stations)
        |> List.concatMap
            (\( station, series ) ->
                series
                    |> Array.toIndexedList
                    |> List.filter (\( _, point ) -> inWindow model.transform point)
                    |> List.map (\( index, point ) -> ( Cross station index, point ))
            )


latestCross : Model -> Maybe Cross
latestCross model =
    selectable model
        |> List.sortBy (\( _, point ) -> negate point.rata)
        |> List.head
        |> Maybe.map Tuple.first


stepPoint : Int -> Cross -> Model -> Cross
stepPoint delta cross model =
    let
        indices =
            windowIndices model.transform (Data.seriesAt cross.station model.data)

        positions =
            List.indexedMap Tuple.pair indices

        current =
            positions
                |> List.filter (\( _, index ) -> index == cross.point)
                |> List.head
                |> Maybe.map Tuple.first
    in
    case current of
        Nothing ->
            cross

        Just position ->
            let
                wanted =
                    clamp 0 (List.length indices - 1) (position + delta)
            in
            case nth wanted indices of
                Just index ->
                    { cross | point = index }

                Nothing ->
                    cross


{-| Walk up or down the legend to the next station that has something to show,
then land on whichever of its points is closest in date to the current one.
-}
stepStation : Int -> Cross -> Model -> Cross
stepStation delta cross model =
    let
        rata =
            Data.pointAt cross.station cross.point model.data
                |> Maybe.map .rata
                |> Maybe.withDefault model.transform.dHgh

        search station =
            if station < 0 || station >= Array.length model.stations then
                Nothing

            else if isShown station model.stations then
                case nearestIndex rata (windowIndices model.transform (Data.seriesAt station model.data)) station model of
                    Just index ->
                        Just (Cross station index)

                    Nothing ->
                        search (station + delta)

            else
                search (station + delta)
    in
    search (cross.station + delta) |> Maybe.withDefault cross


nearestIndex : Int -> List Int -> Int -> Model -> Maybe Int
nearestIndex rata indices station model =
    indices
        |> List.filterMap
            (\index ->
                Data.pointAt station index model.data
                    |> Maybe.map (\point -> ( abs (point.rata - rata), index ))
            )
        |> List.sortBy Tuple.first
        |> List.head
        |> Maybe.map Tuple.second


isShown : Int -> Stations -> Bool
isShown index stations =
    Array.get index stations |> Maybe.map .shown |> Maybe.withDefault False


everyPoint : Data -> List Point
everyPoint data =
    data |> Array.toList |> List.concatMap Array.toList


nth : Int -> List a -> Maybe a
nth n list =
    List.drop n list |> List.head
