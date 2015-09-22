module Todo where

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Http
import Json.Decode as Decode exposing ((:=))
import Misc exposing
  ( i18Cancel, i18Confirm, i18Delete, i18Done, i18Down, i18NewTodo, i18Priorities, i18Up
  , highPriority, lowPriority, maxDesc
  , indexAndCreateUrl, updateAndDeleteUrl
  )
import String
import Task exposing (Task)
import Util exposing (is13, nbsp, onEnter, postRequest)

-- MODEL

type alias Todo =
  { description : String
  , done : Bool
  , id : Int
  , priority : Int
  , editingDescription : Bool
  , newDescription : String
  }


exampleTodo : Todo
exampleTodo =
  { description = ""
  , done = False
  , id = 0
  , priority = highPriority
  , editingDescription = False
  , newDescription = ""
  }


decodeTodo : Decode.Decoder Todo
decodeTodo =
  Decode.object6 Todo
    ("description" := Decode.string)
    ("done" := Decode.bool)
    ("id" := Decode.int)
    ("priority" := Decode.int)
    (Decode.succeed False)
    (Decode.succeed "")


type alias CreateResult = Result Http.Error Todo
type alias UpdateResult = Result Http.Error Todo
type alias DeleteResult = Result Http.Error Int

-- UPDATE

createBody : Todo -> Http.Body
createBody t =
  Http.string <|
    String.join "&"
      [ "todo%5Bdescription%5D=" ++ (Http.uriEncode t.description)
      , "todo%5Bpriority%5D=" ++ (toString t.priority)
      , "commit=Save"
      , "utf8=✓"
      ]

createTodo : Todo -> Task Http.Error CreateResult
createTodo t =
  if String.length t.description > 0 then
    let
      request = postRequest indexAndCreateUrl (createBody t)
    in
      Task.toResult <| Http.fromJson decodeTodo (Http.send Http.defaultSettings request)
  else
    Task.fail <| Http.UnexpectedPayload "can't create todos without a description"


updateBody : Todo -> Http.Body
updateBody t =
  Http.string <|
    String.join "&"
      [ "todo%5Bdescription%5D=" ++ (Http.uriEncode t.description)
      , "todo%5Bpriority%5D=" ++ (toString t.priority)
      , "todo%5Bdone%5D=" ++ if t.done then "1" else "0"
      , "_method=patch"
      , "commit=Save"
      , "utf8=✓"
      ]


updateTodo : Todo -> Task Http.Error UpdateResult
updateTodo t =
  if t.id > 0 then
    let
      request = postRequest (updateAndDeleteUrl t.id) (updateBody t)
    in
      Task.toResult <| Http.fromJson decodeTodo (Http.send Http.defaultSettings request)
  else
    Task.fail <| Http.UnexpectedPayload "can't update todos unless ID > 0"


deleteBody : Http.Body
deleteBody =
  Http.string "_method=delete"


deleteTodo : Int -> Task Http.Error DeleteResult
deleteTodo id =
  if id > 0 then
    let
      request = postRequest (updateAndDeleteUrl id) deleteBody
    in
      Task.toResult <| Http.fromJson Decode.int (Http.send Http.defaultSettings request)
  else
    Task.fail <| Http.UnexpectedPayload "can't delete todos unless ID > 0"

-- VIEW

todoCompare : Todo -> Todo -> Order
todoCompare t1 t2 =
  if t1.id == 0 || t2.id == 0
    then compare t2.id t1.id
    else (
      if xor t1.done t2.done
        then (if t1.done then GT else LT)
        else (
          if t1.priority == t2.priority
            then compare t1.description t2.description
            else compare t1.priority t2.priority
        )
  )


