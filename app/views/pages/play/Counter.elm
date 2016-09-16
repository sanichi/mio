module Counter exposing (Model, increment, init, text)


type alias Model =
    Int


init : Model
init =
    0


increment : Model -> Model
increment counter =
    counter + 1


text : Model -> String
text counter =
    toString counter
