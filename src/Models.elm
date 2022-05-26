module Models exposing (..)

import Lorem


type alias Post =
    { id : String
    , title : String
    , body : String
    }


type alias User =
    { email : String
    }


type alias Model =
    { posts : List Post
    , user : User
    }


initPost : String -> Post
initPost id =
    { id = id
    , title = Lorem.sentence 4
    , body = Lorem.paragraphs 2 |> String.concat
    }


initModel : Model
initModel =
    { posts =
        List.range 1 10
            |> List.map String.fromInt
            |> List.map initPost
    , user = { email = "dummy@example.com" }
    }
