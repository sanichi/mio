module Config exposing (boxHeight, boxRadius, centerY, changePicture, defaultCenter, deltaShift, fontHeight, fontWidth, fontWidthToHeight, height, levelHeight, margin, missingPicturePath, padding, pictureSize, pointerFontHeight, pointerFontWidth, smallFontHeight, smallFontWidth, smallTextWidth, switchBoxHeight, switchBoxRadius, textWidth, viewBox, width)

import String


boxHeight : Int
boxHeight =
    50


boxRadius : Int
boxRadius =
    0


centerY : Int -> Int
centerY level =
    (levelHeight * (2 * level - 1) - pictureSize - margin) // 2


changePicture : Float
changePicture =
    4000


defaultCenter : Int
defaultCenter =
    width // 2 - 100


deltaShift : Int
deltaShift =
    100


fontHeight : Int
fontHeight =
    14


fontWidth : Int
fontWidth =
    fontWidthToHeight fontHeight


fontWidthToHeight : Int -> Int
fontWidthToHeight wid =
    wid * 6 // 10


height : Int
height =
    3 * levelHeight


pointerFontHeight : Int
pointerFontHeight =
    30


pointerFontWidth : Int
pointerFontWidth =
    fontWidthToHeight pointerFontHeight


levelHeight : Int
levelHeight =
    boxHeight + pictureSize + 3 * margin


margin : Int
margin =
    18


missingPicturePath : String
missingPicturePath =
    "/images/blank_woman.png"


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
    fontWidthToHeight smallFontHeight


smallTextWidth : String -> Int
smallTextWidth text =
    String.length text * smallFontWidth


switchBoxHeight : Int
switchBoxHeight =
    30


switchBoxRadius : Int
switchBoxRadius =
    8


textWidth : String -> Int -> Int
textWidth text minLen =
    String.length text * fontWidth |> Basics.max minLen


viewBox : String
viewBox =
    String.join " " [ "0 0", String.fromInt width, String.fromInt height ]


width : Int
width =
    1000
