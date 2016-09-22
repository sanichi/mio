module Todos exposing (Todos, get)

import Html exposing (Html, table, tbody)
import Html.Attributes exposing (class)
import Http
import Json.Decode as Decode
import Task exposing (Task)
import Misc exposing (indexAndCreateUrl)
import Todo exposing (Todo)


type alias Todos =
    List Todo


get : Task Http.Error Todos
get =
    Http.get (Decode.list Todo.decode) indexAndCreateUrl
