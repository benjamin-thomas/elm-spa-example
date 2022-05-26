module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as D exposing (Decoder, field, map4)
import Url exposing (Url)
import Url.Parser as P exposing ((</>), Parser, oneOf, parse, top)



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias User =
    { email : String
    }


type State
    = Loading
    | Failure
    | Success (List Post)


type alias Model =
    { state : State
    , user : User
    , url : Url
    , key : Nav.Key
    }


initModel : Url -> Nav.Key -> Model
initModel url key =
    { state = Loading
    , user = { email = "dummy@example.com" }
    , url = url
    , key = key
    }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( initModel url key, fetchPosts )



-- UPDATE


type Msg
    = UrlChanged Url
    | LinkClicked Browser.UrlRequest
    | GotPosts (Result Http.Error (List Post))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            ( { model | url = url }, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        GotPosts result ->
            case result of
                Ok posts ->
                    ( { model | state = Success posts }, Cmd.none )

                Err _ ->
                    ( { model | state = Failure }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        body =
            case parseUrl model.url of
                Home ->
                    case model.state of
                        Success posts ->
                            viewHome posts

                        Loading ->
                            p [] [ text "Loading..." ]

                        Failure ->
                            p [] [ text "Error loading posts!" ]

                ReadPost id ->
                    readPost id model

                CreatePost ->
                    createPost model

                Login ->
                    login model

                SignUp ->
                    signUp model

                NotFound ->
                    error "Oops, not found!"
    in
    { title = "Blog", body = [ body ] }



-- VIEW HOME


viewHomeBody : List Post -> Html Msg
viewHomeBody posts =
    main_ [ class "container" ]
        [ List.map postCard posts
            |> div [ class "row" ]
        ]


postCard : Post -> Html Msg
postCard post =
    div [ class "col s12 m6 l4" ]
        [ div [ class "card small hoverable grey lighten-4" ]
            [ a [ class "card-content", href <| path (ReadPost post.id) ]
                [ span [ class "card-title medium" ]
                    [ text <| "ID " ++ String.fromInt post.id ++ ": " ++ post.title ]
                , p [] [ text post.body ]
                ]
            ]
        ]


viewHome : List Post -> Html Msg
viewHome posts =
    layout authHeader <| viewHomeBody posts



-- VIEW SHOW POST


readPostBody : Post -> Html msg
readPostBody post =
    main_ [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col l6 offset-l3" ]
                [ h1 [] [ text <| "ID " ++ String.fromInt post.id ++ ": " ++ post.title ]
                , List.repeat 10 post.body |> List.map (\par -> p [] [ text par ]) |> div []
                ]
            ]
        ]


readPost : Int -> Model -> Html msg
readPost id model =
    case model.state of
        Success posts ->
            case List.head <| List.filter (\post -> post.id == id) posts of
                Just post ->
                    layout authHeader <| readPostBody post

                Nothing ->
                    error "404 not found"

        Loading ->
            p [] [ text "Loading..." ]

        Failure ->
            p [] [ text "Error loading posts!" ]



-- VIEW CREATE POST


userHeader : User -> Html msg
userHeader user =
    header []
        [ nav []
            [ div [ class "nav-wrapper container" ]
                [ a [ class "btn", href (path CreatePost) ] [ text "New Post" ]
                , ul [ class "right" ]
                    [ li [] [ text user.email ]
                    , li [] [ a [ class "btn" ] [ text "Logout" ] ]
                    ]
                ]
            ]
        ]


createPostBody : Html msg
createPostBody =
    main_ [ class "container " ]
        [ div [ class "row" ]
            [ Html.form [ class "col s12 m8 offset-m2" ]
                [ div [ class "input-field" ] [ input [ placeholder "Post Title", type_ "text" ] [] ]
                , div [ class "input-field" ] [ textarea [ placeholder "Enter post here..." ] [] ]
                , a [ class "btn right" ] [ text "Create" ]
                ]
            ]
        ]


createPost : Model -> Html msg
createPost model =
    layout (userHeader model.user) createPostBody



-- VIEW LOGIN/SIGNUP


authentication : List (Html msg) -> Html msg
authentication body =
    main_ [ class "container " ]
        [ div [ class "full-height row valign-wrapper" ]
            [ Html.form [ class "col s12 m4 offset-m4" ]
                body
            ]
        ]


emailInput : Html msg
emailInput =
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "email" ]
        , input [ placeholder "Email", type_ "text" ] []
        ]


passwordInput : Html msg
passwordInput =
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "lock" ]
        , input [ placeholder "Password", type_ "password" ] []
        ]


passwordAgain : Html msg
passwordAgain =
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "lock" ]
        , input [ placeholder "Password Again", type_ "password" ] []
        ]



-- VIEW LOGIN


login : Model -> Html msg
login _ =
    authentication
        [ emailInput
        , passwordInput
        , a [ class "btn right" ] [ text "Login" ]
        ]



-- VIEW SIGNUP


signUp : Model -> Html msg
signUp _ =
    authentication
        [ emailInput
        , passwordInput
        , passwordAgain
        , a [ class "btn right" ] [ text "Sign Up" ]
        ]



-- SHARED MODEL


type alias Post =
    { id : Int
    , userId : Int
    , title : String
    , body : String
    }



-- SHARED VIEW


layout : Html msg -> Html msg -> Html msg
layout header body =
    div []
        [ header, body ]


authHeader : Html msg
authHeader =
    header []
        [ nav []
            [ div [ class "nav-wrapper container" ]
                [ ul [ class "right" ]
                    [ li [] [ a [ class "btn", href (path Login) ] [ text "Login" ] ]
                    , li [] [ a [ class "btn", href (path SignUp) ] [ text "Sign Up" ] ]
                    ]
                ]
            ]
        ]


error : String -> Html msg
error msg =
    main_ [ class "container" ] [ text msg ]



-- ROUTING


type Route
    = Home
    | ReadPost Int
    | CreatePost
    | Login
    | SignUp
    | NotFound


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ P.map Home top
        , P.map Home (P.s "posts")
        , P.map ReadPost (P.s "posts" </> P.int)
        , P.map CreatePost (P.s "post")
        , P.map Login (P.s "login")
        , P.map SignUp (P.s "signup")
        ]


parseUrl : Url -> Route
parseUrl url =
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

        ReadPost id ->
            "/posts/" ++ String.fromInt id

        CreatePost ->
            "/post"

        Login ->
            "/login"

        SignUp ->
            "/signup"

        NotFound ->
            "/"



-- HTTP


fetchPosts : Cmd Msg
fetchPosts =
    Http.get
        { url = "https://jsonplaceholder.typicode.com/posts?_limit=10"
        , expect = Http.expectJson GotPosts postsDecoder
        }


postDecoder : Decoder Post
postDecoder =
    map4 Post
        (field "id" D.int)
        (field "userId" D.int)
        (field "title" D.string)
        (field "body" D.string)


postsDecoder : Decoder (List Post)
postsDecoder =
    D.list postDecoder
