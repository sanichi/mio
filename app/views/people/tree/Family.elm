module Family where

import Array exposing (Array)

type alias Person =
  { id : Int
  , name : String
  , years : String
  , pictures : Array String
  }

default_picture_path : String
default_picture_path =
  "/images/blank_woman.png"

nobody : Person
nobody =
  { id = 0
  , name = "Initialising..."
  , years = ""
  , pictures = Array.fromList [ default_picture_path ]
  }

picturePath : Int -> Person -> String
picturePath picture person =
  let
    total = Array.length person.pictures
    index = if total < 1 then 0 else picture % total
  in
    Array.get index person.pictures |> Maybe.withDefault default_picture_path

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
