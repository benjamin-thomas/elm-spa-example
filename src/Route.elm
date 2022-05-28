module Route exposing (Route(..), fromUrl, path)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, top)



-- ROUTING


type Route
    = Home
    | ListPosts
    | ShowPost Int


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Home top
        , map ShowPost (s "posts" </> int)
        , map ListPosts (s "posts")
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    parse matchRoute url


path : Route -> String
path route =
    case route of
        Home ->
            "/"

        ListPosts ->
            "/posts"

        ShowPost int ->
            "/posts/" ++ String.fromInt int
