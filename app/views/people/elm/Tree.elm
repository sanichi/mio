module Tree exposing (..)

import Array
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (..)


-- local modules

import Config
import Messages exposing (Msg(..))
import Types exposing (Model, Focus, Person)


-- local types


type alias Point =
    ( Int, Int )


type alias Handle =
    { inner : Point
    , outer : Point
    }


type alias Box =
    { svgs : List (Svg Msg)
    , top : Handle
    , left : Handle
    , right : Handle
    }


tree : Model -> List (Svg Msg)
tree model =
    let
        focus =
            model.focus

        center =
            Config.width // 2

        focusBox =
            box focus.person model.picture center 2

        ( fatherBox, motherBox, parentLinks ) =
            parentBoxes focusBox focus.father focus.mother model.picture center

        boxSvgs =
            List.map .svgs [ focusBox, fatherBox, motherBox ] |> List.concat

        linkSvgs =
            List.concat [ parentLinks ]
    in
        boxSvgs ++ linkSvgs



-- boxes


box : Person -> Int -> Int -> Int -> Box
box person pictureIndex centerX level =
    let
        centerY =
            Config.centerY level

        name =
            person.name

        nameWidth =
            Config.textWidth name

        nameX =
            centerX

        nameY =
            centerY - Config.fontHeight // 3

        years =
            person.years

        yearsWidth =
            Config.smallTextWidth years

        yearsX =
            centerX

        yearsY =
            centerY + Config.fontHeight

        maxWidth =
            Basics.max nameWidth yearsWidth

        boxWidth =
            maxWidth + 2 * Config.padding

        boxX =
            centerX - boxWidth // 2

        boxY =
            centerY - Config.boxHeight // 2

        picture =
            currentPicturePath person pictureIndex

        pictureWidth =
            Config.pictureSize

        pictureHeight =
            Config.pictureSize

        pictureX =
            centerX - pictureWidth // 2

        pictureY =
            centerY + Config.margin + Config.boxHeight // 2

        topX =
            centerX

        top =
            { inner = ( topX, boxY ), outer = ( topX, boxY - Config.margin ) }

        leftRightY =
            boxY + Config.boxHeight // 2

        left =
            { inner = ( boxX, leftRightY ), outer = ( Basics.min boxX pictureX - Config.margin, leftRightY ) }

        right =
            { inner = ( boxX + boxWidth, leftRightY ), outer = ( Basics.max (boxX + boxWidth) (pictureX + pictureWidth) + Config.margin, leftRightY ) }

        svgs =
            [ rect (rectAttrs "box" boxX boxY boxWidth Config.boxHeight) []
            , text' (textAttrs "medium" nameX nameY nameWidth) [ text name ]
            , text' (textAttrs "small" yearsX yearsY yearsWidth) [ text years ]
            , image (imageAttrs picture pictureX pictureY pictureWidth pictureHeight person.id) []
            ]
    in
        { svgs = svgs
        , top = top
        , left = left
        , right = right
        }


shiftBox : Int -> Box -> Box
shiftBox centerX bx =
    let
        currentX =
            (fst bx.left.inner + fst bx.right.inner) // 2

        deltaX =
            currentX - centerX

        transformX =
            "translate(" ++ toString deltaX ++ ",0)"
    in
        { svgs = [ g [ transform transformX ] bx.svgs ]
        , top = shiftHandle deltaX bx.top
        , left = shiftHandle deltaX bx.left
        , right = shiftHandle deltaX bx.right
        }


parentBoxes : Box -> Person -> Person -> Int -> Int -> ( Box, Box, List (Svg Msg) )
parentBoxes focusBox father mother picture center =
    let
        fatherBox =
            box father picture center 1

        motherBox =
            box mother picture center 1

        leftFatherBox =
            shiftBox (fst fatherBox.right.outer) fatherBox

        rightMotherBox =
            shiftBox (fst motherBox.left.outer) motherBox

        parentLinks =
            linkT leftFatherBox rightMotherBox focusBox
    in
        ( leftFatherBox, rightMotherBox, parentLinks )



-- points and handles


shiftHandle : Int -> Handle -> Handle
shiftHandle deltaX handle =
    { inner = shiftPoint deltaX handle.inner, outer = shiftPoint deltaX handle.outer }


shiftPoint : Int -> Point -> Point
shiftPoint deltaX point =
    ( fst point + deltaX, snd point )



-- lines linking boxes


linkT : Box -> Box -> Box -> List (Svg Msg)
linkT left right below =
    let
        ax1 =
            left.right.inner |> fst |> toString

        ay1 =
            left.right.inner |> snd |> toString

        ax2 =
            right.left.inner |> fst |> toString

        ay2 =
            right.left.inner |> snd |> toString

        bx1 =
            ((fst left.right.outer) + (fst right.left.outer)) // 2 |> toString

        by1 =
            ((snd left.right.outer) + (snd right.left.outer)) // 2 |> toString

        bx2 =
            below.top.inner |> fst |> toString

        by2 =
            below.top.inner |> snd |> toString
    in
        [ line [ x1 ax1, y1 ay1, x2 ax2, y2 ay2 ] []
        , line [ x1 bx2, y1 by1, x2 bx2, y2 by2 ] []
        ]



-- attributes for SVG primitives


imageAttrs : String -> Int -> Int -> Int -> Int -> Int -> List (Svg.Attribute Msg)
imageAttrs l i j w h id =
    let
        handler =
            if id > 0 then
                onClick (PersonId id)
            else
                onClick NoOp
    in
        [ xlinkHref l, x (toString i), y (toString j), width (toString w), height (toString h), handler ]


rectAttrs : String -> Int -> Int -> Int -> Int -> List (Svg.Attribute Msg)
rectAttrs c i j w h =
    [ class c, x (toString i), y (toString j), width (toString w), height (toString h) ]


textAttrs : String -> Int -> Int -> Int -> List (Svg.Attribute Msg)
textAttrs c i j l =
    [ class c, x (toString i), y (toString j), textLength (toString l) ]



-- various utilities


currentPicturePath : Person -> Int -> String
currentPicturePath person picture =
    let
        total =
            Array.length person.pictures

        index =
            if total < 1 then
                0
            else
                picture % total
    in
        Array.get index person.pictures |> Maybe.withDefault Config.missingPicturePath
