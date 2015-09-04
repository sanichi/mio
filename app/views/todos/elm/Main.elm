import Html exposing (Html)
import Http
import Json.Decode as Decode
import Maybe exposing (Maybe)
import Signal exposing (Address)
import Task exposing (Task)
import Todo exposing (Todo, decodeTodo, updates)
import Todos exposing (Todos)

-- MODEL

type alias Model = { todos: Todos, authToken: String, lastUpdated: Int }

init : Model
init = { todos = [ ], authToken = "noTokenYet", lastUpdated = 0 }

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
      { model
      | todos <- List.map (\m -> if m.id == todo.id then todo else m) model.todos
      , lastUpdated <- todo.id
      }

-- VIEW

view : Model -> Html
view model =
  Html.div []
    [ Todos.view model.lastUpdated model.todos
    , Html.p [] [ Html.text model.authToken]
    ]

-- SIGNALS

main : Signal Html
main =
  Signal.map view model


model : Signal Model
model =
  Signal.foldp update init actions


actions : Signal Action
actions =
  Signal.mergeMany
    [ box.signal
    , (Signal.map UpdateTodo updates.signal)
    , (Signal.map SetAuthToken getAuthToken)
    ]


box : Signal.Mailbox Action
box =
  Signal.mailbox NoOp

-- TASKS

getCurrTodos : Task Http.Error Todos
getCurrTodos =
  Http.get (Decode.list decodeTodo) "/todos.json"


sendCurrTodos : Todos -> Task Http.Error ()
sendCurrTodos todos =
  (Signal.send box.address << SetTodos) todos


port runner : Task Http.Error ()
port runner =
  getCurrTodos `Task.andThen` sendCurrTodos

port getAuthToken: Signal String
