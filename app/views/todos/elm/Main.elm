import Html exposing (Html)
import Http
import Json.Decode as Decode
import Signal exposing (Address)
import Task exposing (Task)
import Todo exposing (Todo, decodeTodo, exampleTodo, updateBody, updates, updateTodo)
import Todos exposing (Todos)

-- MODEL

type alias Model = { todos: Todos, token: String, lastUpdated: Int }

init : Model
init = { todos = [ ], token = "noAuthAtStart", lastUpdated = 0 }

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
      { model
      | todos <- List.map (\t -> { t | token <- model.token }) list
      }

    SetAuthToken value ->
      { model
      | token <- value
      , todos <- List.map (\t -> { t | token <- model.token }) model.todos
      }

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
    , Html.p [] [ Html.text model.token]
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

-- Rails URLs

indexUrl : String
indexUrl =
  "/todos.json"

-- TASKS

getCurrTodos : Task Http.Error Todos
getCurrTodos =
  Http.get (Decode.list decodeTodo) indexUrl


mergeCurrTodos : Todos -> Task Http.Error ()
mergeCurrTodos todos =
  (Signal.send box.address << SetTodos) todos

-- PORTS

port runner : Task Http.Error ()
port runner =
  getCurrTodos `Task.andThen` mergeCurrTodos

port getAuthToken: Signal String

port logUpdates : Signal String
port logUpdates =
  Signal.map (updateBody >> toString) updates.signal

port performUpdates : Signal (Task Http.Error String)
port performUpdates =
  Signal.map updateTodo updates.signal
