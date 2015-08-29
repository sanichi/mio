import Html exposing (Html)
import Http exposing (Error)
import Json.Decode
import Maybe exposing (Maybe)
import Signal exposing (Address)
import Task exposing (Task, andThen)
import Todo exposing (Todo, decodeTodo)
import Todos exposing (Todos)

-- MODEL

type alias Model = Todos

init : Model
init = [ ]

-- UPDATE

type Action
  = NoOp
  | SetTodos Todos


update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model

    SetTodos todos ->
      todos

-- VIEW

view : Model -> Html
view model =
  Todos.view model

-- SIGNALS

actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp


model : Signal Model
model = Signal.foldp update init actions.signal


main : Signal Html
main =
  Signal.map view model

-- TASKS

getCurrentTasks : Task Http.Error Todos
getCurrentTasks =
  Http.get (Json.Decode.list decodeTodo) "/todos.json"


port runner : Task Http.Error ()
port runner =
  getCurrentTasks `andThen` (SetTodos >> Signal.send actions.address)
