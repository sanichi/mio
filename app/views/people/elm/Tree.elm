module Tree exposing (tree)

import Array exposing (Array)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (..)


-- local modules

import Config
import Messages exposing (Msg(..))
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
            Config.width // 2

        focusBox =
            box focus.person model.picture center 2 True

        ( fatherBox, motherBox, parentLinks ) =
            parentBoxes focusBox focus.father focus.mother model.picture

        ( oSibBoxes, oSibLinks ) =
            siblingBoxes focusBox focus.olderSiblings model.picture Nothing

        ( partBoxes, partLinks, shiftRight, parentPoint ) =
            partnerBoxes focusBox focus.families model.family model.picture

        ( ySibBoxes, ySibLinks ) =
            siblingBoxes focusBox focus.youngerSiblings model.picture shiftRight

        ( childBoxes, childLinks ) =
            childrenBoxes focusBox focus.families model.family model.picture parentPoint

        allBoxes =
            [ focusBox, fatherBox, motherBox ] ++ List.concat [ oSibBoxes, ySibBoxes, partBoxes, childBoxes ]

        boxSvgs =
            List.map .svgs allBoxes |> List.concat

        linkSvgs =
            List.concat [ parentLinks, oSibLinks, ySibLinks, partLinks, childLinks ]
    in
        boxSvgs ++ linkSvgs



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
            { inner = ( boxX + boxWidth, leftRightY ), outer = ( Basics.max (boxX + boxWidth) (pictureX + pictureWidth) + Config.margin, leftRightY ) }

        svgs =
            [ rect (rectAttrs boxClass boxX boxY Config.boxRadius boxWidth Config.boxHeight handler) []
            , text' (textAttrs nameClass nameX nameY nameWidth handler) [ text name ]
            , text' (textAttrs yearsClass yearsX yearsY yearsWidth handler) [ text years ]
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
                    toString (index + 1) ++ " of " ++ toString len

                labelWidth =
                    Config.textWidth label 40

                labelX =
                    centerX

                labelY =
                    centerY + Config.fontHeight // 3

                labelClass =
                    "medium " ++ boxClass

                boxWidth =
                    labelWidth + 2 * Config.padding

                boxX =
                    centerX - boxWidth // 2

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
                    { inner = ( boxX + boxWidth, leftRightY ), outer = ( boxX + boxWidth + Config.margin, leftRightY ) }

                svgs =
                    [ rect (rectAttrs boxClass boxX boxY Config.switchBoxRadius boxWidth Config.switchBoxHeight handler) []
                    , text' (textAttrs labelClass labelX labelY labelWidth handler) [ text label ]
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
            "translate(" ++ toString deltaX ++ ",0)"
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
            shiftBox (center - fst fatherBox.right.outer) fatherBox

        rightMotherBox =
            shiftBox (center - fst motherBox.left.outer) motherBox

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
                        |> (+) s
                        |> \x -> x - w // 2

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


partnerBoxes : Box -> Families -> Int -> Int -> ( List Box, List (Svg Msg), Maybe Int, Point )
partnerBoxes focusBox families index picture =
    let
        item =
            Array.get index families
    in
        case item of
            Nothing ->
                ( [], [], Nothing, ( 0, 0 ) )

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
                        halfFocusWidth + switchWidth + partnerWidth

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
                                ( fst bx.top.inner, snd bx.top.inner + Config.switchBoxHeight )
                in
                    ( boxes, links, Just siblingShift, parentPoint )


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
                                fst parentPoint

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
                                    |> \s -> s + halfWidth

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



--
-- furthestBox =
--     case shift of
--         Nothing ->
--             List.head shiftedBoxes
--
--         Just s ->
--             List.reverse shiftedBoxes |> List.head
--
-- horizontalLinks =
--     linkH focusBox furthestBox
--                 in
--                     ( [], [] )
-- attributes for SVG primitives


imageAttrs : String -> Int -> Int -> Int -> Int -> Svg.Attribute Msg -> List (Svg.Attribute Msg)
imageAttrs l i j w h handler =
    [ xlinkHref l, x (toString i), y (toString j), width (toString w), height (toString h), handler ]


rectAttrs : String -> Int -> Int -> Int -> Int -> Int -> Svg.Attribute Msg -> List (Svg.Attribute Msg)
rectAttrs c i j r w h handler =
    [ class c, x (toString i), y (toString j), rx (toString r), ry (toString r), width (toString w), height (toString h), handler ]


textAttrs : String -> Int -> Int -> Int -> Svg.Attribute Msg -> List (Svg.Attribute Msg)
textAttrs c i j l handler =
    [ class c, x (toString i), y (toString j), textLength (toString l), handler ]



-- lines linking boxes


linkT : Box -> Box -> Box -> List (Svg Msg)
linkT left right below =
    let
        ax1 =
            fst left.right.inner |> toString

        ay1 =
            snd left.right.inner |> toString

        ax2 =
            fst right.left.inner |> toString

        ay2 =
            snd right.left.inner |> toString

        bx1 =
            (fst left.right.outer + fst right.left.outer) // 2 |> toString

        by1 =
            (snd left.right.outer + snd right.left.outer) // 2 |> toString

        bx2 =
            fst below.top.inner |> toString

        by2 =
            snd below.top.inner |> toString
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
                    fst bx1.top.outer |> toString

                j1 =
                    snd bx1.top.outer |> toString

                i2 =
                    fst bx2.top.outer |> toString

                j2 =
                    snd bx2.top.outer |> toString
            in
                [ line [ x1 i1, y1 j1, x2 i2, y2 j2 ] [] ]


linkM : Box -> Box -> List (Svg Msg)
linkM bx1 bx2 =
    let
        i1 =
            fst bx1.right.inner |> toString

        j1 =
            snd bx1.right.inner |> toString

        i2 =
            fst bx2.left.inner |> toString

        j2 =
            snd bx2.left.inner |> toString
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
                            fst point |> toString

                        j1 =
                            snd point |> toString

                        i2 =
                            fst point |> toString

                        j2 =
                            snd bx.top.outer |> toString
                    in
                        Just (line [ x1 i1, y1 j1, x2 i2, y2 j2 ] [])

                _ ->
                    Nothing

        horizontal =
            case ( b1, b2 ) of
                ( Just bx1, Just bx2 ) ->
                    let
                        i1 =
                            fst bx1.top.outer |> toString

                        j1 =
                            snd bx1.top.outer |> toString

                        i2 =
                            fst bx2.top.outer |> toString

                        j2 =
                            snd bx2.top.outer |> toString
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
    fst bx.right.outer - fst bx.left.outer


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
            fst handle.inner |> toString

        j1 =
            snd handle.inner |> toString

        i2 =
            fst handle.outer |> toString

        j2 =
            snd handle.outer |> toString
    in
        line [ x1 i1, y1 j1, x2 i2, y2 j2 ] []


middleBox : Box -> Int
middleBox bx =
    fst bx.top.inner


shiftHandle : Int -> Handle -> Handle
shiftHandle deltaX handle =
    { inner = shiftPoint deltaX handle.inner, outer = shiftPoint deltaX handle.outer }


shiftPoint : Int -> Point -> Point
shiftPoint deltaX point =
    ( fst point + deltaX, snd point )
