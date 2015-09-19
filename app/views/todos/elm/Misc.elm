module Misc where

import Dict exposing (Dict)

highPriority : Int
highPriority = 0

lowPriority : Int
lowPriority = 4

priorities : Dict Int String
priorities =
  Dict.fromList [ (0, "Urgent"), (1, "Important"), (2, "Medium"), (3, "Low"), (4, "Lowest") ]

delete : String
delete = "✘"

done : String
done = "✔︎"

down : String
down = "⬇︎"

up : String
up = "⬆︎"
