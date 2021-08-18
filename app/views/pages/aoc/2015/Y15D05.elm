module Y15D05 exposing (answer)

import Regex exposing (Regex)
import Util exposing (regex)


answer : Int -> String -> String
answer part input =
    let
        strings =
            Regex.find stringRgx input |> List.map .match
    in
    if part == 1 then
        countNice nice1 strings

    else
        countNice nice2 strings


countNice : (String -> Bool) -> List String -> String
countNice nice strings =
    strings |> List.filter nice |> List.length |> String.fromInt


nice1 : String -> Bool
nice1 string =
    let
        vowels =
            count vowelRgx string

        dubles =
            count dubleRgx string

        badies =
            count badieRgx string
    in
    vowels >= 3 && dubles > 0 && badies == 0


nice2 : String -> Bool
nice2 string =
    let
        pairs =
            count pairsRgx string

        twips =
            count twipsRgx string
    in
    pairs > 0 && twips > 0


count : Regex -> String -> Int
count rgx string =
    Regex.find rgx string |> List.length


stringRgx : Regex
stringRgx =
    regex "[a-z]{10,}"


vowelRgx : Regex
vowelRgx =
    regex "[aeiou]"


dubleRgx : Regex
dubleRgx =
    regex "(.)\\1"


badieRgx : Regex
badieRgx =
    regex "(:?ab|cd|pq|xy)"


pairsRgx : Regex
pairsRgx =
    regex "(..).*\\1"


twipsRgx : Regex
twipsRgx =
    regex "(.).\\1"
