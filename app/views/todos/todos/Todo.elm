module Todo where

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http exposing (defaultSettings, empty, fromJson)
import List exposing (filter, intersperse, map)
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
  let
    spanAtr     = class (cellClass t) :: [ ]
    description = span spanAtr [ text t.description ] :: [ ]
    priority    = span spanAtr [ text t.priority_ ] :: [ ]
    buttons     = controlButtons t
  in
    tr [ ]
      [ td [ ] description
      , td [ class "col-md-2" ] priority
      , td [ class "col-md-3 text-center" ] buttons
      ]


controlButtons : Todo -> List Html
controlButtons t =
  let
    space = text "\n"
    buttons = map (\f -> f t) [editButton, increaseButton, decreaseButton, doneButton]
  in
    intersperse space buttons


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
    then t.priority > t.priority_hi
    else t.priority < t.priority_low


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
    newPriority = toString (t.priority + (if up then 1 else -1))
  in
    if canChange
    then [ onClick updates.address (t.id, "todos[priority]=" ++ newPriority) ]
    else [ ]


doneButton : Todo -> Html
doneButton t =
  span
    [class "btn btn-success btn-xs", onClick updates.address (t.id, "todos[done]=" ++ (if t.done then "0" else "1"))]
    [ text "✔︎" ]


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
