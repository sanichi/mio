module BeginEnd exposing (begin, beginPref, beginDefault, end, endPref, endDefault)


-- TODO: do we really need this


beginPref : List Int -> Int
beginPref beginEnd =
    let
        months =
            beginEnd
                |> List.head
                |> Maybe.withDefault beginDefault
    in
    begin months


endPref : List Int -> Int
endPref beginEnd =
    let
        year =
            beginEnd
                |> List.reverse
                |> List.head
                |> Maybe.withDefault endDefault
    in
    begin year


begin : Int -> Int
begin months =
    if months < 0 then
        beginDefault

    else
        months


end : Int -> Int
end year =
    if year < 0 then
        endDefault

    else
        year


beginDefault : Int
beginDefault =
    2


endDefault : Int
endDefault =
    0
