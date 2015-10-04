module Family where

import Array exposing (Array)

type alias Person =
  { id : Int
  , name : String
  }

nobody : Person
nobody =
  { id = 0
  , name = "Initialising..."
  }

type alias People =
  Array Person

type alias Family =
  { partner : Maybe Person
  , children : People
  }

type alias Families =
  Array Family

type alias Focus =
  { person : Person
  , father : Maybe Person
  , mother : Maybe Person
  , families : Families
  }

blur : Focus
blur =
  { person = nobody
  , father = Nothing
  , mother = Nothing
  , families = Array.empty
  }
