module Tree exposing (tree)

-- local modules

import Array exposing (Array)
import Config
import Messages exposing (Msg(..))
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (..)
import Tuple exposing (first, second)
import Types exposing (..)



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



-- the only exported function


tree : Model -> List (Svg Msg)
tree model =
    let
        focus =
            model.focus

        center =
            Config.defaultCenter + model.shift

        focusBox =
            box focus.person model.picture center 2 True

        ( fatherBox, motherBox, parentLinks ) =
            parentBoxes focusBox focus.father focus.mother model.picture

        ( oSibBoxes, oSibLinks ) =
            siblingBoxes focusBox focus.olderSiblings model.picture Nothing

        ( ( partBoxes, partLinks ), ( shiftRight, parentPoint ) ) =
            partnerBoxes focusBox focus.families model.family model.picture

        ( ySibBoxes, ySibLinks ) =
            siblingBoxes focusBox focus.youngerSiblings model.picture (Just shiftRight)

        ( childBoxes, childLinks ) =
            childrenBoxes focusBox focus.families model.family model.picture parentPoint

        allBoxes =
            [ focusBox, fatherBox, motherBox ] ++ List.concat [ oSibBoxes, ySibBoxes, partBoxes, childBoxes ]

        boxSvgs =
            List.map .svgs allBoxes |> List.concat

        linkSvgs =
            List.concat [ parentLinks, oSibLinks, ySibLinks, partLinks, childLinks ]

        pointerSvgs =
            pointers allBoxes
    in
    boxSvgs ++ linkSvgs ++ pointerSvgs



-- boxes


box : Person -> Int -> Int -> Int -> Bool -> Box
box person pictureIndex centerX level focus =
    let
        centerY =
            Config.centerY level

        boxClass =
            if focus then
                "focus"

            else
                "box"

        name =
            person.name

        nameWidth =
            Config.textWidth name 70

        nameX =
            centerX

        nameY =
            centerY - Config.fontHeight // 3

        nameClass =
            "medium " ++ boxClass

        years =
            person.years

        yearsWidth =
            Config.smallTextWidth years

        yearsX =
            centerX

        yearsY =
            centerY + Config.fontHeight

        yearsClass =
            "small " ++ boxClass

        maxWidth =
            Basics.max nameWidth yearsWidth

        bxWidth =
            maxWidth + 2 * Config.padding

        boxX =
            centerX - bxWidth // 2

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

        msg =
            if person.id > 0 then
                if focus then
                    DisplayPerson person.id

                else
                    GetFocus person.id

            else
                NoOp

        handler =
            onClick msg

        topX =
            centerX

        top =
            { inner = ( topX, boxY ), outer = ( topX, boxY - Config.margin ) }

        leftRightY =
            boxY + Config.boxHeight // 2

        left =
            { inner = ( boxX, leftRightY ), outer = ( Basics.min boxX pictureX - Config.margin, leftRightY ) }

        right =
            { inner = ( boxX + bxWidth, leftRightY ), outer = ( Basics.max (boxX + bxWidth) (pictureX + pictureWidth) + Config.margin, leftRightY ) }

        svgs =
            [ rect (rectAttrs boxClass boxX boxY Config.boxRadius bxWidth Config.boxHeight handler) []
            , text_ (textAttrs nameClass nameX nameY nameWidth handler) [ text name ]
            , text_ (textAttrs yearsClass yearsX yearsY yearsWidth handler) [ text years ]
            , image (imageAttrs picture pictureX pictureY pictureWidth pictureHeight handler) []
            ]
    in
    { svgs = svgs
    , top = top
    , left = left
    , right = right
    }


switcherBox : Families -> Int -> Int -> Maybe Box
switcherBox families index centerX =
    let
        len =
            Array.length families
    in
    if len < 2 then
        Nothing

    else
        let
            centerY =
                Config.centerY 2

            boxClass =
                "box"

            label =
                String.fromInt (index + 1) ++ " of " ++ String.fromInt len

            labelWidth =
                Config.textWidth label 40

            labelX =
                centerX

            labelY =
                centerY + Config.fontHeight // 3

            labelClass =
                "medium " ++ boxClass

            bxWidth =
                labelWidth + 2 * Config.padding

            boxX =
                centerX - bxWidth // 2

            boxY =
                centerY - Config.switchBoxHeight // 2

            nextIndex =
                if index + 1 >= len then
                    0

                else
                    index + 1

            handler =
                SwitchFamily nextIndex |> onClick

            topX =
                centerX

            top =
                { inner = ( topX, boxY ), outer = ( topX, boxY - Config.margin ) }

            leftRightY =
                boxY + Config.switchBoxHeight // 2

            left =
                { inner = ( boxX, leftRightY ), outer = ( boxX - Config.margin, leftRightY ) }

            right =
                { inner = ( boxX + bxWidth, leftRightY ), outer = ( boxX + bxWidth + Config.margin, leftRightY ) }

            svgs =
                [ rect (rectAttrs boxClass boxX boxY Config.switchBoxRadius bxWidth Config.switchBoxHeight handler) []
                , text_ (textAttrs labelClass labelX labelY labelWidth handler) [ text label ]
                ]

            bx =
                { svgs = svgs
                , top = top
                , left = left
                , right = right
                }
        in
        Just bx


