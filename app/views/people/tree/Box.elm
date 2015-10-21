module Box where

import Array
import Config exposing
  ( boxBgColor, lineColor
  , border, deltaShift, level, margin, padding, thumbSize
  , largeStyle, smallStyle, textStyle
  , newFocus, shifts
  )
import Family exposing (Person, People)
import Graphics.Collage as Graphic exposing (Form)
import Graphics.Element as Element exposing (Element)
import Graphics.Input as Input
import Point exposing (Point)
import Text

-- MODEL

type alias Box =
  { forms : List Form
  , lines : List Form
  , w : Int
  , h : Int
  , x : Float
  , y : Float
  }

emptyForm : Form
emptyForm = Element.empty |> Graphic.toForm

emptyBox : Box
emptyBox =
  { forms = [ ]
  , lines = [ ]
  , w = 0
  , h = 0
  , x = 0.0
  , y = 0.0
  }

middle : Box -> Point
middle box =
  (box.x, box.y)

top : Box -> Point
top box =
  (box.x, box.y + (toFloat (box.h // 2 - margin.x)))

bottom : Box -> Point
bottom box =
  (box.x, box.y - (toFloat (box.h // 2 - margin.x)))

right : Box -> Point
right box =
  (box.x + (toFloat (box.w // 2 - margin.y)), box.y)

left : Box -> Point
left box =
  (box.x - (toFloat (box.w // 2 - margin.y)), box.y)

move : Point -> Box -> Box
move (dx, dy) box =
  { box
  | x <- box.x + dx
  , y <- box.y + dy
  , forms <- List.map (Graphic.move (dx, dy)) box.forms
  , lines <- List.map (Graphic.move (dx, dy)) box.lines
  }

-- MAPPINGS

box : (Float, Float) -> Person -> Box
box d p =
  box2 False d p

box2 : Bool -> (Float, Float) -> Person -> Box
box2 isFocus (dx, dy) person =
  let
    m = Signal.message newFocus.address person.id

    t = Text.fromString person.name |> Text.style textStyle
    t' = if isFocus then Text.bold t else t

    y = Text.fromString person.years |> Text.style smallStyle
    y' = if isFocus then Text.bold y else y

    e = Text.join (Text.fromString "\n") [t', y'] |> Element.centered
    w = Element.widthOf e
    h = Element.heightOf e

    a = if isFocus then 2 else 0

    w' = 2 * (ceiling ((toFloat w) / 2.0) + (padding.x + a)) |> max thumbSize
    h' = 2 * (ceiling ((toFloat h) / 2.0) + (padding.y + a))
    e' = Element.container w' h' Element.middle e |> Element.color boxBgColor |> Input.clickable m

    b = if isFocus then 1 else 0

    w'' = w' + 2 * (border + b)
    h'' = h' + 2 * (border + b)
    e'' = Element.container w'' h'' Element.middle e' |> Element.color lineColor

    w''' = w'' + 2 * margin.x
    h''' = h'' + 2 * margin.y
    e''' = Element.container w''' h''' Element.middle e'' |> Graphic.toForm

    ts = thumbSize + if isFocus then 20 else 0
    p = Element.image ts ts person.picture |> Input.clickable m

    px = dx * 0.5 * toFloat (w''' + thumbSize)
    py = dy * 0.5 * toFloat (h''' + thumbSize)
    p' = Graphic.toForm p |> Graphic.move (px, py)

  in
    { forms = [ e''', p' ]
    , lines = [ ]
    , w = w'''
    , h = h'''
    , x = 0.0
    , y = 0.0
    }

parents : (Float, Float) -> Maybe Person -> Maybe Person -> Box
parents (x, y) father mother =
  let
    b =
      case (father, mother) of
        (Nothing, Nothing) -> emptyBox
        (Just f, Nothing)  -> box (0, 1) f
        (Nothing, Just m)  -> box (0, 1) m
        (Just f, Just m)   -> couple f m
    t =
      move (0, (toFloat level)) b
    l =
      case (father, mother) of
        (Nothing, Nothing) -> emptyForm
        (Just m, Just f)   -> line (middle t) (x, y)
        _                  -> line (bottom t) (x, y)
  in
     { t
     | forms <- t.forms
     , lines <- l :: t.lines
     }

partner : Point -> Person -> Box
partner (x, y) partner =
  let
    b = box (1, 0) partner
    m = move (x + (toFloat (margin.x + (b.w // 2))), y) b
    l = line (x, y) (left m)
  in
    { m
    | forms <- m.forms
    , lines <- [ l ]
    }

children : Point -> Float -> People -> Box
children (x, y) h people =
  let
    bx1 = Array.map (box (0, -1)) people
    wds = Array.map (\b -> b.w) bx1
    wid = Array.foldl (\w t -> w + t) 0 wds
    mds = Array.indexedMap (\i w -> (w - wid) // 2 + (Array.foldl (\w t -> w + t) 0 (Array.slice 0 i wds))) wds
    bx2 = Array.indexedMap (\i b -> move (x + toFloat (Maybe.withDefault 0 (Array.get i mds)), toFloat -level) b) bx1
    b1 = Array.get 0 bx2 |> Maybe.withDefault emptyBox
    b2 = Array.get ((Array.length bx2) - 1) bx2 |> Maybe.withDefault emptyBox
    ym = Point.average (x, h) (top b1) |> snd
    ls = Array.map (\m -> line (top m) (m.x, ym)) bx2 |> Array.toList
    l1 = line (x, y) (x, ym)
    l2 = line (b1.x, ym) (b2.x, ym)
  in
    { forms = Array.map (\b -> b.forms) bx2 |> Array.toList |> List.concat
    , lines = List.append ls [l1, l2]
    , w = Array.foldl (\b l -> b.w + l) 0 bx2
    , h = b1.h
    , x = (b1.x + b2.x) / 2.0
    , y = b1.y
    }

couple : Person -> Person -> Box
couple p1 p2 =
  let
    b1 = box (0, 1) p1
    b2 = box (0, 1) p2
    m1 = move (toFloat(-b1.w // 2), 0) b1
    m2 = move (toFloat( b2.w // 2), 0) b2
    hb = line (right m1) (left m2)
  in
    { forms = List.append m1.forms m2.forms
    , lines = [ hb ]
    , w = b1.w + b2.w
    , h = b1.h
    , x = (b1.x + b2.x) / 2.0
    , y = b1.y
    }

overflow : Bool -> Int -> Int -> Int -> Box -> Form
overflow leftSide width height shift widestBox =
  let
    point = if leftSide then left widestBox else right widestBox
    extreme = 2 * (shift + round (fst point))
    offEdge = if leftSide then extreme <= -width else extreme >= width
  in
    if offEdge
      then
        let
          delta = if leftSide then deltaShift else -deltaShift
          m = Signal.message shifts.address delta

          arrow = if leftSide then "☜" else "☞"
          t = Text.fromString arrow |> Text.style largeStyle
          e = Element.centered t
          w = Element.widthOf e
          h = Element.heightOf e

          w' = 2 * (ceiling ((toFloat w) / 2.0) + padding.x)
          h' = 2 * (ceiling ((toFloat h) / 2.0) + padding.y)
          e' = Element.container w' h' Element.middle e |> Input.clickable m

          x =
            let
              dx = toFloat (width - w') / 2.0
            in
              if leftSide then -dx else dx
          y = toFloat (height - h') / 2.0

        in
          Graphic.toForm e' |> Graphic.move (x, y)
      else
        emptyForm

-- MISC

line : Point -> Point -> Form
line p1 p2 =
  let
    path = Graphic.segment p1 p2
    style = Graphic.solid lineColor
  in
    Graphic.traced style path
