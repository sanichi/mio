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


deltaShift : Int
deltaShift =
    200


height : Int
height =
    3 * levelHeight


levelHeight : Int
levelHeight =
    boxHeight + thumbSize + margin.y


margin : { x : Int, y : Int }
margin =
    { x = 18, y = 18 }


padding : { x : Int, y : Int }
padding =
    { x = 4, y = 4 }


thumbSize : Int
thumbSize =
    100


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


changePictures : Float
changePictures =
    4
