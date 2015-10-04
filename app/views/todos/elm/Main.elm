import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Signal exposing (Address)
import Task exposing (Task)
import Todo exposing
  ( Todo
  , CreateResult, DeleteResult, UpdateResult
  , createTodo, deleteTodo, exampleTodo, updateTodo
  , cancellations, confirmations, creates, deletes, descriptions, edits, updates
  )
import Todos exposing (Todos, TodosResult, getTodos)

-- MODEL

type alias Model =
  { todos : Todos
  , lastUpdated : Int
  , maybeDelete : Int
  , error : Maybe String
  }


init : Model
init =
  { todos = [ ]
  , lastUpdated = 0
  , maybeDelete = 0
  , error = Nothing
  }

-- UPDATE

type Action
  = NoOp
  | AddNewTodo CreateResult
  | CancelDelete
  | ConfirmDelete Int
  | DeleteTodo DeleteResult
  | EditingDescription (Int, Bool)
  | UpdateDescription (Int, String)
  | UpdateTodo UpdateResult
  | SetTodos TodosResult


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    AddNewTodo result ->
      case result of
        Ok todo ->
          let
            newTodo t = if t.id == 0 then { t | newDescription <- "" } else t
            todo' = { todo | newDescription <- todo.description }
          in
            { model
            | todos <- todo' :: (List.map newTodo model.todos)
            , lastUpdated <- todo.id
            , error <- Nothing
            }

        Err msg -> { model | error <- Just (toString msg) }

    CancelDelete ->
      { model
      | maybeDelete <- 0
      , lastUpdated <- 0
      , error <- Nothing
      }

    ConfirmDelete id ->
      { model
      | maybeDelete <- id
      , lastUpdated <- id
      , error <- Nothing
      }

    DeleteTodo result ->
      case result of
        Ok id ->
          { model
          | todos <- List.filter (\t -> t.id /= id) model.todos
          , lastUpdated <- 0
          , maybeDelete <- 0
          , error <- Nothing
          }

        Err msg -> { model | error <- Just (toString msg) }

    EditingDescription (id, bool) ->
      let
        newTodo t = { t | editingDescription <- if t.id == id then bool else False }
      in
        { model | todos <- List.map newTodo model.todos }

    UpdateDescription (id, description) ->
      let
        newTodo t = if t.id == id then { t | newDescription <- description } else t
      in
        { model | todos <- List.map newTodo model.todos }

    UpdateTodo result ->
      case result of
        Ok todo ->
          let
            newTodo t =
              if t.id == todo.id
                then { todo | newDescription <- todo.description }
                else t
          in
            { model
            | todos <- List.map newTodo model.todos
            , lastUpdated <- todo.id
            , maybeDelete <- 0
            , error <- Nothing
            }

        Err msg -> { model | error <- Just (toString msg) }

    SetTodos result ->
      case result of
        Ok list ->
          let
            newTodo t =  { t | newDescription <- t.description }
            todos = List.map newTodo (exampleTodo :: list)
          in
            { model | todos <- todos, error <- Nothing }

        Err msg ->
          { model | error <- Just (toString msg) }

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
      , Todos.view model.lastUpdated model.maybeDelete model.todos
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
    , Signal.map EditingDescription edits.signal
    , Signal.map UpdateDescription descriptions.signal
    , Signal.map ConfirmDelete confirmations.signal
    , Signal.map (always CancelDelete) cancellations.signal
    ]


mailBox : Signal.Mailbox Action
mailBox =
  Signal.mailbox NoOp


initTodos : TodosResult -> Task Http.Error ()
initTodos todos =
  Signal.send mailBox.address <| SetTodos todos


addTodo : CreateResult -> Task Http.Error ()
addTodo todo =
  Signal.send mailBox.address <| AddNewTodo todo


mergeTodo : UpdateResult -> Task Http.Error ()
mergeTodo todo =
  Signal.send mailBox.address <| UpdateTodo todo


removeTodo : DeleteResult -> Task Http.Error ()
removeTodo id =
  Signal.send mailBox.address <| DeleteTodo id

-- PORTS

port performIndex : Task Http.Error ()
port performIndex =
  getTodos `Task.andThen` initTodos


port performCreates : Signal (Task Http.Error ())
port performCreates =
  Signal.map (\todo -> createTodo todo `Task.andThen` addTodo) creates.signal


port performUpdates : Signal (Task Http.Error ())
port performUpdates =
  Signal.map (\todo -> updateTodo todo `Task.andThen` mergeTodo) updates.signal


port performDeletes : Signal (Task Http.Error ())
port performDeletes =
  Signal.map (\id -> deleteTodo id `Task.andThen` removeTodo) deletes.signal