shiftBox : Int -> Box -> Box
shiftBox deltaX bx =
    let
        transformX =
            "translate(" ++ String.fromInt deltaX ++ ",0)"
    in
    { svgs = [ g [ transform transformX ] bx.svgs ]
    , top = shiftHandle deltaX bx.top
    , left = shiftHandle deltaX bx.left
    , right = shiftHandle deltaX bx.right
    }


parentBoxes : Box -> Person -> Person -> Int -> ( Box, Box, List (Svg Msg) )
parentBoxes focusBox father mother picture =
    let
        center =
            middleBox focusBox

        fatherBox =
            box father picture center 1 False

        motherBox =
            box mother picture center 1 False

        leftFatherBox =
            shiftBox (center - first fatherBox.right.outer) fatherBox

        rightMotherBox =
            shiftBox (center - first motherBox.left.outer) motherBox

        parentLinks =
            linkT leftFatherBox rightMotherBox focusBox
    in
    ( leftFatherBox, rightMotherBox, parentLinks )


siblingBoxes : Box -> People -> Int -> Maybe Int -> ( List Box, List (Svg Msg) )
siblingBoxes focusBox people picture shift =
    let
        center =
            middleBox focusBox

        focusHalfWidth =
            boxWidth focusBox // 2

        boxes =
            Array.map (\p -> box p picture center 2 False) people

        widths =
            Array.map boxWidth boxes

        len =
            Array.length widths

        widthsToShifts i w =
            case shift of
                Nothing ->
                    Array.slice i len widths
                        |> Array.toList
                        |> List.sum
                        |> (+) focusHalfWidth
                        |> (-) (w // 2)

                Just s ->
                    Array.slice 0 (i + 1) widths
                        |> Array.toList
                        |> List.sum
                        |> (+) focusHalfWidth
                        |> (+) s
                        |> (\x -> x - w // 2)

        shifts =
            Array.indexedMap widthsToShifts widths

        shiftedBoxes =
            Array.indexedMap (\i b -> shiftBox (getWithDefault i 0 shifts) b) boxes |> Array.toList

        verticalLinks =
            List.map .top shiftedBoxes |> List.map handleToLink

        furthestBox =
            case shift of
                Nothing ->
                    List.head shiftedBoxes

                Just s ->
                    List.reverse shiftedBoxes |> List.head

        horizontalLinks =
            linkH focusBox furthestBox
    in
    ( shiftedBoxes, verticalLinks ++ horizontalLinks )


partnerBoxes : Box -> Families -> Int -> Int -> ( ( List Box, List (Svg Msg) ), ( Int, Point ) )
partnerBoxes focusBox families index picture =
    let
        item =
            Array.get index families
    in
    case item of
        Nothing ->
            ( ( [], [] ), ( 0, ( 0, 0 ) ) )

        Just family ->
            let
                center =
                    middleBox focusBox

                halfFocusWidth =
                    boxWidth focusBox // 2

                partner =
                    family.partner

                partnerBox =
                    box partner picture center 2 False

                partnerWidth =
                    boxWidth partnerBox

                switchBox =
                    switcherBox families index center

                switchWidth =
                    case switchBox of
                        Nothing ->
                            0

                        Just bx ->
                            boxWidth bx

                switchShift =
                    case switchBox of
                        Nothing ->
                            0

                        Just bx ->
                            halfFocusWidth + switchWidth // 2

                shiftedSwitchBox =
                    case switchBox of
                        Nothing ->
                            Nothing

                        Just bx ->
                            Just (shiftBox switchShift bx)

                partnerShift =
                    halfFocusWidth + switchWidth + partnerWidth // 2

                shiftedPartnerBox =
                    shiftBox partnerShift partnerBox

                siblingShift =
                    switchWidth + partnerWidth

                boxes =
                    case shiftedSwitchBox of
                        Nothing ->
                            [ shiftedPartnerBox ]

                        Just bx ->
                            [ bx, shiftedPartnerBox ]

                links =
                    case shiftedSwitchBox of
                        Nothing ->
                            linkM focusBox shiftedPartnerBox

                        Just bx ->
                            linkM focusBox bx ++ linkM bx shiftedPartnerBox

                parentPoint =
                    case shiftedSwitchBox of
                        Nothing ->
                            focusBox.right.outer

                        Just bx ->
                            ( first bx.top.inner, second bx.top.inner + Config.switchBoxHeight )
            in
            ( ( boxes, links ), ( siblingShift, parentPoint ) )


childrenBoxes : Box -> Families -> Int -> Int -> Point -> ( List Box, List (Svg Msg) )
childrenBoxes focusBox families index picture parentPoint =
    let
        item =
            Array.get index families
    in
    case item of
        Nothing ->
            ( [], [] )

        Just family ->
            let
                people =
                    family.children
            in
            if Array.isEmpty people then
                ( [], [] )

            else
                let
                    center =
                        first parentPoint

                    boxes =
                        Array.map (\p -> box p picture center 3 False) people

                    widths =
                        Array.map boxWidth boxes

                    len =
                        Array.length widths

                    halfWidth =
                        (Array.toList widths |> List.sum) // 2

                    widthsToShifts i w =
                        Array.slice i len widths
                            |> Array.toList
                            |> List.sum
                            |> (-) (w // 2)
                            |> (\s -> s + halfWidth)

                    shifts =
                        Array.indexedMap widthsToShifts widths

                    shiftedBoxes =
                        Array.indexedMap (\i b -> shiftBox (getWithDefault i 0 shifts) b) boxes |> Array.toList

                    verticalLinks =
                        List.map .top shiftedBoxes |> List.map handleToLink

                    otherLinks =
                        linkO shiftedBoxes parentPoint
                in
                ( shiftedBoxes, verticalLinks ++ otherLinks )



-- attributes for SVG primitives


imageAttrs : String -> Int -> Int -> Int -> Int -> Svg.Attribute Msg -> List (Svg.Attribute Msg)
imageAttrs l i j w h handler =
    [ xlinkHref l, x (String.fromInt i), y (String.fromInt j), width (String.fromInt w), height (String.fromInt h), handler ]


rectAttrs : String -> Int -> Int -> Int -> Int -> Int -> Svg.Attribute Msg -> List (Svg.Attribute Msg)
rectAttrs c i j r w h handler =
    [ class c, x (String.fromInt i), y (String.fromInt j), rx (String.fromInt r), ry (String.fromInt r), width (String.fromInt w), height (String.fromInt h), handler ]


textAttrs : String -> Int -> Int -> Int -> Svg.Attribute Msg -> List (Svg.Attribute Msg)
textAttrs c i j l handler =
    [ class c, x (String.fromInt i), y (String.fromInt j), textLength (String.fromInt l), handler ]


pointerAttrs : String -> Int -> Int -> Svg.Attribute Msg -> List (Svg.Attribute Msg)
pointerAttrs c i j handler =
    [ class c, x (String.fromInt i), y (String.fromInt j), handler ]



-- lines linking boxes


linkT : Box -> Box -> Box -> List (Svg Msg)
linkT left right below =
    let
        ax1 =
            first left.right.inner |> String.fromInt

        ay1 =
            second left.right.inner |> String.fromInt

        ax2 =
            first right.left.inner |> String.fromInt

        ay2 =
            second right.left.inner |> String.fromInt

        bx1 =
            (first left.right.outer + first right.left.outer) // 2 |> String.fromInt

        by1 =
            (second left.right.outer + second right.left.outer) // 2 |> String.fromInt

        bx2 =
            first below.top.inner |> String.fromInt

        by2 =
            second below.top.inner |> String.fromInt
    in
    [ line [ x1 ax1, y1 ay1, x2 ax2, y2 ay2 ] []
    , line [ x1 bx2, y1 by1, x2 bx2, y2 by2 ] []
    ]


linkH : Box -> Maybe Box -> List (Svg Msg)
linkH bx1 mbx2 =
    case mbx2 of
        Nothing ->
            []

        Just bx2 ->
            let
                i1 =
                    first bx1.top.outer |> String.fromInt

                j1 =
                    second bx1.top.outer |> String.fromInt

                i2 =
                    first bx2.top.outer |> String.fromInt

                j2 =
                    second bx2.top.outer |> String.fromInt
            in
            [ line [ x1 i1, y1 j1, x2 i2, y2 j2 ] [] ]


linkM : Box -> Box -> List (Svg Msg)
linkM bx1 bx2 =
    let
        i1 =
            first bx1.right.inner |> String.fromInt

        j1 =
            second bx1.right.inner |> String.fromInt

        i2 =
            first bx2.left.inner |> String.fromInt

        j2 =
            second bx2.left.inner |> String.fromInt
    in
    [ line [ x1 i1, y1 j1, x2 i2, y2 j2 ] [] ]


linkO : List Box -> Point -> List (Svg Msg)
linkO boxes point =
    let
        b1 =
            List.head boxes

        b2 =
            List.reverse boxes |> List.head

        vertical =
            case b1 of
                Just bx ->
                    let
                        i1 =
                            first point |> String.fromInt

                        j1 =
                            second point |> String.fromInt

                        i2 =
                            first point |> String.fromInt

                        j2 =
                            second bx.top.outer |> String.fromInt
                    in
                    Just (line [ x1 i1, y1 j1, x2 i2, y2 j2 ] [])

                _ ->
                    Nothing

        horizontal =
            case ( b1, b2 ) of
                ( Just bx1, Just bx2 ) ->
                    let
                        i1 =
                            first bx1.top.outer |> String.fromInt

                        j1 =
                            second bx1.top.outer |> String.fromInt

                        i2 =
                            first bx2.top.outer |> String.fromInt

                        j2 =
                            second bx2.top.outer |> String.fromInt
                    in
                    Just (line [ x1 i1, y1 j1, x2 i2, y2 j2 ] [])

                _ ->
                    Nothing
    in
    case ( vertical, horizontal ) of
        ( Just v, Just h ) ->
            [ v, h ]

        _ ->
            []



-- various other utilities


boxWidth : Box -> Int
boxWidth bx =
    first bx.right.outer - first bx.left.outer


currentPicturePath : Person -> Int -> String
currentPicturePath person picture =
    let
        total =
            Array.length person.pictures

        index =
            if total < 1 then
                0

            else
                modBy total picture
    in
    Array.get index person.pictures |> Maybe.withDefault Config.missingPicturePath


getWithDefault : Int -> a -> Array a -> a
getWithDefault index default array =
    let
        notsure =
            Array.get index array
    in
    case notsure of
        Just value ->
            value

        Nothing ->
            default


handleToLink : Handle -> Svg Msg
handleToLink handle =
    let
        i1 =
            first handle.inner |> String.fromInt

        j1 =
            second handle.inner |> String.fromInt

        i2 =
            first handle.outer |> String.fromInt

        j2 =
            second handle.outer |> String.fromInt
    in
    line [ x1 i1, y1 j1, x2 i2, y2 j2 ] []


middleBox : Box -> Int
middleBox bx =
    first bx.top.inner


pointers : List Box -> List (Svg Msg)
pointers boxes =
    let
        leftMost =
            List.map (\b -> first b.left.outer) boxes |> List.minimum |> Maybe.withDefault 0

        rightMost =
            List.map (\b -> first b.right.outer) boxes |> List.maximum |> Maybe.withDefault Config.width

        leftPointer =
            let
                i =
                    Config.pointerFontWidth

                j =
                    Config.pointerFontHeight

                h =
                    onClick ShiftLeft
            in
            text_ (pointerAttrs "pointer" i j h) [ text "☜" ]

        rightPointer =
            let
                i =
                    Config.width - Config.pointerFontWidth

                j =
                    Config.pointerFontHeight

                h =
                    onClick ShiftRight
            in
            text_ (pointerAttrs "pointer" i j h) [ text "☞" ]
    in
    case ( leftMost < 0, rightMost > Config.width ) of
        ( True, True ) ->
            [ leftPointer, rightPointer ]

        ( True, False ) ->
            [ leftPointer ]

        ( False, True ) ->
            [ rightPointer ]

        ( False, False ) ->
            []


shiftHandle : Int -> Handle -> Handle
shiftHandle deltaX handle =
    { inner = shiftPoint deltaX handle.inner, outer = shiftPoint deltaX handle.outer }


shiftPoint : Int -> Point -> Point
shiftPoint deltaX point =
    ( first point + deltaX, second point )
