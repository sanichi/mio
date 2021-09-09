port module Ports exposing (..)

-- Elm to JS or Elm to Elm


port getData : ( Int, Int ) -> Cmd msg


port startThink : Int -> Cmd msg


port getRuby : List Int -> Cmd msg



-- JS to Elm


port gotData : (String -> msg) -> Sub msg


port startedThink : (Int -> msg) -> Sub msg


port gotRuby : (( Int, String ) -> msg) -> Sub msg
