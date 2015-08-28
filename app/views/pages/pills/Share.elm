module Share where

import Color exposing (lightBlue, lightRed, black, darkGray)

width = 500
height = 500

hWidth = width / 2
hHeight = height / 2

defPillCol = lightRed
defPillRad = 15
defPillVel = 400
defPlayerCol = black
capturePillCol = lightBlue

capturePillProb = 0.2

spawnInterval = 57 / defPillVel
frameRate = 30

textCol = darkGray
lineHeight = 50
