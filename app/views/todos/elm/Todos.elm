module Todos where

import Html exposing (Html, table, tbody)
import Html.Attributes exposing (class)
import Todo exposing (Todo, todoCompare)

type alias Todos = List Todo

-- VIEW

view : Int -> Int -> Todos -> Html
view lastUpdated toDelete todos =
  let
    rows = List.map (Todo.view lastUpdated toDelete) <| List.sortWith todoCompare todos
  in
    table
      [ class "table table-bordered table-striped" ]
      [ tbody [ ] rows ]
