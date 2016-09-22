module Misc exposing (..)

import Dict exposing (Dict)


highPriority : Int
highPriority = 0


lowPriority : Int
lowPriority = 4


i18Priorities : Dict Int String
i18Priorities =
  Dict.fromList [ (0, "Urgent"), (1, "Important"), (2, "Medium"), (3, "Low"), (4, "Lowest") ]


i18Cancel : String
i18Cancel = "Cancel"


i18Confirm : String
i18Confirm = "Confirm"


i18Delete : String
i18Delete = "✘"


i18Done : String
i18Done = "✔︎"


i18Down : String
i18Down = "⬇︎"


i18NewTodo : String
i18NewTodo = "New Todo"


i18Up : String
i18Up = "⬆︎"


maxDesc : Int
maxDesc = 60


indexAndCreateUrl : String
indexAndCreateUrl =
  "/todos.json"


updateAndDeleteUrl : Int -> String
updateAndDeleteUrl id =
  "/todos/" ++ (toString id) ++ ".json"
