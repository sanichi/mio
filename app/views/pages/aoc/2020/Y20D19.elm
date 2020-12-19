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
    List String


type alias Rule =
    { trm : Maybe String
    , seq : Maybe Sequence
    , alt : Maybe Sequence
    }


type alias Book =
    Dict String Rule


type alias Data =
    { book : Book
    , messages : List String
    }


count : Data -> Int
count data =
    data.messages
        |> List.map (test data.book)
        |> List.filter identity
        |> List.length


edit : Data -> Data
edit data =
    let
        r8 =
            Rule Nothing (Just [ "42" ]) (Just [ "42", "8" ])

        r11 =
            Rule Nothing (Just [ "42", "31" ]) (Just [ "42", "11", "31" ])

        book =
            data.book
                |> Dict.insert "8" r8
                |> Dict.insert "11" r11
    in
    { data | book = book }


test : Book -> String -> Bool
test book message =
    let
        start =
            [ Rule Nothing (Just [ "0" ]) Nothing ]

        remainder =
            consume book start message
    in
    case remainder of
        Just "" ->
            True

        _ ->
            False


consume : Book -> List Rule -> String -> Maybe String
consume book rules message =
    case rules of
        rule :: rest ->
            case rule.trm of
                Just c ->
                    if String.startsWith c message then
                        consume book rest (String.dropLeft 1 message)

                    else
                        Nothing

                _ ->
                    case [ rule.seq, rule.alt ] of
                        [ Just seq, Nothing ] ->
                            let
                                seqRules =
                                    List.filterMap (\num -> Dict.get num book) seq
                            in
                            consume book (seqRules ++ rest) message

                        [ Just seq, Just alt ] ->
                            let
                                seqRules =
                                    List.filterMap (\num -> Dict.get num book) seq

                                seqTry =
                                    consume book (seqRules ++ rest) message
                            in
                            if seqTry == Nothing then
                                let
                                    altRules =
                                        List.filterMap (\num -> Dict.get num book) alt
                                in
                                consume book (altRules ++ rest) message

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
                        { data | book = parseRule line data.book }

                    else
                        { data | messages = line :: data.messages }
            in
            parseLine data_ rest

        _ ->
            data


parseRule : String -> Book -> Book
parseRule line book =
    let
        m =
            line
                |> Regex.find (Util.regex "^(0|[1-9]\\d*): (?:\\\"([ab])\\\"|([1-9]\\d*(?: [1-9]\\d*)*))(?: \\| )?([1-9]\\d*(?: [1-9]\\d*)*)?")
                |> List.map .submatches
                |> List.head
                |> Maybe.withDefault []
    in
    case m of
        [ Just num, Just trm, Nothing, Nothing ] ->
            Dict.insert num (Rule (Just trm) Nothing Nothing) book

        [ Just num, Nothing, Just seq, Nothing ] ->
            Dict.insert num (Rule Nothing (toSeq seq) Nothing) book

        [ Just num, Nothing, Just seq, Just alt ] ->
            Dict.insert num (Rule Nothing (toSeq seq) (toSeq alt)) book

        _ ->
            book


toSeq : String -> Maybe Sequence
toSeq list =
    Just (String.split " " list)


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
