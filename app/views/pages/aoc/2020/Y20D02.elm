module Y20D02 exposing (answer)

import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        passwords =
            parse input
    in
    if part == 1 then
        passwords
            |> List.filter valid1
            |> List.length
            |> String.fromInt

    else
        passwords
            |> List.filter valid2
            |> List.length
            |> String.fromInt


type alias Password =
    { n1 : Int
    , n2 : Int
    , letter : String
    , password : String
    }


valid1 : Password -> Bool
valid1 p =
    let
        count =
            String.indices p.letter p.password |> List.length
    in
    p.n1 <= count && p.n2 >= count


valid2 : Password -> Bool
valid2 p =
    let
        l1 =
            String.slice (p.n1 - 1) p.n1 p.password

        l2 =
            String.slice (p.n2 - 1) p.n2 p.password
    in
    xor (l1 == p.letter) (l2 == p.letter)


parse : String -> List Password
parse input =
    input
        |> Regex.find (Util.regex "([1-9]\\d*)-([1-9]\\d*) ([a-z]): ([a-z]+)")
        |> List.map .submatches
        |> List.filterMap parsePassword


parsePassword : List (Maybe String) -> Maybe Password
parsePassword submatches =
    case submatches of
        [ Just n1_, Just n2_, Just letter, Just password ] ->
            case ( String.toInt n1_, String.toInt n2_ ) of
                ( Just n1, Just n2 ) ->
                    Just (Password n1 n2 letter password)

                _ ->
                    Nothing

        _ ->
            Nothing


example : String
example =
    "1-3 a: abcde 1-3 b: cdefg 2-9 c: ccccccccc"
