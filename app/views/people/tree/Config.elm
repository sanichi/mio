module Config where

import Color exposing (Color)
import Signal
import Text exposing (defaultStyle)

-- COLORS

bgColor : Color
bgColor = Color.rgb 176 224 230

boxBgColor : Color
boxBgColor = Color.white

lineColor : Color
lineColor = Color.black

-- DIMENSIONS

border : Int
border = 1

deltaShift : Int
deltaShift = 200

level : Int
level = 180

margin : { x : Int, y : Int }
margin = { x = 18, y = 18 }

padding : { x : Int, y : Int }
padding = { x = 4, y = 4 }

thumbSize : Int
thumbSize = 100

-- TEXT

textStyle : Text.Style
textStyle =
  { defaultStyle
  | typeface <- ["Verdana", "Helvetica", "sans-serif"]
  , height <- Just 15
  }

smallStyle : Text.Style
smallStyle =
  { textStyle
  | height <- Just 11
  }

largeStyle : Text.Style
largeStyle =
  { textStyle
  | height <- Just 40
  }

-- TIME

changePictures : Float
changePictures = 5

-- SHARED MAILBOXES

family : Signal.Mailbox Int
family = Signal.mailbox 0

focus : Signal.Mailbox Int
focus = Signal.mailbox 0

shifts : Signal.Mailbox Int
shifts = Signal.mailbox 0
