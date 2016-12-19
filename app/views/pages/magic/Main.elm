module Main exposing (..)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
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


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- UPDATE


type Msg
    = NextNumber
    | Continue Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NextNumber ->
            let
                newModel =
                    { model | thinking = True }
            in
                newModel ! [ Ports.waitAMoment 100 ]

        Continue _ ->
            let
                num =
                    nextNumber model.current

                newModel =
                    { model | current = num + 1, computed = num :: model.computed, thinking = False }
            in
                newModel ! []



-- COMMANDS & SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.continue Continue



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [ class "row" ]
            [ div [ class "col-xs-12 col-sm-offset-1 col-sm-10 col-md-offset-2 col-md-8 col-lg-offset-3 col-lg-6" ]
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
            [ number |> toString |> text ]
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
            [ ( "display", display ) ]

        node =
            if model.thinking then
                img [ src "/images/loader.gif" ] []
            else
                button [ type_ "button", class "btn btn-success btn-sm", onClick NextNumber ] [ text "Next" ]
    in
        tr [ style rowStyle ]
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
        |> toString
        |> String.reverse


hexToInt : String -> Int
hexToInt hex =
    let
        zero =
            Char.toCode '0'

        add index char =
            char
                |> Char.toCode
                |> (\code -> code - zero)
                |> (*) (16 ^ index)
    in
        hex
            |> String.reverse
            |> String.toList
            |> List.indexedMap add
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
