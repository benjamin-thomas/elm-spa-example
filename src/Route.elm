module Route exposing (Route(..), fromUrl, path)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, top)



-- ROUTING


type Route
    = Home
    | Login
    | SignUp
    | NewPost
    | ListPosts
    | ShowPost Int


path : Route -> String
path route =
    case route of
        Home ->
            "#/"

        Login ->
            "#/login"

        SignUp ->
            "#/signup"

        NewPost ->
            "#/posts/new"

        ListPosts ->
            "#/posts"

        ShowPost int ->
            "#/posts/" ++ String.fromInt int


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Home top

        -- AUTHENTICATION
        , map Login (s "login")
        , map SignUp (s "signup")

        -- POSTS
        , map ListPosts (s "posts")
        , map ShowPost (s "posts" </> int)
        , map NewPost (s "posts" </> s "new")
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    parse matchRoute url
