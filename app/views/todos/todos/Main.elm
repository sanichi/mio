import Html exposing (Html)
import Http
import Json.Decode as Decode
import Maybe exposing (Maybe)
import Signal exposing (Address)
import Task exposing (Task)
import Todo exposing (Todo, decodeTodo, updates)
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
  | UpdateTodo Todo


update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model

    SetTodos list ->
      { model | todos <- list }

    SetAuthToken value ->
      { model | authToken <- value }

    UpdateTodo todo ->
      { model | todos <- List.map (\m -> if m.id == todo.id then todo else m) model.todos }

-- VIEW

view : Model -> Html
view model =
  Html.div []
    [ Todos.view model.todos
    , Html.p [] [ Html.text model.authToken]
    ]

-- SIGNALS

actions : Signal.Mailbox Action
actions =
  Signal.mailbox NoOp


model : Signal Model
model =
  Signal.foldp update init <| Signal.mergeMany
    [ actions.signal
    , (Signal.map UpdateTodo updates.signal)
    , (Signal.map SetAuthToken getAuthToken)
    ]


main : Signal Html
main =
  Signal.map view model

-- TASKS

getCurrTodos : Task Http.Error Todos
getCurrTodos =
  Http.get (Decode.list decodeTodo) "/todos.json"


port runner : Task Http.Error ()
port runner =
  getCurrTodos `Task.andThen` (Signal.send actions.address << SetTodos)


port getAuthToken: Signal String
