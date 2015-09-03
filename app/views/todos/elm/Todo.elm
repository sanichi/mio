module Todo where

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events as Events
import Http
import Json.Decode as Decode exposing ((:=))
import Misc exposing (priorityHigh, priorityLow, priorityString)
import Task exposing (Task)

-- MODEL

type alias Todo =
  { description: String
  , done: Bool
  , id: Int
  , priority: Int
  }


noTodo : Todo
noTodo =
  { description = ""
  , done = True
  , id = 0
  , priority = 1
  }


decodeTodo : Decode.Decoder Todo
decodeTodo =
  Decode.object4 Todo
    ("description" := Decode.string)
    ("done" := Decode.bool)
    ("id" := Decode.int)
    ("priority" := Decode.int)

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
  let
    spanAtr     = [ class (cellClass t) ]
    description = [ span spanAtr [ text t.description ] ]
    priority    = [ span spanAtr [ text (priorityDescription t) ] ]
    buttons     = controlButtons t
  in
    tr [ ]
      [ td [ ] description
      , td [ class "col-md-2" ] priority
      , td [ class "col-md-3 text-center" ] buttons
      ]


priorityDescription : Todo -> String
priorityDescription t =
  Maybe.withDefault "Unknown" (Dict.get t.priority priorityString)


controlButtons : Todo -> List Html
controlButtons t =
  let
    space = text "\n"
    buttons = List.map (\f -> f t) [editButton, increaseButton, decreaseButton, doneButton]
  in
    List.intersperse space buttons


editButton : Todo -> Html
editButton t =
  span [ class "btn btn-info btn-xs" ] [ text "✍" ]


increaseButton : Todo -> Html
increaseButton t =
  increaseDecreaseButton t True


decreaseButton : Todo -> Html
decreaseButton t =
  increaseDecreaseButton t False


increaseDecreaseButton : Todo -> Bool -> Html
increaseDecreaseButton t up =
  let
    spanClass = increaseDecreaseSpanClass t up
    clickHandler = increaseDecreaseClickHandler t up
    spanAttrs = spanClass :: clickHandler
    arrow =
      case up of
        True -> "⬆︎"
        False -> "⬇︎"
  in
    span spanAttrs [ text arrow ]


canIncreaseDecrease : Todo -> Bool -> Bool
canIncreaseDecrease t up =
  if up
    then t.priority > priorityHigh
    else t.priority < priorityLow


increaseDecreaseSpanClass : Todo -> Bool -> Attribute
increaseDecreaseSpanClass t up =
  let
    canChange = canIncreaseDecrease t up
    butColor = if canChange then "info" else "default"
  in
    class ("btn btn-" ++ butColor ++ " btn-xs")


increaseDecreaseClickHandler : Todo -> Bool -> List Attribute
increaseDecreaseClickHandler t up =
  let
    canChange = canIncreaseDecrease t up
    newTodo = { t | priority <- t.priority + (if up then -1 else 1) }
  in
    if canChange
    then [ Events.onClick updates.address newTodo ]
    else [ ]


doneButton : Todo -> Html
doneButton t =
  let
    newTodo = { t | done <- if t.done then False else True }
  in
    span
      [class "btn btn-success btn-xs", Events.onClick updates.address newTodo]
      [ text "✔︎" ]


cellClass : Todo -> String
cellClass todo =
  if todo.done then "inactive" else "active"

-- SIGNALS

updates : Signal.Mailbox Todo
updates = Signal.mailbox noTodo

-- TASKS

updateTodo : Int -> Task Http.Error Todo
updateTodo id =
  let
    request =
      { verb = "PATCH"
      , headers = []
      , url = "/todos/" ++ (toString id) ++ "/update.json"
      , body = Http.empty
      }
  in
    Http.fromJson decodeTodo (Http.send Http.defaultSettings request)
