module Config exposing (..)

import Color
import Element
import Text


-- import Color exposing (Color)
-- import Graphics.Element as Element
-- import Signal
-- import Text exposing (defaultStyle)
-- COLORS
-- bgColor : Color
-- bgColor = Color.rgb 176 224 230
--
-- boxBgColor : Color
-- boxBgColor = Color.white
--
-- focusBgColor : Color
-- focusBgColor = Color.rgb 24 188 156
--
-- lineColor : Color
-- lineColor = Color.black
-- dimensions
-- adjustY : Float
-- adjustY =
--     0.5 * toFloat (levelHeight - boxHeight)
--


border : Int
border =
    1



-- boxHeight : Int
-- boxHeight =
--     30


boxHeight : Int
boxHeight =
    let
        name =
            "Name" |> Text.fromString |> Text.style textStyle

        year =
            "2000" |> Text.fromString |> Text.style smallStyle

        combined =
            "x"

        --Text.join (Text.fromString "\n") [ name, year ] |> Element.centered
    in
        30



-- Element.heightOf combined + 2 * (padding.y + border + margin.y)


deltaShift : Int
deltaShift =
    200


initialHeight : Int
initialHeight =
    3 * levelHeight


initialWidth : Int
initialWidth =
    500


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



-- text


defaultStyle : Text.Style
defaultStyle =
    Text.defaultStyle


textStyle : Text.Style
textStyle =
    { defaultStyle
        | typeface = [ "Verdana", "Helvetica", "sans-serif" ]
        , height = Just 15
        , color = Color.black
    }


focusStyle : Text.Style
focusStyle =
    { textStyle
        | color = Color.white
    }


largeStyle : Text.Style
largeStyle =
    { textStyle
        | height = Just 40
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



-- time


changePictures : Float
changePictures =
    4
