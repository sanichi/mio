module Todo where

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)

-- MODEL

type alias Todo =
  { description: String
  , priority: Int
  , priority_desc: String
  , done: Bool
  }

type alias Model = List Todo

-- UPDATE

type Action = Increment | Decrement

update : Action -> Model -> Model
update action model =
  model

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

tableRow : Todo -> Html
tableRow todo =
  tr [ ]
    [ td [ ]
        [ span [ class (cellClass todo) ] [ text todo.description ] ]
    , td [ class "col-md-2" ]
        [ span [ class (cellClass todo) ] [ text todo.priority_desc ] ]
    ]

view : Signal.Address Action -> Model -> Html
view address model =
  table [ class "table table-bordered table-striped" ]
    [ tbody [ ]
        (List.map tableRow (List.sortWith todoCompare model))
    ]
