module Main exposing (..)

import Html exposing (..)
import Html.App exposing (program)
import Html.Attributes exposing (..)
import Html.Events as Events exposing (onClick, onInput)
import Http
import Task


--- Local modules

import Misc exposing (..)
import Todos exposing (Todos)
import Todo exposing (Todo)
import Util exposing (..)


-- Main program and models


main : Program Never
main =
    program
        { init = ( init, todosRequest )
        , view = view
        , update = update
        , subscriptions = (\model -> Sub.none)
        }


type alias Model =
    { todos : Todos
    , lastUpdated : Int
    , maybeDelete : Int
    , error : Maybe String
    }


init : Model
init =
    { todos = []
    , lastUpdated = 0
    , maybeDelete = 0
    , error = Nothing
    }



-- Commands


todosRequest : Cmd Msg
todosRequest =
    Task.perform FailedRequest TodosSuccess Todos.get


todoUpdateRequest : Todo -> Cmd Msg
todoUpdateRequest t =
    Task.perform FailedRequest TodoUpdateSuccess <| Todo.update t


todoCreateRequest : Todo -> Cmd Msg
todoCreateRequest t =
    Task.perform FailedRequest TodoCreateSuccess <| Todo.create t


todoDeleteRequest : Int -> Cmd Msg
todoDeleteRequest id =
    Task.perform FailedRequest DeleteSuccess <| Todo.delete id



-- Update


type Msg
    = NoOp
    | CancelDelete
    | DeleteSuccess Int
    | EditDescription Int
    | FailedRequest Http.Error
    | MaybeDelete Int
    | NewDescription ( Int, String )
    | RequestDelete Int
    | RequestUpdate Todo
    | TodoCreateSuccess Todo
    | TodoUpdateSuccess Todo
    | TodosSuccess Todos
    | SubmitCreate
    | SubmitDescription


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FailedRequest err ->
            ( { model | error = Just (httpErr err) }, Cmd.none )

        TodosSuccess todos ->
            let
                newTodos =
                    List.map (\t -> { t | newDescription = t.description }) (Todo.blank :: todos)
            in
                ( { model | todos = newTodos }, Cmd.none )

        TodoUpdateSuccess todo ->
            let
                newTodo t =
                    if t.id == todo.id then
                        { todo | newDescription = todo.description }
                    else
                        { t | newDescription = t.description }

                newModel =
                    { model
                        | todos = List.map newTodo model.todos
                        , lastUpdated = todo.id
                        , maybeDelete = 0
                        , error = Nothing
                    }
            in
                ( newModel, Cmd.none )

        TodoCreateSuccess todo ->
            let
                newTodos t =
                    if t.id == 0 then
                        { t | newDescription = "" }
                    else
                        t

                newModel =
                    { model
                        | todos = { todo | newDescription = todo.description } :: (List.map newTodos model.todos)
                        , lastUpdated = todo.id
                        , maybeDelete = 0
                        , error = Nothing
                    }
            in
                ( newModel, Cmd.none )

        RequestUpdate todo ->
            ( model, todoUpdateRequest todo )

        MaybeDelete id ->
            let
                newModel =
                    { model
                        | maybeDelete = id
                        , lastUpdated = 0
                        , error = Nothing
                    }
            in
                ( newModel, Cmd.none )

        CancelDelete ->
            let
                newModel =
                    { model
                        | maybeDelete = 0
                        , lastUpdated = 0
                        , error = Nothing
                    }
            in
                ( newModel, Cmd.none )

        RequestDelete id ->
            let
                newModel =
                    { model
                        | maybeDelete = id
                        , lastUpdated = id
                        , error = Nothing
                    }
            in
                ( newModel, todoDeleteRequest id )

        DeleteSuccess id ->
            let
                newModel =
                    { model
                        | todos = List.filter (\t -> t.id /= id) model.todos
                        , maybeDelete = 0
                        , lastUpdated = 0
                        , error = Nothing
                    }
            in
                ( newModel, Cmd.none )

        EditDescription id ->
            let
                newTodo t =
                    if t.id == id then
                        { t | editingDescription = True }
                    else
                        { t | editingDescription = False }

                newModel =
                    { model
                        | todos = List.map newTodo model.todos
                        , maybeDelete = 0
                        , lastUpdated = 0
                        , error = Nothing
                    }
            in
                ( newModel, Cmd.none )

        NewDescription ( id, description ) ->
            let
                newTodo t =
                    if t.id == id then
                        { t | newDescription = description }
                    else
                        t

                newModel =
                    { model | todos = List.map newTodo model.todos }
            in
                ( newModel, Cmd.none )

        SubmitDescription ->
            let
                newModelTodos t =
                    { t | editingDescription = False }

                newModel =
                    { model | todos = List.map newModelTodos model.todos }

                newTodo =
                    case List.filter (\t -> t.editingDescription) model.todos of
                        [] ->
                            Nothing

                        t :: [] ->
                            Just { t | description = t.newDescription }

                        _ ->
                            Nothing

                cmd =
                    case newTodo of
                        Just t ->
                            todoUpdateRequest t

                        Nothing ->
                            Cmd.none
            in
                ( newModel, cmd )

        SubmitCreate ->
            let
                newTodo =
                    case List.filter (\t -> t.id == 0) model.todos of
                        [] ->
                            Nothing

                        t :: [] ->
                            Just { t | description = t.newDescription }

                        _ ->
                            Nothing

                cmd =
                    case newTodo of
                        Just t ->
                            todoCreateRequest t

                        Nothing ->
                            Cmd.none
            in
                ( model, cmd )



