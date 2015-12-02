import Array
import Box exposing (Box)
import Color
import Config exposing (bgColor, changePictures, family, margin, focus, shifts)
import Dict exposing (Dict)
import Family exposing (Person, People, Focus, Family)
import Graphics.Collage as Graphic exposing (Form)
import Graphics.Element as Element exposing (Element)
import Point
import String
import Text
import Time exposing (Time)
import Window

-- MODEL

type alias Model =
  { width: Int
  , height: Int
  , focus: Focus
  , family : Int
  , picture : Int
  , shift : Int
  }

init : Model
init =
  { width = Config.initialWidth
  , height = Config.initialHeight
  , focus = Family.blur
  , family = 0
  , picture = 0
  , shift = 0
  }

-- VIEW

view : Model -> Element
view model =
  let
    focus = model.focus
    focusBox = Box.box2 True model.picture focus.person
    parentsBox = Box.parents (Box.top focusBox) model.picture focus.father focus.mother
    family = Array.get model.family focus.families
    partnerBox =
      case family of
        Nothing -> Box.emptyBox
        Just f -> Box.partner (Box.right focusBox) (model.family, Array.length focus.families) model.picture f.partner
    childrenBox =
      case family of
        Nothing -> Box.emptyBox
        Just f ->
          let
            handle = Box.right focusBox |> Point.moveX (toFloat margin.x)
            bot = Box.bottom focusBox |> snd
          in
            if Array.isEmpty f.children then Box.emptyBox else Box.children handle bot model.picture f.children
    youngSibsBox =
      if Array.isEmpty focus.younger_siblings
        then Box.emptyBox
        else
          let
            rightEdge = [focusBox, partnerBox] |> List.map Box.right |> List.map fst |> List.maximum |> Maybe.withDefault 0
          in
            Box.siblings rightEdge model.picture focus.younger_siblings
    oldSibsBox =
      if Array.isEmpty focus.older_siblings
        then Box.emptyBox
        else
          let
            leftEdge = fst (Box.left focusBox)
          in
            Box.siblings leftEdge model.picture focus.older_siblings
    adjustX =
      if partnerBox.w > 0
        then Point.average (Box.right focusBox) (Box.left partnerBox) |> fst |> round
        else 0
    boxes = [ focusBox, parentsBox, partnerBox, childrenBox, youngSibsBox, oldSibsBox ]
    leftMost = Box.leftMost boxes
    rightMost = Box.rightMost boxes
    leftOverflow = Box.overflow True model.width model.height (model.shift - adjustX) leftMost
    rightOverflow = Box.overflow False model.width model.height (model.shift - adjustX) rightMost
    unshiftedForms =
      List.append
        (boxes |> List.map .lines |> List.concat) -- lines must be first, otherwise
        (boxes |> List.map .forms |> List.concat) -- onclicks don't work (Elm bug)
    shiftX = toFloat (model.shift - adjustX)
    shiftY = Config.adjustY
    shiftedForms = List.map (Graphic.move (shiftX, shiftY)) unshiftedForms
    forms = List.append shiftedForms [leftOverflow, rightOverflow]
  in
    Graphic.collage model.width model.height forms |> Element.color bgColor

-- UPDATE

type Action
  = NoOp
  | UpdateContainer (Int, Int)
  | ChangeFocus Focus
  | Shift Int
  | SwitchFamily Int
  | RolloverPictures

update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    UpdateContainer (w,h) ->
      { model
      | width = w
      , height = h
      }

    ChangeFocus f ->
      { model
      | focus = f
      , family = 0
      , shift = 0
      }

    Shift delta ->
      { model
      | shift = model.shift + delta
      }

    SwitchFamily index ->
      { model
      | family = index
      }

    RolloverPictures ->
      { model
      | picture = model.picture + 1
      }

-- SIGNALS

main : Signal Element
main =
  Signal.map view model

model : Signal Model
model =
  Signal.foldp update init actions

actions : Signal Action
actions =
  Signal.mergeMany
    [ Signal.map UpdateContainer Window.dimensions
    , Signal.map ChangeFocus foci
    , Signal.map Shift shifts.signal
    , Signal.map SwitchFamily family.signal
    , Signal.map (always RolloverPictures) pictureClock
    ]

pictureClock : Signal Time
pictureClock = changePictures * Time.second |> Time.every

-- PORTS

port foci : Signal Focus

port getFocus : Signal Int
port getFocus = focus.signal
