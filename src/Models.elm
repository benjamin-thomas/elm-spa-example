module Models exposing (..)

import Lorem


type alias Post =
    { id : String
    , title : String
    , body : String
    }


type alias Model =
    { posts : List Post
    }


initPost : String -> Post
initPost id =
    { id = id
    , title = Lorem.sentence 4
    , body = Lorem.paragraphs 2 |> String.concat
    }


initModel : { posts : List Post }
initModel =
    { posts =
        List.range 1 10
            |> List.map String.fromInt
            |> List.map initPost
    }
