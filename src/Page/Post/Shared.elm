module Page.Post.Shared exposing (Post, postDecoder)

import Json.Decode exposing (Decoder, field, int, map3, string)


type alias Post =
    { id : Int
    , title : String
    , body : String
    }


postDecoder : Decoder Post
postDecoder =
    map3 Post
        (field "id" int)
        (field "title" string)
        (field "body" string)
