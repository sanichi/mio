module Todo where

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http exposing (defaultSettings, empty, fromJson)
import Json.Decode as Decode exposing ((:=))
import Task exposing (Task, andThen)

-- MODEL

type alias Todo =
  { description: String
  , done: Bool
  , id: Int
  , priority: Int
  , priority_: String
  , priority_hi: Int
  , priority_low: Int
  }


decodeTodo : Decode.Decoder Todo
decodeTodo =
  Decode.object7 Todo
    ("description" := Decode.string)
    ("done" := Decode.bool)
    ("id" := Decode.int)
    ("priority" := Decode.int)
    ("priority_" := Decode.string)
    ("priority_hi" := Decode.int)
    ("priority_low" := Decode.int)

-- UPDATE

update : (Int, String) -> (Maybe (Task Http.Error Todo))
update action =
  case action of
    (id, "up") -> Just (updateTodo id)

    (id, "down") -> Just (updateTodo id)

    (id, "done") -> Just (updateTodo id)

    _ -> Nothing

-- VIEW

todoCompare : Todo -> Todo -> Order
todoCompare t1 t2 =
  if xor t1.done t2.done
    then (if t1.done then GT else LT)
    else
      ( if t1.priority == t2.priority
        then compare t1.description t2.description
        else compare t1.priority t2.priority
      )


view : Todo -> Html
view t =
  tr [ ]
    [ td [ ]
        [ span [ class (cellClass t) ] [ text t.description ] ]
    , td [ class "col-md-2" ]
        [ span [ class (cellClass t) ] [ text t.priority_ ] ]
    , td [ class "col-md-3 text-center" ]
        [ span [class "btn btn-info btn-xs"] [ text "✍" ]
        , text "\n"
        , span
          [ class "btn btn-info btn-xs"
          , onClick updates.address (t.id, "todos[priority]=" ++ (toString (t.priority + 1)))
          ]
          [ text "⬆︎" ]
        , text "\n"
        , span
          [class "btn btn-info btn-xs", onClick updates.address (t.id, "todos[priority]=" ++ (toString (t.priority - 1)))]
          [ text "⬇︎" ]
        , text "\n"
        , span
          [class "btn btn-success btn-xs", onClick updates.address (t.id, "todos[done]=" ++ (if t.done then "0" else "1"))]
          [ text "✔︎" ]
        ]
    ]

cellClass : Todo -> String
cellClass todo =
  if todo.done then "inactive" else "active"

-- SIGNALS

updates : Signal.Mailbox (Int, String)
updates = Signal.mailbox (0, "")

-- TASKS

updateTodo : Int -> Task Http.Error Todo
updateTodo id =
  let
    request =
      { verb = "PATCH"
      , headers = []
      , url = "/todos/" ++ (toString id) ++ "/update.json"
      , body = empty
      }
  in
    fromJson decodeTodo (Http.send defaultSettings request)