-- Views


view : Model -> Html Msg
view model =
    let
        error =
            case model.error of
                Just msg ->
                    p [] [ text ("Error: " ++ msg) ]

                Nothing ->
                    p [ hidden True ] [ text "No error" ]
    in
        div []
            [ error
            , viewTodos model.lastUpdated model.maybeDelete model.todos
            ]


viewTodos : Int -> Int -> Todos -> Html Msg
viewTodos lastUpdated toDelete todos =
    let
        rows =
            List.map (viewTodo lastUpdated toDelete) <| List.sortWith Todo.order todos
    in
        table
            [ class "table table-bordered table-striped" ]
            [ tbody [] rows ]


viewTodo : Int -> Int -> Todo -> Html Msg
viewTodo lastUpdated toDelete t =
    if t.id == 0 then
        let
            submit key =
                if key == enter then
                    SubmitCreate
                else
                    NoOp

            updater =
                div
                    [ class "input-group input-group-sm" ]
                    [ input
                        [ value t.newDescription
                        , type' "text"
                        , id "description_0"
                        , class "form-control"
                        , size maxDesc
                        , maxlength maxDesc
                        , placeholder i18NewTodo
                        , autofocus True
                        , onInput (\d -> NewDescription ( 0, d ))
                        , onKeyDown submit
                        ]
                        []
                    ]
        in
            tr [] [ td [ colspan 3 ] [ updater ] ]
    else
        let
            spanAtr =
                class (Todo.class t)

            rowClass =
                if lastUpdated == t.id then
                    "last-updated"
                else
                    ""

            buttons =
                controlButtons toDelete t

            priority =
                span [ spanAtr ] [ text (Todo.priority t) ]

            description =
                span [ spanAtr, onClick <| EditDescription t.id ] [ text t.description ]

            submit key =
                if key == enter then
                    SubmitDescription
                else
                    NoOp

            updater =
                div
                    [ class "input-group input-group-sm" ]
                    [ input
                        [ value t.newDescription
                        , type' "text"
                        , id <| "description_" ++ (toString t.id)
                        , class "form-control"
                        , size maxDesc
                        , maxlength maxDesc
                        , autofocus True
                        , onInput (\d -> NewDescription ( t.id, d ))
                        , onKeyDown submit
                        ]
                        []
                    ]
        in
            tr
                [ class rowClass, id ("todo_" ++ (toString t.id)) ]
                [ td []
                    [ if t.editingDescription then
                        updater
                      else
                        description
                    ]
                , td [ class "col-md-2" ] [ priority ]
                , td [ class "col-md-2 text-center" ] buttons
                ]


