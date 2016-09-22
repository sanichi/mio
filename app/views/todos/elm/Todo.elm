module Todo exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Http
import Json.Decode as Decode exposing ((:=))
import String
import Task exposing (Task)
import Misc exposing (..)
import Util exposing (..)


-- MODEL


type alias Todo =
    { description : String
    , done : Bool
    , id : Int
    , priority : Int
    , editingDescription : Bool
    , newDescription : String
    }


blank : Todo
blank =
    { description = ""
    , done = False
    , id = 0
    , priority = highPriority
    , editingDescription = False
    , newDescription = ""
    }


decode : Decode.Decoder Todo
decode =
    Decode.object6 Todo
        ("description" := Decode.string)
        ("done" := Decode.bool)
        ("id" := Decode.int)
        ("priority" := Decode.int)
        (Decode.succeed False)
        (Decode.succeed "")


order : Todo -> Todo -> Order
order t1 t2 =
    if t1.id == 0 || t2.id == 0 then
        compare t2.id t1.id
    else if xor t1.done t2.done then
        if t1.done then
            GT
        else
            LT
    else if t1.priority == t2.priority then
        compare t1.description t2.description
    else
        compare t1.priority t2.priority



-- Utilities


priority : Todo -> String
priority t =
    Maybe.withDefault "Unknown" (Dict.get t.priority i18Priorities)


class : Todo -> String
class todo =
    if todo.done then
        "inactive"
    else
        "active"


changeable : Todo -> Bool -> Bool
changeable t bool =
    if bool then
        t.priority > highPriority
    else
        t.priority < lowPriority



-- Requests


delete : Int -> Task Http.Error Int
delete id =
    if id > 0 then
        let
            request =
                postRequest (updateAndDeleteUrl id) (Http.string "_method=delete")
        in
            Http.fromJson Decode.int (Http.send Http.defaultSettings request)
    else
        Task.fail <| Http.UnexpectedPayload "can't delete todos unless ID > 0"


update : Todo -> Task Http.Error Todo
update t =
    if t.id > 0 then
        let
            body =
                Http.string <|
                    String.join "&"
                        [ "todo%5Bdescription%5D=" ++ (Http.uriEncode t.description)
                        , "todo%5Bpriority%5D=" ++ (toString t.priority)
                        , "todo%5Bdone%5D="
                            ++ if t.done then
                                "1"
                               else
                                "0"
                        , "_method=patch"
                        , "commit=Save"
                        , "utf8=✓"
                        ]

            request =
                postRequest (updateAndDeleteUrl t.id) body
        in
            Http.fromJson decode (Http.send Http.defaultSettings request)
    else
        Task.fail <| Http.UnexpectedPayload "can't update todos unless ID > 0"


create : Todo -> Task Http.Error Todo
create t =
    if t.id == 0 then
        let
            body =
                Http.string <|
                    String.join "&"
                        [ "todo%5Bdescription%5D=" ++ (Http.uriEncode t.description)
                        , "todo%5Bpriority%5D=" ++ (toString t.priority)
                        , "commit=Save"
                        , "utf8=✓"
                        ]

            request =
                postRequest indexAndCreateUrl body
        in
            Http.fromJson decode (Http.send Http.defaultSettings request)
    else
        Task.fail <| Http.UnexpectedPayload "can't create todos unless ID = 0"
