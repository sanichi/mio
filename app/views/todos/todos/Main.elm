import Html exposing (Html, div, p, text)
import Http
import Json.Decode as Decode
import Maybe exposing (Maybe)
import Signal exposing (Address, merge, map)
import Task exposing (Task, andThen)
import Todo exposing (Todo, decodeTodo)
import Todos exposing (Todos)

-- MODEL

type alias Model = { todos: Todos, authToken: String }

init : Model
init = { todos = [ ], authToken = "noTokenYet" }

-- UPDATE

type Action
  = NoOp
  | SetTodos Todos
  | SetAuthToken String


update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model

    SetTodos list ->
      { model | todos <- list }

    SetAuthToken value ->
      { model | authToken <- value }

-- VIEW

view : Model -> Html
view model =
  div []
    [ Todos.view model.todos
    , p [] [ text model.authToken]
    ]

-- SIGNALS

actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp


model : Signal Model
model = Signal.foldp update init (merge actions.signal (map SetAuthToken getAuthToken))


main : Signal Html
main =
  Signal.map view model

-- TASKS

getCurrTodos : Task Http.Error Todos
getCurrTodos =
  Http.get (Decode.list decodeTodo) "/todos.json"


port runner : Task Http.Error ()
port runner =
  getCurrTodos `andThen` (Signal.send actions.address << SetTodos)


port getAuthToken: Signal String
