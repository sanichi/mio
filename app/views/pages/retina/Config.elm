module Config exposing (cells, cellSize, getRandomVals, height, viewBox, width)

import Random exposing (Generator)
import String


-- local modules

import Messages exposing (Msg(..))


height : Int
height =
    cells * cellSize


cells : Int
cells =
    100


cellSize : Int
cellSize =
    10


generateRandomVals : Generator (List Float)
generateRandomVals =
    Random.list (cells * cells) (Random.float 0 1)


getRandomVals : Cmd Msg
getRandomVals =
    Random.generate NewValues generateRandomVals


viewBox : String
viewBox =
    String.join " " [ "0 0", toString width, toString height ]


width : Int
width =
    cells * cellSize
