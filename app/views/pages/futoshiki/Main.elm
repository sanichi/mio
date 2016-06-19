import Html
import Html.App exposing (beginnerProgram)
import Svg exposing (..)
import Svg.Attributes exposing (..)


main =
  beginnerProgram { model = 0, view = view, update = update }


view model =
  svg
    [ id "futoshiki", version "1.1", viewBox "0 0 1000 1000" ]
    [ Svg.title [] [ text "Futoshiki" ]
    , desc [] [ text "Interactive Futoshiki solver" ]
    , rect [ width "100%", height "100%", rx "5", ry "5", class "background" ] []
    ]
    -- %desc Interactive map of Rennies Isle including blocks, flats and parking bays.
    -- %rect{width: "100%", height: "100%", class: "background"}


type Msg = Increment | Decrement

update msg model =
  case msg of
    Increment ->
      model + 1

    Decrement ->
      model - 1
