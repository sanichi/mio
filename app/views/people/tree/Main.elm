import Array
import Box exposing (Box)
import Color
import Config exposing (bgColor, family, level, margin, focus, shifts)
import Dict exposing (Dict)
import Family exposing (Person, People, Focus, Family)
import Graphics.Collage as Graphic exposing (Form)
import Graphics.Element as Element exposing (Element)
import Point
import String
import Text
import Window

-- MODEL

type alias Model =
  { width: Int
  , height: Int
  , focus: Focus
  , family : Int
  , shift : Int
  }

init : Model
init =
  { width = 500
  , height = 4 * level
  , focus = Family.blur
  , family = 0
  , shift = 0
  }

-- VIEW

view : Model -> Element
view model =
  let
    focus = model.focus
    focusBox = Box.box2 True (-1, 0) focus.person
    parentsBox = Box.parents (Box.top focusBox) focus.father focus.mother
    family = Array.get model.family focus.families
    partnerBox =
      case family of
        Nothing -> Box.emptyBox
        Just f ->
          case f.partner of
            Nothing -> Box.emptyBox
            Just p -> Box.partner (Box.right focusBox) (model.family, Array.length focus.families) p
    childrenBox =
      case family of
        Nothing -> Box.emptyBox
        Just f ->
          let
            handle =
              case f.partner of
                Nothing -> Box.bottom focusBox
                Just p -> Box.right focusBox |> Point.moveX (toFloat margin.x)
            bot = Box.bottom focusBox |> snd
          in
            if Array.isEmpty f.children then Box.emptyBox else Box.children handle bot f.children
    adjust =
      if partnerBox.w > 0
        then Point.average (Box.right focusBox) (Box.left partnerBox) |> fst |> round
        else 0
    leftOverflow = Box.overflow True model.width model.height (model.shift - adjust) childrenBox
    rightOverflow = Box.overflow False model.width model.height (model.shift - adjust) childrenBox
    boxes = [ focusBox, parentsBox, partnerBox, childrenBox ]
    unshiftedForms =
      List.append
        (boxes |> List.map .lines |> List.concat) -- lines must be first, otherwise
        (boxes |> List.map .forms |> List.concat) -- onclicks don't work (Elm bug)
    shift = toFloat (model.shift - adjust)
    shiftedForms = List.map (Graphic.move (shift, 0)) unshiftedForms
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

update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    UpdateContainer (w,h) ->
      { model
      | width <- w
      , height <- h
      }

    ChangeFocus f ->
      { model
      | focus <- f
      , family <- 0
      , shift <- 0
      }

    Shift delta ->
      { model
      | shift <- model.shift + delta
      }

    SwitchFamily index ->
      { model
      | family <- index
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
    ]

-- PORTS

port foci : Signal Focus

port getFocus : Signal Int
port getFocus = focus.signal
