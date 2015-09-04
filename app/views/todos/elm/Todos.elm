module Todos where

import Html exposing (Html, table, tbody)
import Html.Attributes exposing (class)
import Todo exposing (Todo, todoCompare)

type alias Todos = List Todo

-- VIEW

view : Int -> Todos -> Html
view lastUpdated todos =
  table
    [ class "table table-bordered table-striped" ]
    [ tbody [ ] (List.map (Todo.view lastUpdated) (List.sortWith todoCompare todos)) ]
