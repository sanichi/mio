module Config where

import Color exposing (Color)
import Graphics.Element as Element
import Signal
import Text exposing (defaultStyle)

-- COLORS

bgColor : Color
bgColor = Color.rgb 176 224 230

boxBgColor : Color
boxBgColor = Color.white

focusBgColor : Color
focusBgColor = Color.rgb 24 188 156

lineColor : Color
lineColor = Color.black

-- DIMENSIONS

adjustY : Float
adjustY = 0.5 * toFloat (levelHeight - boxHeight)

border : Int
border = 1

boxHeight : Int
boxHeight =
  let
    name = "Name" |> Text.fromString |> Text.style textStyle
    year = "2000" |> Text.fromString |> Text.style smallStyle
    combined = Text.join (Text.fromString "\n") [name, year] |> Element.centered
  in
    Element.heightOf combined + 2 * (padding.y + border + margin.y)

deltaShift : Int
deltaShift = 200

initialHeight : Int
initialHeight = 3 * levelHeight

initialWidth : Int
initialWidth = 500

levelHeight : Int
levelHeight = boxHeight + thumbSize + margin.y

margin : { x : Int, y : Int }
margin = { x = 18, y = 18 }

padding : { x : Int, y : Int }
padding = { x = 4, y = 4 }

thumbSize : Int
thumbSize = 100

-- TEXT

focusStyle : Text.Style
focusStyle =
  { textStyle
  | color = Color.white
  }

smallStyle : Text.Style
smallStyle =
  { textStyle
  | height = Just 11
  }

smallFocusStyle : Text.Style
smallFocusStyle =
  { smallStyle
  | color = Color.white
  }

textStyle : Text.Style
textStyle =
  { defaultStyle
  | typeface = ["Verdana", "Helvetica", "sans-serif"]
  , height = Just 15
  , color = Color.black
  }

largeStyle : Text.Style
largeStyle =
  { textStyle
  | height = Just 40
  }

-- TIME

changePictures : Float
changePictures = 4

-- SHARED MAILBOXES

family : Signal.Mailbox Int
family = Signal.mailbox 0

focus : Signal.Mailbox Int
focus = Signal.mailbox 0

shifts : Signal.Mailbox Int
shifts = Signal.mailbox 0
