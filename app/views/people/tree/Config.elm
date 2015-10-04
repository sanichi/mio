module Config where

import Color exposing (Color)
import Signal

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

level : Int
level = 80

margin : { x : Int, y : Int }
margin = { x = 18, y = 18 }

padding : { x : Int, y : Int }
padding = { x = 3, y = 3 }

-- SHARED MAILBOXES

newFocus : Signal.Mailbox Int
newFocus = Signal.mailbox 0
