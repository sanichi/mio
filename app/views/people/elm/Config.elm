module Config exposing (..)

import String


-- SVG


viewBox : String
viewBox =
    String.join " " [ "0 0", toString width, toString height ]



-- dimensions


adjustY : Float
adjustY =
    0.5 * toFloat (levelHeight - boxHeight)


border : Int
border =
    1


boxHeight : Int
boxHeight =
    50


centerY : Int -> Int
centerY level =
    (levelHeight * (2 * level - 1) - pictureSize - margin) // 2


deltaShift : Int
deltaShift =
    200


fontHeight : Int
fontHeight =
    14


fontWidth : Int
fontWidth =
    8


height : Int
height =
    3 * levelHeight


levelHeight : Int
levelHeight =
    boxHeight + pictureSize + 3 * margin


margin : Int
margin =
    18


padding : Int
padding =
    6


smallFontHeight : Int
smallFontHeight =
    10


smallFontWidth : Int
smallFontWidth =
    6


smallTextWidth : String -> Int
smallTextWidth text =
    String.length text * smallFontWidth


textWidth : String -> Int
textWidth text =
    String.length text * fontWidth |> Basics.max 70


width : Int
width =
    1000



-- text
-- defaultStyle : Text.Style
-- defaultStyle =
--     Text.defaultStyle
--
--
-- textStyle : Text.Style
-- textStyle =
--     { defaultStyle
--         | typeface = [ "Verdana", "Helvetica", "sans-serif" ]
--         , height = Just 15
--         , color = Color.black
--     }
--
--
-- focusStyle : Text.Style
-- focusStyle =
--     { textStyle
--         | color = Color.white
--     }
--
--
-- largeStyle : Text.Style
-- largeStyle =
--     { textStyle
--         | height = Just 40
--     }
--
--
-- smallStyle : Text.Style
-- smallStyle =
--     { textStyle
--         | height = Just 11
--     }
--
--
-- smallFocusStyle : Text.Style
-- smallFocusStyle =
--     { smallStyle
--         | color = Color.white
--     }
-- time
-- pictures


changePicture : Float
changePicture =
    4


pictureSize : Int
pictureSize =
    100


missingPicturePath : String
missingPicturePath =
    "/images/blank_woman.png"
