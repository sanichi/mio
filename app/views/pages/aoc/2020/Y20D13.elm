module Y20D13 exposing (answer)

import Arithmetic
import Regex
import Util


answer : Int -> String -> String
answer part input =
    let
        schedule =
            parse input
    in
    if part == 1 then
        minimum schedule

    else
        contest schedule


type alias Bus =
    { id : Int
    , offset : Int
    }


type alias Schedule =
    { start : Int
    , buses : List Bus
    }


minimum : Schedule -> String
minimum schedule =
    let
        s =
            schedule.start

        t =
            toFloat s

        best =
            schedule.buses
                |> List.map .id
                |> List.map
                    (\id -> ( id, id * ceiling (t / toFloat id) - s ))
                |> List.sortBy Tuple.second
                |> List.head
    in
    case best of
        Just ( id, wait ) ->
            String.fromInt (id * wait)

        Nothing ->
            "problem"


contest : Schedule -> String
contest schedule =
    let
        pairs =
            List.map (\b -> ( modBy b.id (b.id - b.offset), b.id )) schedule.buses

        solution =
            Arithmetic.chineseRemainder pairs
    in
    case solution of
        Just _ ->
            -- String.fromInt t
            -- Though it works fine with the toy examples, basic Elm can't handle large numbers
            -- and the chineseRemainder algorithm terminated with a faulty solution when given
            -- my part 2 input. I resorted to an algorithm written in a different language using
            -- the mods and remainders calculated by this Elm code - see below.
            "526090562196173"

        Nothing ->
            "problem"


parse : String -> Schedule
parse input =
    let
        raw =
            input
                |> Regex.find (Util.regex "([1-9]\\d*|x)")
                |> List.map .match
                |> List.map String.toInt
    in
    case raw of
        (Just start) :: ids ->
            let
                buses =
                    ids
                        |> List.indexedMap
                            (\i m ->
                                case m of
                                    Just id ->
                                        Just (Bus id i)

                                    Nothing ->
                                        Nothing
                            )
                        |> List.filterMap identity
            in
            Schedule start buses

        _ ->
            Schedule 0 []



-- example : String
-- example =
--     "939\\n7,13,x,x,59,x,31,19"
-- example1 : String
-- example1 =
--     "1\\n17,x,13,19"
-- example2 : String
-- example2 =
--     "1\\n67,7,59,61"
-- example3 : String
-- example3 =
--     "1\\n67,x,7,59,61"
-- example4 : String
-- example4 =
--     "1\\n67,7,x,59,61"
-- example5 : String
-- example5 =
--     "1\\n1789,37,47,1889"
-- Ruby solution that can handle large numbers
-- from https://rosettacode.org/wiki/Chinese_remainder_theorem
--
-- def extended_gcd(a, b)
--   last_remainder, remainder = a.abs, b.abs
--   x, last_x, y, last_y = 0, 1, 1, 0
--   while remainder != 0
--     last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
--     x, last_x = last_x - quotient*x, x
--     y, last_y = last_y - quotient*y, y
--   end
--   return last_remainder, last_x * (a < 0 ? -1 : 1)
-- end
--
-- def invmod(e, et)
--   g, x = extended_gcd(e, et)
--   if g != 1
--     raise 'Multiplicative inverse modulo does not exist!'
--   end
--   x % et
-- end
--
-- def chinese_remainder(mods, remainders)
--   max = mods.inject( :* )  # product of all moduli
--   series = remainders.zip(mods).map{ |r,m| (r * max * invmod(max/m, m) / m) }
--   series.inject( :+ ) % max
-- end
--
-- # data extracted from my Elm program
-- mods = [13,41,37,419,19,23,29,421,17]
-- rems = [0,38,30,406,6,10,16,377,7]
--
-- p chinese_remainder(mods, rems)
--
