module Picture exposing (..)

import Types exposing (Person)


picturePath : Int -> Person -> String
picturePath picture person =
    let
        total =
            Array.length person.pictures

        index =
            if total < 1 then
                0
            else
                picture % total
    in
        Array.get index person.pictures |> Maybe.withDefault defaultPicturePath


defaultPicturePath : String
defaultPicturePath =
    "/images/blank_woman.png"
