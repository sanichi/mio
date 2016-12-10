module Y16D10 exposing (answers)

import Dict exposing (Dict)
import Regex
import Util


answers : String -> String
answers input =
    let
        model =
            parse input

        a1 =
            lookfor 17 61 model

        a2 =
            model.instructions
                |> Dict.size
                |> toString
    in
        Util.join a1 a2


lookfor : Value -> Value -> Model -> String
lookfor low high model =
    let
        activeBots =
            model.bots
                |> Dict.filter (\_ bot -> active bot)
                |> Dict.values
    in
        case activeBots of
            [ bot ] ->
                case ( bot.lowVal, bot.highVal ) of
                    ( Just low, Just high ) ->
                        toString bot.id

                    _ ->
                        let
                            newModel =
                                step bot model
                        in
                            case newModel.error of
                                Nothing ->
                                    lookfor low high newModel

                                Just err ->
                                    err

            _ ->
                "no single active bot"


step : Bot -> Model -> Model
step bot model =
    case ( bot.lowVal, bot.highVal, bot.instruction ) of
        ( Just low, Just high, Just ( lowTarget, highTarget ) ) ->
            let
                newBot =
                    { bot | lowVal = Nothing, highVal = Nothing }

                newModel =
                    { model | bots = Dict.insert bot.id newBot model.bots }

                newLowModel =
                    case lowTarget of
                        BotTarget id ->
                            let
                                lowBot =
                                    Dict.get id model.bots
                            in
                                case lowBot of
                                    Nothing ->
                                        { newModel | error = "can't find bot " ++ (toString id) |> Just }

                                    Just existingBot ->
                                        let
                                            newExistingBot =
                                                newVal low existingBot
                                        in
                                            { newModel | bots = Dict.insert id newExistingBot newModel.bots }

                        OutputTarget id ->
                            let
                                lowOutput =
                                    Dict.get id model.outputs

                                newOutput =
                                    case lowOutput of
                                        Nothing ->
                                            Output id [ low ]

                                        Just o ->
                                            { o | values = low :: o.values }
                            in
                                { newModel | outputs = Dict.insert id newOutput newModel.outputs }
            in
                { model | error = Just "xxx" }

        _ ->
            { model | error = "can't step bot" ++ (toString bot) |> Just }


type Target
    = BotTarget Int
    | OutputTarget Int


type alias Value =
    Int


type alias Bot =
    { id : Int
    , lowVal : Maybe Value
    , highVal : Maybe Value
    , instruction : Maybe ( Target, Target )
    }


type alias Output =
    { id : Int
    , values : List Value
    }


type alias Model =
    { bots : Dict Int Bot
    , outputs : Dict Int Output
    , instructions : Dict Value Target
    , error : Maybe String
    }


init : Model
init =
    { bots =
        Dict.empty
            |> Dict.insert 1 (Bot 1 (Just 3) Nothing Nothing)
            |> Dict.insert 2 (Bot 2 (Just 2) (Just 5) Nothing)
    , outputs = Dict.empty
    , instructions = Dict.empty
    , error = Nothing
    }


parse : String -> Model
parse input =
    let
        highLow =
            "bot (\\d+) gives low to (bot|output) (\\d+) and high to (bot|output) (\\d+)"

        specific =
            "value (\\d+) goes to (bot|output) (\\d+)"

        pattern =
            highLow ++ "|" ++ specific
    in
        input
            |> Regex.find Regex.All (Regex.regex pattern)
            |> List.map .submatches
            |> process init


process : Model -> List (List (Maybe String)) -> Model
process model matches =
    case matches of
        [] ->
            model

        match :: rest ->
            let
                newModel =
                    case match of
                        [ Just n1, Just s1, Just n2, Just s2, Just n3, Nothing, Nothing, Nothing ] ->
                            let
                                id =
                                    toInt n1

                                low =
                                    toInt n2

                                high =
                                    toInt n3

                                lowTarget =
                                    targetConstructor s1

                                highTarget =
                                    targetConstructor s2
                            in
                                case [ id, low, high ] of
                                    [ Just i, Just l, Just h ] ->
                                        let
                                            instruction =
                                                Just ( lowTarget l, highTarget h )

                                            oldBot =
                                                Dict.get i model.bots

                                            newBot =
                                                case oldBot of
                                                    Nothing ->
                                                        Bot i Nothing Nothing instruction

                                                    Just bot ->
                                                        { bot | instruction = instruction }
                                        in
                                            { model | bots = Dict.insert i newBot model.bots }

                                    _ ->
                                        model

                        [ Nothing, Nothing, Nothing, Nothing, Nothing, Just v, Just s, Just n ] ->
                            let
                                id =
                                    toInt n

                                value =
                                    toInt v

                                target =
                                    targetConstructor s
                            in
                                case [ id, value ] of
                                    [ Just i, Just v ] ->
                                        { model | instructions = Dict.insert v (target i) model.instructions }

                                    _ ->
                                        model

                        _ ->
                            model
            in
                process newModel rest


active : Bot -> Bool
active bot =
    case ( bot.lowVal, bot.highVal, bot.instruction ) of
        ( Just _, Just _, Just _ ) ->
            True

        _ ->
            False


newVal : Int -> Bot -> Bot
newVal val bot =
    case ( bot.lowVal, bot.highVal ) of
        ( Nothing, Nothing ) ->
            { bot | lowVal = Just val }

        ( Just low, Nothing ) ->
            if val > low then
                { bot | highVal = Just val }
            else if val < low then
                { bot | lowVal = Just val, highVal = Just low }
            else
                bot

        ( Nothing, Just high ) ->
            if val < high then
                { bot | lowVal = Just val }
            else if val > high then
                { bot | lowVal = Just high, highVal = Just val }
            else
                bot

        ( Just low, Just high ) ->
            if val < low then
                { bot | lowVal = Just val }
            else if val > high then
                { bot | highVal = Just val }
            else
                bot


targetConstructor : String -> (Int -> Target)
targetConstructor s =
    if s == "bot" then
        BotTarget
    else
        OutputTarget


toInt : String -> Maybe Int
toInt string =
    string
        |> String.toInt
        |> Result.toMaybe
