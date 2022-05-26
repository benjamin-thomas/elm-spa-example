module Models exposing (..)

import Browser.Navigation as Nav
import Lorem
import Route exposing (Route)


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
    , route : Route
    , key : Nav.Key
    }


initPost : String -> Post
initPost id =
    { id = id
    , title = Lorem.sentence 4
    , body = Lorem.paragraphs 2 |> String.concat
    }


initModel : Nav.Key -> Model
initModel key =
    { posts =
        List.range 1 10
            |> List.map String.fromInt
            |> List.map initPost
    , user = { email = "dummy@example.com" }
    , route = Route.Home
    , key = key
    }
