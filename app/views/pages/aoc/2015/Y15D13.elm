module Y15D13 exposing (answer)

import Dict exposing (Dict)
import Regex exposing (HowMany(AtMost), find, regex)
import Set exposing (Set)
import Util


answer : Int -> String -> String
answer part input =
    if part == 1 then
        input
            |> parse
            |> happinesses
            |> List.maximum
            |> Maybe.withDefault 0
            |> toString
    else
        input
            |> parse
            |> addMe
            |> happinesses
            |> List.maximum
            |> Maybe.withDefault 0
            |> toString


happinesses : Model -> List Int
happinesses model =
    let
        f ( p1, p2 ) =
            pairValue p1 p2 model.happiness
    in
        Util.permutations (Set.toList model.people)
            |> List.map (\perm -> pairup perm)
            |> List.map (\pairs -> List.map f pairs |> List.sum)


pairValue : String -> String -> Dict String Int -> Int
pairValue p1 p2 h =
    let
        v1 =
            Dict.get (key p1 p2) h |> Maybe.withDefault 0

        v2 =
            Dict.get (key p2 p1) h |> Maybe.withDefault 0
    in
        v1 + v2


addMe : Model -> Model
addMe model =
    let
        me =
            "Me"

        p =
            Set.insert me model.people

        a =
            Set.toList model.people

        h0 =
            model.happiness

        h1 =
            List.foldl (\p h -> Dict.insert (key me p) 0 h) h0 a

        h2 =
            List.foldl (\p h -> Dict.insert (key p me) 0 h) h1 a
    in
        { happiness = h2, people = p }


parse : String -> Model
parse input =
    String.split "\n" input
        |> List.filter (\l -> l /= "")
        |> List.foldl parseLine initModel


parseLine : String -> Model -> Model
parseLine line model =
    let
        matches =
            find (AtMost 1) (regex "^(\\w+) would (gain|lose) (\\d+) happiness units by sitting next to (\\w+)\\.$") line |> List.map .submatches
    in
        case matches of
            [ [ Just p1, Just gl, Just i, Just p2 ] ] ->
                let
                    j =
                        String.toInt i |> Result.withDefault 0

                    k =
                        if gl == "gain" then
                            j
                        else
                            -j

                    h =
                        Dict.insert (key p1 p2) k model.happiness

                    p =
                        model.people |> Set.insert p1 |> Set.insert p2
                in
                    { happiness = h, people = p }

            _ ->
                model


key : String -> String -> String
key p1 p2 =
    p1 ++ "|" ++ p2


pairup : List a -> List ( a, a )
pairup list =
    let
        pairs =
            inner list

        pair =
            outer list
    in
        case pair of
            Just ( l, f ) ->
                ( l, f ) :: pairs

            _ ->
                pairs


inner : List a -> List ( a, a )
inner list =
    case list of
        x :: y :: rest ->
            ( x, y ) :: inner (y :: rest)

        _ ->
            []


outer : List a -> Maybe ( a, a )
outer list =
    let
        first =
            List.head list

        last =
            List.reverse list |> List.head
    in
        case ( first, last ) of
            ( Just f, Just l ) ->
                Just ( l, f )

            _ ->
                Nothing


type alias Model =
    { happiness : Dict String Int
    , people : Set String
    }


initModel =
    { happiness = Dict.empty
    , people = Set.empty
    }
