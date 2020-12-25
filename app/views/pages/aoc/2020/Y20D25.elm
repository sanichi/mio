module Y20D25 exposing (answer)

import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        keys =
            parse input
    in
    if part == 1 then
        keys
            |> secret
            |> String.fromInt

    else
        "no part two for this day"


type alias Key =
    { public : Int
    , loops : Int
    }


type alias Keys =
    { card : Key
    , door : Key
    }


secret : Keys -> Int
secret keys =
    transform keys.card.loops keys.door.public 1


parse : String -> Keys
parse input =
    let
        list =
            input
                |> Regex.find (Util.regex "\\d+")
                |> List.map .match
                |> List.map String.toInt
    in
    case list of
        [ Just card, Just door ] ->
            Keys (Key card (guess card)) (Key door (guess door))

        _ ->
            Keys (Key 0 0) (Key 0 0)


guess : Int -> Int
guess public =
    guess_ public 1 1


guess_ : Int -> Int -> Int -> Int
guess_ public loops value =
    let
        value_ =
            transform 1 7 value
    in
    if value_ == public then
        loops

    else
        guess_ public (loops + 1) value_


transform : Int -> Int -> Int -> Int
transform n subject value =
    if n <= 0 then
        value

    else
        transform (n - 1) subject (remainderBy 20201227 (subject * value))


example : String
example =
    "5764801 17807724"
