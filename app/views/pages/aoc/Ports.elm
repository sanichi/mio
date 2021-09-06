port module Ports exposing (..)

-- Elm to JS or Elm to Elm


port getData : ( Int, Int ) -> Cmd msg


port prepare : Int -> Cmd msg


port useRuby : List Int -> Cmd msg



-- JS to Elm


port gotData : (String -> msg) -> Sub msg


port getAnswer : (Int -> msg) -> Sub msg


port gotAnswer : (( Int, String ) -> msg) -> Sub msg
