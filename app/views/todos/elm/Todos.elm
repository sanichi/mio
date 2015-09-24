module Todos where

import Html exposing (Html, table, tbody)
import Html.Attributes exposing (class)
import Http
import Json.Decode as Decode
import Misc exposing (indexAndCreateUrl)
import Task exposing (Task)
import Todo exposing (Todo, decodeTodo, todoCompare)

type alias Todos = List Todo
type alias TodosResult = Result Http.Error Todos

-- VIEW

view : Int -> Int -> Todos -> Html
view lastUpdated toDelete todos =
  let
    rows = List.map (Todo.view lastUpdated toDelete) <| List.sortWith todoCompare todos
  in
    table
      [ class "table table-bordered table-striped" ]
      [ tbody [ ] rows ]

-- OTHER

getInitialTodos : Task Http.Error TodosResult
getInitialTodos =
  Task.toResult <| Http.get (Decode.list decodeTodo) indexAndCreateUrl
