module Todo where

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode exposing ((:=))

-- MODEL

type alias Todo =
  { description: String
  , done: Bool
  , id: Int
  , priority: Int
  , priority_: String
  }


decodeTodo : Json.Decode.Decoder Todo
decodeTodo =
  Json.Decode.object5 Todo
    ("description" := Json.Decode.string)
    ("done" := Json.Decode.bool)
    ("id" := Json.Decode.int)
    ("priority" := Json.Decode.int)
    ("priority_" := Json.Decode.string)

-- VIEW

cellClass : Todo -> String
cellClass todo =
  if todo.done then "inactive" else "active"


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
view todo =
  tr [ ]
    [ td [ ]
        [ span [ class (cellClass todo) ] [ text todo.description ] ]
    , td [ class "col-md-2" ]
        [ span [ class (cellClass todo) ] [ text todo.priority_ ] ]
    ]
