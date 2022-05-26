module Route exposing (..)

import Browser exposing (UrlRequest(..))
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


type Route
    = Home
    | ReadPost String
    | CreatePost
    | Login
    | SignUp
    | NotFound


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Home top
        , map Home (s "posts")
        , map ReadPost (s "posts" </> string)
        , map CreatePost (s "post")
        , map Login (s "login")
        , map SignUp (s "signup")
        ]


parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route

        Nothing ->
            NotFound


parseRoute : Route -> Url
parseRoute route =
    { protocol = Url.Http
    , host = "localhost"
    , port_ = Just 8000
    , path = path route
    , query = Nothing
    , fragment = Nothing
    }


parseUrlRequest : Browser.UrlRequest -> Route
parseUrlRequest request =
    case request of
        Internal url ->
            parseUrl url

        External _ ->
            NotFound


path : Route -> String
path route =
    case route of
        Home ->
            "/"

        ReadPost id ->
            "/posts/" ++ id

        CreatePost ->
            "/post"

        Login ->
            "/login"

        SignUp ->
            "/signup"

        NotFound ->
            "/"
