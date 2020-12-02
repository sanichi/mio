module Y20D02 exposing (answer)

import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        example =
            parse "1-3 a: abcde 1-3 b: cdefg 2-9 c: ccccccccc"

        passwords =
            parse input
    in
    if part == 1 then
        passwords
            |> List.filter valid
            |> List.length
            |> String.fromInt

    else
        example
            |> List.filter valid
            |> List.length
            |> String.fromInt


type alias Password =
    { min : Int
    , max : Int
    , letter : String
    , password : String
    }


valid : Password -> Bool
valid p =
    let
        count =
            String.indices p.letter p.password |> List.length
    in
    p.min <= count && p.max >= count


parse : String -> List Password
parse input =
    input
        |> Regex.find (Util.regex "(\\d+)-(\\d+) ([a-z]): ([a-z]+)")
        |> List.map .submatches
        |> List.filterMap parsePassword


parsePassword : List (Maybe String) -> Maybe Password
parsePassword submatches =
    case submatches of
        [ Just min_, Just max_, Just letter, Just password ] ->
            let
                min =
                    String.toInt min_ |> Maybe.withDefault 0

                max =
                    String.toInt max_ |> Maybe.withDefault 0
            in
            Just (Password min max letter password)

        _ ->
            Nothing
