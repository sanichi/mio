module Y15D05 exposing (answers)

import Regex exposing (HowMany(All), Regex, find, regex)
import Util


answers : String -> String
answers input =
    let
        strings =
            find All stringRgx input |> List.map .match

        p1 =
            countNice nice1 strings

        p2 =
            countNice nice2 strings
    in
        Util.join p1 p2


countNice : (String -> Bool) -> List String -> String
countNice nice strings =
    strings |> List.filter nice |> List.length |> toString


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
    find All rgx string |> List.length


stringRgx =
    regex "[a-z]{10,}"


vowelRgx =
    regex "[aeiou]"


dubleRgx =
    regex "(.)\\1"


badieRgx =
    regex "(:?ab|cd|pq|xy)"


pairsRgx =
    regex "(..).*\\1"


twipsRgx =
    regex "(.).\\1"
