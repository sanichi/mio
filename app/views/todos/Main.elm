
import Todo exposing (update, view)
import StartApp.Simple exposing (start)


main =
  start
    { model =
      [ { description = "Fix water pipe", priority = 0, priority_desc = "Urgent", done = True }
      , { description = "Do washing-up", priority = 2, priority_desc = "Medium", done = False }
      , { description = "Paint ceiling", priority = 2, priority_desc = "Medium", done = False }
      , { description = "Clean car", priority = 3, priority_desc = "Low", done = False }
      ]
    , update = update
    , view = view
    }
