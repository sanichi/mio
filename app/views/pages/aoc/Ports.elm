port module Ports exposing (..)

-- JS to Elm or Elm to Elm


port getData : ( Int, Int ) -> Cmd msg


port prepare : Int -> Cmd msg



-- Elm to JS


port gotData : (String -> msg) -> Sub msg


port answer : (Int -> msg) -> Sub msg
