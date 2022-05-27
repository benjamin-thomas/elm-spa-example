module Route exposing (..)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, top)



-- ROUTING


type Route
    = Home
    | ListPosts
    | NotFound


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Home top
        , map ListPosts (s "posts")
        ]


fromUrl : Url -> Route
fromUrl url =
    case parse matchRoute url of
        Just route ->
            route

        Nothing ->
            NotFound


path : Route -> String
path route =
    case route of
        Home ->
            "/"

        ListPosts ->
            "/posts"

        NotFound ->
            "/"
