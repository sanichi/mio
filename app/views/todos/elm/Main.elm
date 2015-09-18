import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Json.Decode as Decode
import Signal exposing (Address)
import Task exposing (Task)
import Todo exposing (Todo, TodoResult, decodeTodo, exampleTodo, updateBody, updates, updateTodo)
import Todos exposing (Todos)

-- MODEL

type alias Model =
  { todos: Todos
  , token: String
  , lastUpdated: Int
  , error: Maybe String
  }


init : Model
init =
  { todos = [ ]
  , token = "noAuthAtStart"
  , lastUpdated = 0
  , error = Nothing
  }

-- UPDATE

type Action
  = NoOp
  | SetTodos TodosResult
  | SetAuthToken String
  | UpdateTodo TodoResult


update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model

    SetTodos result ->
      case result of
        Ok list ->
          { model
          | todos <- List.map (\t -> { t | token <- model.token }) list
          , error <- Nothing
          }

        Err msg -> { model | error <- Just (toString msg) }

    SetAuthToken value ->
      { model
      | token <- value
      , todos <- List.map (\t -> { t | token <- value }) model.todos
      }

    UpdateTodo result ->
      case result of
        Ok todo ->
          let
            todo' = { todo | token <- model.token }
          in
            { model
            | todos <- List.map (\t -> if t.id == todo.id then todo' else t) model.todos
            , lastUpdated <- todo.id
            , error <- Nothing
            }

        Err msg -> { model | error <- Just (toString msg) }

-- VIEW

view : Model -> Html
view model =
  let
    error =
      case model.error of
        Just msg ->
          Html.p [ ] [ Html.text ("Error: " ++ msg) ]

        Nothing ->
          Html.p [ Attr.hidden True ] [ Html.text "No error" ]
  in
    Html.div []
      [ Todos.view model.lastUpdated model.todos
      , error
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
    , (Signal.map SetAuthToken getAuthToken)
    ]


box : Signal.Mailbox Action
box =
  Signal.mailbox NoOp

-- TASKS

type alias TodosResult = Result Http.Error Todos


getCurrTodos : Task Http.Error TodosResult
getCurrTodos =
  Task.toResult <| Http.get (Decode.list decodeTodo) "/todos.json"


mergeCurrTodos : TodosResult -> Task Http.Error ()
mergeCurrTodos todos =
  Signal.send box.address <| SetTodos todos


mergeTodo : TodoResult -> Task Http.Error ()
mergeTodo todo =
  Signal.send box.address <| UpdateTodo todo

-- PORTS

port runner : Task Http.Error ()
port runner =
  getCurrTodos `Task.andThen` mergeCurrTodos

port getAuthToken: Signal String

port performUpdates : Signal (Task Http.Error ())
port performUpdates =
  Signal.map (\todo -> updateTodo todo `Task.andThen` mergeTodo) updates.signal
