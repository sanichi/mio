module Todo where

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Http
import Json.Decode as Decode exposing ((:=))
import Misc exposing (priorityHigh, priorityLow, priorityString)
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


type alias TodoResult = Result Http.Error Todo


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

-- URLS

updateUrl : Todo -> String
updateUrl t =
  "/todos/" ++ (toString t.id) ++ ".json"

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

-- Using Http.post sets the Content-Type to text/plain, which Rails rejects
-- so here we use the full Http.send method just to fix that.
updateTodo : Todo -> Task Http.Error TodoResult
updateTodo t =
  if t.id > 0 then
    let
      request =
        { verb = "POST"
        , headers = [ ("Content-Type", "application/x-www-form-urlencoded") ]
        , url = updateUrl t
        , body = updateBody t
        }
    in
      Task.toResult <| Http.fromJson decodeTodo (Http.send Http.defaultSettings request)
  else
    Task.fail <| Http.UnexpectedPayload "only update todos with ID > 0"


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
    spanAtr = [ class (cellClass t) ]
    rowStyles = if id == t.id then [ ("background-color", "lightBlue") ] else [ ]
    priority = span spanAtr [ text (priorityDescription t) ]
    buttons = controlButtons t
    description = span spanAtr [ text t.description ]
    updater =
      div
        [ class "input-group input-group-md" ]
        [
          input
            [ value t.newDescription
            , type' "text"
            , class "form-control"
            , Events.on "input" Events.targetValue (\value -> Signal.message descUpdates.address (t.id, value))
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
  span
    [ class "btn btn-info btn-xs", Events.onClick edits.address t.id ]
    [ text "✍" ]


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
updates = Signal.mailbox exampleTodo


descUpdates : Signal.Mailbox (Int, String)
descUpdates = Signal.mailbox (0, "")


edits : Signal.Mailbox Int
edits = Signal.mailbox 0

-- UTILITIES

onEnter : Signal.Address a -> a -> Attribute
onEnter address value =
    Events.on "keydown"
      (Decode.customDecoder Events.keyCode is13)
      (\_ -> Signal.message address value)


is13 : Int -> Result String ()
is13 code =
  if code == 13 then Ok () else Err "not the right key code"
