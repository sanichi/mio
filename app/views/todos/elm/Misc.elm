module Misc where

import Dict exposing (Dict)

priorityHigh : Int
priorityHigh = 0

priorityLow : Int
priorityLow = 4

priorityString : Dict Int String
priorityString =
  Dict.fromList [ (0, "Urgent"), (1, "Important"), (2, "Medium"), (3, "Low"), (4, "Lowest") ]