controlButtons : Int -> Todo -> List (Html Msg)
controlButtons toDelete t =
    let
        space =
            text nbsp

        buttons =
            if t.id == toDelete then
                [ cancelButton, (confirmButton t.id) ]
            else
                List.map (\f -> f t) [ increaseButton, decreaseButton, doneButton, deleteButton ]
    in
        List.intersperse space buttons


increaseButton : Todo -> Html Msg
increaseButton t =
    increaseDecreaseButton t True


decreaseButton : Todo -> Html Msg
decreaseButton t =
    increaseDecreaseButton t False


increaseDecreaseButton : Todo -> Bool -> Html Msg
increaseDecreaseButton t upDown =
    let
        changeable =
            Todo.changeable t upDown

        buttonColor =
            if changeable then
                "info"
            else
                "default"

        klass =
            class <| "btn btn-" ++ buttonColor ++ " btn-xs"

        newTodo =
            if changeable then
                if upDown then
                    { t | priority = t.priority - 1 }
                else
                    { t | priority = t.priority + 1 }
            else
                t

        handler =
            if changeable then
                Just <| onClick <| RequestUpdate newTodo
            else
                Nothing

        attrs =
            case handler of
                Just h ->
                    [ klass, h ]

                Nothing ->
                    [ klass ]

        arrow =
            case upDown of
                True ->
                    i18Up

                False ->
                    i18Down
    in
        span attrs [ text arrow ]


cancelButton : Html Msg
cancelButton =
    span
        [ class "btn btn-default btn-xs", onClick CancelDelete ]
        [ text i18Cancel ]


confirmButton : Int -> Html Msg
confirmButton id =
    span
        [ class "btn btn-danger btn-xs", onClick <| RequestDelete id ]
        [ text i18Confirm ]


doneButton : Todo -> Html Msg
doneButton t =
    let
        newTodo =
            { t
                | done =
                    if t.done then
                        False
                    else
                        True
            }
    in
        span
            [ class "btn btn-success btn-xs", onClick <| RequestUpdate newTodo ]
            [ text i18Done ]


deleteButton : Todo -> Html Msg
deleteButton t =
    span
        [ class "btn btn-danger btn-xs", onClick <| MaybeDelete t.id ]
        [ text i18Delete ]



-- update : Action -> Model -> Model
-- update action model =
--   case action of
--     NoOp ->
--       model
--
--     AddNewTodo result ->
--       case result of
--         Ok todo ->
--           let
--             newTodo t = if t.id == 0 then { t | newDescription = "" } else t
--             todo' = { todo | newDescription = todo.description }
--           in
--             { model
--             | todos = todo' :: (List.map newTodo model.todos)
--             , lastUpdated = todo.id
--             , error = Nothing
--             }
--
--         Err msg -> { model | error = Just (toString msg) }
--
--     EditingDescription (id, bool) ->
--       let
--         newTodo t = { t | editingDescription = if t.id == id then bool else False }
--       in
--         { model | todos = List.map newTodo model.todos }
--
--     UpdateDescription (id, description) ->
--       let
--         newTodo t = if t.id == id then { t | newDescription = description } else t
--       in
--         { model | todos = List.map newTodo model.todos }
--
--     UpdateTodo result ->
--       case result of
--         Ok todo ->
--           let
--             newTodo t =
--               if t.id == todo.id
--                 then { todo | newDescription = todo.description }
--                 else t
--           in
--             { model
--             | todos = List.map newTodo model.todos
--             , lastUpdated = todo.id
--             , maybeDelete = 0
--             , error = Nothing
--             }
--
--         Err msg -> { model | error = Just (toString msg) }
--
--     SetTodos result ->
--       case result of
--         Ok list ->
--           let
--             newTodo t =  { t | newDescription = t.description }
--             todos = List.map newTodo (exampleTodo :: list)
--           in
--             { model | todos = todos, error = Nothing }
--
--         Err msg ->
--           { model | error = Just (toString msg) }