view : Int -> Int -> Todo -> Html
view lastUpdated toDelete t =
  if t.id == 0
    then
      let
        updater =
          div
            [ class "input-group input-group-sm" ]
            [
              input
                [ value t.newDescription
                , type' "text"
                , class "form-control"
                , size maxDesc
                , maxlength maxDesc
                , placeholder i18NewTodo
                , autofocus True
                , Events.on "input" Events.targetValue (\value -> Signal.message descriptions.address (0, value))
                , onEnter creates.address { t | description <- t.newDescription }
                ]
                [ ]
            ]
      in
        tr [ ] [ td [ colspan 3 ] [ updater ] ]
    else
      let
        spanAtr = class (cellClass t)
        rowClass = if lastUpdated == t.id then "last-updated" else ""
        buttons = controlButtons toDelete t
        priority = span [ spanAtr ] [ text (priorityDescription t) ]
        description =
          span [ spanAtr, Events.onDoubleClick edits.address (t.id, True) ] [ text t.description ]
        updater =
          div
            [ class "input-group input-group-sm" ]
            [
              input
                [ value t.newDescription
                , type' "text"
                , class "form-control"
                , size maxDesc
                , maxlength maxDesc
                , autofocus True
                , Events.on "input" Events.targetValue (\value -> Signal.message descriptions.address (t.id, value))
                , Events.onBlur edits.address (t.id, False)
                , onEnter updates.address { t | description <- t.newDescription }
                ]
                [ ]
            ]
    in
      tr
        [ class rowClass ]
        [ td [ ] [ if t.editingDescription then updater else description ]
        , td [ class "col-md-2" ] [ priority ]
        , td [ class "col-md-2 text-center" ] buttons
        ]


priorityDescription : Todo -> String
priorityDescription t =
  Maybe.withDefault "Unknown" (Dict.get t.priority i18Priorities)


controlButtons : Int -> Todo -> List Html
controlButtons toDelete t =
  let
    space = text nbsp
    buttons =
      if t.id == toDelete
        then [ cancelButton, (confirmButton t.id) ]
        else List.map (\f -> f t) [ increaseButton, decreaseButton, doneButton, deleteButton ]
  in
    List.intersperse space buttons


increaseButton : Todo -> Html
increaseButton t =
  increaseDecreaseButton t True


decreaseButton : Todo -> Html
decreaseButton t =
  increaseDecreaseButton t False


increaseDecreaseButton : Todo -> Bool -> Html
increaseDecreaseButton t bool =
  let
    spanClass = increaseDecreaseSpanClass t bool
    clickHandler = increaseDecreaseClickHandler t bool
    spanAttrs = spanClass :: clickHandler
    arrow =
      case bool of
        True -> i18Up
        False -> i18Down
  in
    span spanAttrs [ text arrow ]


canIncreaseDecrease : Todo -> Bool -> Bool
canIncreaseDecrease t bool =
  if bool
    then t.priority > highPriority
    else t.priority < lowPriority


increaseDecreaseSpanClass : Todo -> Bool -> Attribute
increaseDecreaseSpanClass t bool =
  let
    canChange = canIncreaseDecrease t bool
    butColor = if canChange then "info" else "default"
  in
    class ("btn btn-" ++ butColor ++ " btn-xs")


increaseDecreaseClickHandler : Todo -> Bool -> List Attribute
increaseDecreaseClickHandler t bool =
  let
    canChange = canIncreaseDecrease t bool
    newTodo = { t | priority <- t.priority + (if bool then -1 else 1) }
  in
    if canChange
      then [ Events.onClick updates.address newTodo ]
      else [ ]


cancelButton : Html
cancelButton =
  span
    [ class "btn btn-default btn-xs", Events.onClick cancellations.address () ]
    [ text i18Cancel ]


confirmButton : Int -> Html
confirmButton id =
  span
    [ class "btn btn-danger btn-xs", Events.onClick deletes.address id ]
    [ text i18Confirm ]


doneButton : Todo -> Html
doneButton t =
  let
    newTodo = { t | done <- if t.done then False else True }
  in
    span
      [ class "btn btn-success btn-xs", Events.onClick updates.address newTodo ]
      [ text i18Done ]


deleteButton : Todo -> Html
deleteButton t =
  span
    [ class "btn btn-danger btn-xs", Events.onClick confirmations.address t.id ]
    [ text i18Delete ]


cellClass : Todo -> String
cellClass todo =
  if todo.done then "inactive" else "active"

-- SIGNALS

cancellations : Signal.Mailbox ()
cancellations = Signal.mailbox ()


confirmations : Signal.Mailbox Int
confirmations = Signal.mailbox 0


creates : Signal.Mailbox Todo
creates = Signal.mailbox exampleTodo


deletes : Signal.Mailbox Int
deletes = Signal.mailbox 0


edits : Signal.Mailbox (Int, Bool)
edits = Signal.mailbox (0, False)


descriptions : Signal.Mailbox (Int, String)
descriptions = Signal.mailbox (0, "")


updates : Signal.Mailbox Todo
updates = Signal.mailbox exampleTodo
