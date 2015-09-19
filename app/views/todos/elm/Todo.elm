module Todo where

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Http
import Json.Decode as Decode exposing ((:=))
import Misc exposing (highPriority, lowPriority, priorities)
import String
import Task exposing (Task)

-- MODEL

type alias Todo =
  { description: String
  , done: Bool
  , id: Int
  , priority: Int
  , token: String
  , editing: Bool
  , newDescription : String
  }


exampleTodo : Todo
exampleTodo =
  { description = ""
  , done = True
  , id = 0
  , priority = 1
  , token = "noAuthAtStart"
  , editing = False
  , newDescription = ""
  }


decodeTodo : Decode.Decoder Todo
decodeTodo =
  Decode.object7 Todo
    ("description" := Decode.string)
    ("done" := Decode.bool)
    ("id" := Decode.int)
    ("priority" := Decode.int)
    (Decode.succeed "noAuthFromServer")
    (Decode.succeed False)
    (Decode.succeed "")


type alias UpdateResult = Result Http.Error Todo
type alias DeleteResult = Result Http.Error Int

-- UPDATE

updateBody : Todo -> Http.Body
updateBody t =
  Http.string <|
    String.join "&"
      [ "todo%5Bdescription%5D=" ++ (Http.uriEncode t.description)
      , "todo%5Bpriority%5D=" ++ (toString t.priority)
      , "todo%5Bdone%5D=" ++ if t.done then "1" else "0"
      , "authenticity_token=" ++ (Http.uriEncode t.token)
      , "_method=patch"
      , "commit=Save"
      , "utf8=✓"
      ]


updateTodo : Todo -> Task Http.Error UpdateResult
updateTodo t =
  if t.id > 0 then
    let
      request =
        { verb = "POST"
        , headers = [ ("Content-Type", "application/x-www-form-urlencoded") ]
        , url = updateAndDeleteUrl t
        , body = updateBody t
        }
    in
      Task.toResult <| Http.fromJson decodeTodo (Http.send Http.defaultSettings request)
  else
    Task.fail <| Http.UnexpectedPayload "can't update todos unless ID > 0"


deleteBody : Todo -> Http.Body
deleteBody t =
  Http.string <|
    String.join "&"
      [ "_method=delete"
      , "authenticity_token=" ++ (Http.uriEncode t.token)
      ]


deleteTodo : Todo -> Task Http.Error DeleteResult
deleteTodo t =
  if t.id > 0 then
    let
      request =
        { verb = "POST"
        , headers = [ ("Content-Type", "application/x-www-form-urlencoded") ]
        , url = updateAndDeleteUrl t
        , body = deleteBody t
        }
    in
      Task.toResult <| Http.fromJson Decode.int (Http.send Http.defaultSettings request)
  else
    Task.fail <| Http.UnexpectedPayload "can't delete todos unless ID > 0"

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


view : Int -> Todo -> Html
view id t =
  let
    spanAtr = class (cellClass t)
    rowStyles = if id == t.id then [ ("background-color", "lightBlue") ] else [ ]
    buttons = controlButtons t
    priority = span [ spanAtr ] [ text (priorityDescription t) ]
    description =
      span [ spanAtr, Events.onDoubleClick edits.address (t.id, True) ] [ text t.description ]
    updater =
      div
        [ class "input-group input-group-md" ]
        [
          input
            [ value t.newDescription
            , type' "text"
            , class "form-control"
            , size 50
            , autofocus True
            , Events.on "input" Events.targetValue (\value -> Signal.message descriptions.address (t.id, value))
            , Events.onBlur edits.address (t.id, False)
            , onEnter updates.address { t | description <- t.newDescription }
            ]
            [ ]
        ]
  in
    tr [ style rowStyles ]
      [ td [ ] [ if t.editing then updater else description ]
      , td [ class "col-md-2" ] [ priority ]
      , td [ class "col-md-3 text-center" ] buttons
      ]


priorityDescription : Todo -> String
priorityDescription t =
  Maybe.withDefault "Unknown" (Dict.get t.priority priorities)


controlButtons : Todo -> List Html
controlButtons t =
  let
    space = text "\n"
    buttons = List.map (\f -> f t) [increaseButton, decreaseButton, doneButton, deleteButton]
  in
    List.intersperse space buttons


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
    then t.priority > highPriority
    else t.priority < lowPriority


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
      [ class "btn btn-success btn-xs", Events.onClick updates.address newTodo ]
      [ text "✔︎" ]


deleteButton : Todo -> Html
deleteButton t =
  span
    [ class "btn btn-danger btn-xs", Events.onClick deletes.address t ]
    [ text "✘" ]


cellClass : Todo -> String
cellClass todo =
  if todo.done then "inactive" else "active"

-- SIGNALS

descriptions : Signal.Mailbox (Int, String)
descriptions = Signal.mailbox (0, "")


updates : Signal.Mailbox Todo
updates = Signal.mailbox exampleTodo


deletes : Signal.Mailbox Todo
deletes = Signal.mailbox exampleTodo


edits : Signal.Mailbox (Int, Bool)
edits = Signal.mailbox (0, False)

-- UTILITIES

updateAndDeleteUrl : Todo -> String
updateAndDeleteUrl t =
  "/todos/" ++ (toString t.id) ++ ".json"


onEnter : Signal.Address a -> a -> Attribute
onEnter address value =
    Events.on "keydown"
      (Decode.customDecoder Events.keyCode is13)
      (\_ -> Signal.message address value)


is13 : Int -> Result String ()
is13 code =
  if code == 13 then Ok () else Err "not the right key code"
