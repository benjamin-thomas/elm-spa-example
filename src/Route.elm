module Route exposing (Route(..), fromUrl, path)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, top)



-- ROUTING


type Route
    = Home
    | Login
    | SignUp
    | ListPosts
    | ShowPost Int


path : Route -> String
path route =
    case route of
        Home ->
            "/"

        Login ->
            "/login"

        SignUp ->
            "/signup"

        ListPosts ->
            "/posts"

        ShowPost int ->
            "/posts/" ++ String.fromInt int


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Home top
        , map Login (s "login")
        , map SignUp (s "signup")
        , map ListPosts (s "posts")
        , map ShowPost (s "posts" </> int)
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    parse matchRoute url
