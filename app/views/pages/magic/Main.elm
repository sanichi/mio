module Main exposing (Model, Msg(..), hexToInt, init, initModel, isMagic, main, nextNumber, reverse, subscriptions, update, view, viewButtonRow, viewNumberRow, viewRows, waitAMoment)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Encode exposing (Value)
import Ports



-- MAIN


main : Program Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> subscriptions
        }



-- MODEL


type alias Model =
    { current : Int
    , computed : List Int
    , thinking : Bool
    }


initModel : Model
initModel =
    { current = 10
    , computed = []
    , thinking = False
    }


init : Value -> ( Model, Cmd Msg )
init _ =
    ( initModel, Cmd.none )



-- UPDATE


type Msg
    = NextNumber
    | Continue ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NextNumber ->
            let
                newModel =
                    { model | thinking = True }
            in
            ( newModel, waitAMoment )

        Continue _ ->
            let
                num =
                    nextNumber model.current

                newModel =
                    { model | current = num + 1, computed = num :: model.computed, thinking = False }
            in
            ( newModel, Cmd.none )



-- COMMANDS & SUBSCRIPTIONS


subscriptions : Sub Msg
subscriptions =
    Ports.continue Continue


waitAMoment : Cmd Msg
waitAMoment =
    Ports.waitAMoment ()



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [ class "row" ]
            [ div [ class "col-xs-12 offset-sm-1 col-sm-10 offset-md-2 col-md-8 offset-lg-3 col-lg-6" ]
                [ table [ class "table table-bordered" ]
                    [ tbody []
                        (viewRows model)
                    ]
                ]
            ]
        ]


viewRows : Model -> List (Html Msg)
viewRows model =
    let
        numberRows =
            model.computed
                |> List.reverse
                |> List.map viewNumberRow

        buttonRow =
            viewButtonRow model
    in
    numberRows ++ [ buttonRow ]


viewNumberRow : Int -> Html Msg
viewNumberRow number =
    tr []
        [ th [ class "col-xs-6 text-center" ]
            [ number |> String.fromInt |> text ]
        , th [ class "col-xs-6 text-center" ]
            [ number |> reverse |> text ]
        ]


viewButtonRow : Model -> Html Msg
viewButtonRow model =
    let
        display =
            if List.length model.computed >= 5 then
                "none"

            else
                "table-row"

        rowStyle =
            style "display" display

        node =
            if model.thinking then
                img [ src "/images/loader.gif" ] []

            else
                button [ type_ "button", class "btn btn-success btn-sm", onClick NextNumber ] [ text "Next" ]
    in
    tr [ rowStyle ]
        [ td [ class "text-center", colspan 2 ] [ node ] ]



-- HELPERS


nextNumber : Int -> Int
nextNumber num =
    if isMagic num then
        num

    else
        nextNumber (num + 1)


reverse : Int -> String
reverse number =
    number
        |> String.fromInt
        |> String.reverse


hexToInt : String -> Int
hexToInt hex =
    let
        zero =
            Char.toCode '0'

        digitToInt index char =
            char
                |> Char.toCode
                |> (\code -> code - zero)
                |> (*) (16 ^ index)
    in
    hex
        |> String.reverse
        |> String.toList
        |> List.indexedMap digitToInt
        |> List.sum


isMagic : Int -> Bool
isMagic number =
    let
        number_ =
            number
                |> reverse
                |> hexToInt
    in
    number == number_
