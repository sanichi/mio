module Y20D04 exposing (answer)

import Dict exposing (Dict)
import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        passports =
            parse input
    in
    if part == 1 then
        passports
            |> List.filter valid
            |> List.length
            |> String.fromInt

    else
        passports
            |> List.filter byrValid
            |> List.filter iyrValid
            |> List.filter eyrValid
            |> List.filter hgtValid
            |> List.filter hclValid
            |> List.filter eclValid
            |> List.filter pidValid
            |> List.length
            |> String.fromInt


type alias Passport =
    Dict String String


valid : Passport -> Bool
valid p =
    List.all (\f -> Dict.member f p) [ "byr", "ecl", "eyr", "hcl", "hgt", "iyr", "pid" ]


byrValid : Passport -> Bool
byrValid p =
    checkYear p "byr" 1920 2002


iyrValid : Passport -> Bool
iyrValid p =
    checkYear p "iyr" 2010 2020


eyrValid : Passport -> Bool
eyrValid p =
    checkYear p "eyr" 2020 2030


hgtValid : Passport -> Bool
hgtValid p =
    let
        length =
            Dict.get "hgt" p |> Maybe.withDefault "" |> getLength
    in
    case length of
        Just ( v, "cm" ) ->
            150 <= v && v <= 193

        Just ( v, "in" ) ->
            59 <= v && v <= 76

        _ ->
            False


hclValid : Passport -> Bool
hclValid p =
    p
        |> Dict.get "hcl"
        |> Maybe.withDefault ""
        |> Regex.contains (Util.regex "^#[0-9a-f]{6}$")


eclValid : Passport -> Bool
eclValid p =
    p
        |> Dict.get "ecl"
        |> Maybe.withDefault ""
        |> Regex.contains (Util.regex "^(amb|blu|brn|gry|grn|hzl|oth)$")


pidValid : Passport -> Bool
pidValid p =
    p
        |> Dict.get "pid"
        |> Maybe.withDefault ""
        |> Regex.contains (Util.regex "^\\d{9}$")


checkYear : Passport -> String -> Int -> Int -> Bool
checkYear p f min max =
    let
        number =
            p
                |> Dict.get f
                |> Maybe.withDefault ""
                |> String.toInt
    in
    case number of
        Just year ->
            min <= year && year <= max

        Nothing ->
            False


getLength : String -> Maybe ( Int, String )
getLength input =
    let
        data =
            input
                |> Regex.find (Util.regex "^(\\d+)(cm|in)$")
                |> List.map .submatches
                |> List.head
                |> Maybe.withDefault [ Just "", Just "" ]
                |> List.map (Maybe.withDefault "")

        number =
            data
                |> List.head
                |> Maybe.withDefault ""
                |> String.toInt
                |> Maybe.withDefault 0
    in
    case data of
        [ _, "cm" ] ->
            Just ( number, "cm" )

        [ _, "in" ] ->
            Just ( number, "in" )

        _ ->
            Nothing


parse : String -> List Passport
parse input =
    input
        |> Regex.split (Util.regex "\\n\\n")
        |> List.map parsePassport


parsePassport : String -> Passport
parsePassport input =
    input
        |> Regex.find (Util.regex "(byr|cid|ecl|eyr|hcl|hgt|iyr|pid):([^\\s]+)")
        |> List.map .submatches
        |> List.filterMap
            (\m ->
                case m of
                    [ Just field, Just value ] ->
                        Just ( field, value )

                    _ ->
                        Nothing
            )
        |> Dict.fromList



-- example : String
-- example =
-- """
--     ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
--     byr:1937 iyr:2017 cid:147 hgt:183cm
--     iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
--     hcl:#cfa07d byr:1929
--     hcl:#ae17e1 iyr:2013
--     eyr:2024
--     ecl:brn pid:760753108 byr:1931
--     hgt:179cm
--     hcl:#cfa07d eyr:2025 pid:166559648
--     iyr:2011 ecl:brn hgt:59in
-- """
