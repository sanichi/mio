module Y20D19 exposing (answer)

import Dict exposing (Dict)
import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        data =
            parse input
    in
    if part == 1 then
        data
            |> count
            |> String.fromInt

    else
        data
            |> edit
            |> count
            |> String.fromInt


type alias Sequence =
    List Int


type alias Rule =
    { str : Maybe String
    , seq : Maybe Sequence
    , alt : Maybe Sequence
    }


type alias Rules =
    List Rule


type alias Book =
    Dict Int Rule


type alias Data =
    { rules : Book
    , messages : List String
    }


count : Data -> Int
count data =
    data.messages
        |> List.map (test data.rules)
        |> List.filter identity
        |> List.length


edit : Data -> Data
edit data =
    let
        rule8 =
            Rule Nothing (Just [ 42 ]) (Just [ 42, 8 ])

        rule11 =
            Rule Nothing (Just [ 42, 31 ]) (Just [ 42, 11, 31 ])

        book =
            data.rules
                |> Dict.insert 8 rule8
                |> Dict.insert 11 rule11
    in
    { data | rules = book }


test : Book -> String -> Bool
test book message =
    let
        rules =
            [ Rule Nothing (Just [ 0 ]) Nothing ]
    in
    case expand book rules message of
        Just "" ->
            True

        _ ->
            False


expand : Book -> Rules -> String -> Maybe String
expand book rules message =
    case rules of
        rule :: rest ->
            case rule.str of
                Just c ->
                    if String.startsWith c message then
                        expand book rest (String.dropLeft 1 message)

                    else
                        Nothing

                _ ->
                    case [ rule.seq, rule.alt ] of
                        [ Just seq, Nothing ] ->
                            let
                                seqRules =
                                    List.filterMap (\num -> Dict.get num book) seq
                            in
                            expand book (seqRules ++ rest) message

                        [ Just seq, Just alt ] ->
                            let
                                seqRules =
                                    List.filterMap (\num -> Dict.get num book) seq

                                seqTry =
                                    expand book (seqRules ++ rest) message
                            in
                            if seqTry == Nothing then
                                let
                                    altRules =
                                        List.filterMap (\num -> Dict.get num book) alt
                                in
                                expand book (altRules ++ rest) message

                            else
                                seqTry

                        _ ->
                            Nothing

        _ ->
            Just message


parse : String -> Data
parse input =
    input
        |> Regex.split (Util.regex "\\n")
        |> List.map String.trim
        |> List.filter (\e -> String.length e > 0)
        |> parseLine (Data Dict.empty [])


parseLine : Data -> List String -> Data
parseLine data lines =
    case lines of
        line :: rest ->
            let
                data_ =
                    if Regex.contains (Util.regex "^\\d+:") line then
                        { data | rules = parseRule line data.rules }

                    else
                        { data | messages = line :: data.messages }
            in
            parseLine data_ rest

        _ ->
            data


parseRule : String -> Book -> Book
parseRule line rules =
    let
        m =
            line
                |> Regex.find (Util.regex "^(0|[1-9]\\d*): (?:\\\"([ab])\\\"|([1-9]\\d*(?: [1-9]\\d*)*))(?: \\| )?([1-9]\\d*(?: [1-9]\\d*)*)?")
                |> List.map .submatches
                |> List.head
                |> Maybe.withDefault []
    in
    case m of
        [ Just num, Nothing, seq, alt ] ->
            Dict.insert (toInt num) (Rule Nothing (toSeq seq) (toSeq alt)) rules

        [ Just num, str, Nothing, Nothing ] ->
            Dict.insert (toInt num) (Rule str Nothing Nothing) rules

        _ ->
            rules


toSeq : Maybe String -> Maybe Sequence
toSeq m =
    case m of
        Just list ->
            list
                |> String.split " "
                |> List.map String.toInt
                |> List.map (Maybe.withDefault 0)
                |> Just

        Nothing ->
            Nothing


toInt : String -> Int
toInt str =
    str
        |> String.toInt
        |> Maybe.withDefault 0


example : String
example =
    """
        0: 4 1 5
        1: 2 3 | 3 2
        2: 4 4 | 5 5
        3: 4 5 | 5 4
        4: "a"
        5: "b"

        ababbb
        bababa
        abbbab
        aaabbb
        aaaabbb
    """
