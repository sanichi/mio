module Config exposing (..)

import String


boxHeight : Int
boxHeight =
    50


centerY : Int -> Int
centerY level =
    (levelHeight * (2 * level - 1) - pictureSize - margin) // 2


changePicture : Float
changePicture =
    4


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


pictureSize : Int
pictureSize =
    100


smallFontHeight : Int
smallFontHeight =
    10


smallFontWidth : Int
smallFontWidth =
    6


smallTextWidth : String -> Int
smallTextWidth text =
    String.length text * smallFontWidth


switchBoxHeight : Int
switchBoxHeight =
    30


textWidth : String -> Int -> Int
textWidth text minLen =
    String.length text * fontWidth |> Basics.max minLen


viewBox : String
viewBox =
    String.join " " [ "0 0", toString width, toString height ]


width : Int
width =
    1000


missingPicturePath : String
missingPicturePath =
    "/images/blank_woman.png"
