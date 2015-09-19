import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Json.Decode as Decode
import Signal exposing (Address)
import Task exposing (Task)
import Todo exposing
  ( Todo, UpdateResult, DeleteResult
  , exampleTodo, decodeTodo, updateTodo, deleteTodo
  , edits, descriptions, updates, deletes
  )
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
  | EditingDescription (Int, Bool)
  | SetTodos TodosResult
  | SetAuthToken String
  | UpdatingDescription (Int, String)
  | UpdateTodo UpdateResult
  | DeleteTodo DeleteResult


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    SetTodos result ->
      case result of
        Ok list ->
          let
            newTodo t =  { t | token <- model.token, newDescription <- t.description }
          in
            { model | todos <- List.map newTodo list, error <- Nothing }

        Err msg ->
          { model | error <- Just (toString msg) }

    UpdateTodo result ->
      case result of
        Ok todo ->
          let
            newTodo t =
              if t.id == todo.id
              then { todo | token <- model.token, newDescription <- todo.description }
              else t
          in
            { model
            | todos <- List.map newTodo model.todos
            , lastUpdated <- todo.id
            , error <- Nothing
            }

        Err msg -> { model | error <- Just (toString msg) }

    DeleteTodo result ->
      case result of
        Ok id ->
          { model
          | todos <- List.filter (\t -> t.id /= id) model.todos
          , lastUpdated <- 0
          , error <- Nothing
          }

        Err msg -> { model | error <- Just (toString msg) }

    EditingDescription (id, bool) ->
      let
        newTodo t = { t | editing <- if t.id == id then bool else False }
      in
        { model | todos <- List.map newTodo model.todos }

    UpdatingDescription (id, description) ->
      let
        newTodo t = if t.id == id then { t | newDescription <- description } else t
      in
        { model | todos <- List.map newTodo model.todos }

    SetAuthToken value ->
      let
        newTodo t = { t | token <- value }
      in
        { model | todos <- List.map newTodo model.todos, token <- value }

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
      [ error
      , Todos.view model.lastUpdated model.todos
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
    [ mailBox.signal
    , (Signal.map SetAuthToken getAuthToken)
    , (Signal.map EditingDescription edits.signal)
    , (Signal.map UpdatingDescription descriptions.signal)
    ]


mailBox : Signal.Mailbox Action
mailBox =
  Signal.mailbox NoOp

-- TASKS

type alias TodosResult = Result Http.Error Todos


getCurrTodos : Task Http.Error TodosResult
getCurrTodos =
  Task.toResult <| Http.get (Decode.list decodeTodo) "/todos.json"


mergeCurrTodos : TodosResult -> Task Http.Error ()
mergeCurrTodos todos =
  Signal.send mailBox.address <| SetTodos todos


mergeTodo : UpdateResult -> Task Http.Error ()
mergeTodo todo =
  Signal.send mailBox.address <| UpdateTodo todo


removeTodo : DeleteResult -> Task Http.Error ()
removeTodo id =
  Signal.send mailBox.address <| DeleteTodo id

-- PORTS

port runner : Task Http.Error ()
port runner =
  getCurrTodos `Task.andThen` mergeCurrTodos


port performUpdates : Signal (Task Http.Error ())
port performUpdates =
  Signal.map (\todo -> updateTodo todo `Task.andThen` mergeTodo) updates.signal


port performDeletes : Signal (Task Http.Error ())
port performDeletes =
  Signal.map (\todo -> deleteTodo todo `Task.andThen` removeTodo) deletes.signal


port getAuthToken: Signal String
