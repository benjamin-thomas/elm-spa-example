module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Lorem
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = onUrlChange
        , onUrlRequest = onUrlRequest
        }



-- MODEL


type alias User =
    { email : String
    }


type alias Model =
    { posts : List Post
    , user : User
    , route : Route
    , key : Nav.Key
    }


fakePost : String -> Post
fakePost id =
    { id = id
    , title = Lorem.sentence 4
    , body = Lorem.paragraphs 2 |> String.concat
    }


initModel : Url -> Nav.Key -> Model
initModel url key =
    { posts =
        List.range 1 10
            |> List.map String.fromInt
            |> List.map fakePost
    , user = { email = "dummy@example.com" }
    , route = parseUrl url
    , key = key
    }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( initModel url key, Cmd.none )



-- UPDATE


type Msg
    = OnUrlChange Url
    | UpdateRoute Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnUrlChange url ->
            ( { model | route = parseUrl url }, Cmd.none )

        UpdateRoute url ->
            ( model, Nav.pushUrl model.key (Url.toString url) )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- NAVIGATION


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest request =
    UpdateRoute (parseRoute <| parseUrlRequest request)


onUrlChange : Url -> Msg
onUrlChange url =
    OnUrlChange url



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        body =
            case model.route of
                Home ->
                    viewHome model

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
    div [ class "col s12 m6 l4", onClick (UpdateRoute <| parseRoute <| ReadPost post.id) ]
        [ div [ class "card small hoverable grey lighten-4" ]
            [ div [ class "card-content" ]
                [ span [ class "card-title medium" ]
                    [ text <| "ID " ++ post.id ++ ": " ++ post.title ]
                , p [] [ text post.body ]
                ]
            ]
        ]


viewHome : Model -> Html Msg
viewHome model =
    layout authHeader <| viewHomeBody model.posts



-- VIEW SHOW POST


readPostBody : Post -> Html msg
readPostBody post =
    main_ [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col l6 offset-l3" ]
                [ h1 [] [ text <| "ID " ++ post.id ++ ": " ++ post.title ]
                , List.repeat 10 post.body |> List.map (\par -> p [] [ text par ]) |> div []
                ]
            ]
        ]


readPost : String -> Model -> Html msg
readPost id model =
    case List.head <| List.filter (\post -> post.id == id) model.posts of
        Just post ->
            layout authHeader <| readPostBody post

        Nothing ->
            error "404 not found"



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
    { id : String
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
    | ReadPost String
    | CreatePost
    | Login
    | SignUp
    | NotFound


matchRoute : Parser (Route -> a) a
matchRoute =
    let
        map =
            Url.Parser.map

        s =
            Url.Parser.s
    in
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
        Browser.Internal url ->
            parseUrl url

        Browser.External _ ->
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
