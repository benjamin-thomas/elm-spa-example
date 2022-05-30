module Main exposing (..)

import Browser
import Browser.Hash
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Page.Creds.Login exposing (User(..))
import Page.Creds.SignUp
import Page.Home
import Page.Post.List
import Page.Post.New
import Page.Post.Show
import Route exposing (Route)
import Url exposing (Url)



-- MAIN


main : Program () Model Msg
main =
    Browser.Hash.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type Page
    = Home
    | Login Page.Creds.Login.Model
    | SignUp
    | NewPostPage Page.Post.New.Model
    | ListPosts Page.Post.List.Model
    | ShowPost Page.Post.Show.Model
    | NotFound


type alias Model =
    { key : Nav.Key, page : Page, user : Page.Creds.Login.User }


changePage : Maybe Route -> Model -> ( Model, Cmd Msg )
changePage maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Route.Home ->
            ( { model | page = Home }, Cmd.none )

        Just Route.Login ->
            let
                ( subModel, subCmdMsg ) =
                    Page.Creds.Login.init
            in
            ( { model | page = Login subModel }, Cmd.map LoginMsg subCmdMsg )

        Just Route.SignUp ->
            ( { model | page = SignUp }, Cmd.none )

        Just Route.NewPost ->
            let
                ( subModel, subCmdMsg ) =
                    Page.Post.New.init
            in
            ( { model | page = NewPostPage subModel }, Cmd.map NewPostMsg subCmdMsg )

        Just Route.ListPosts ->
            let
                ( subModel, subCmdMsg ) =
                    Page.Post.List.init
            in
            ( { model | page = ListPosts subModel }, Cmd.map ListPostsMsg subCmdMsg )

        Just (Route.ShowPost id) ->
            let
                ( subModel, subCmdMsg ) =
                    Page.Post.Show.init id
            in
            ( { model | page = ShowPost subModel }, Cmd.map ShowPostMsg subCmdMsg )


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    let
        initModel =
            { page = NotFound
            , key = navKey
            , user = Page.Creds.Login.asGuest
            }
    in
    changePage (Route.fromUrl url) initModel



-- UPDATE


type Msg
    = UrlChanged Url
    | LinkClicked Browser.UrlRequest
    | NewPostMsg Page.Post.New.Msg
    | ListPostsMsg Page.Post.List.Msg
    | ShowPostMsg Page.Post.Show.Msg
    | LoginMsg Page.Creds.Login.Msg
    | SimulateLogin
    | Logout


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            changePage (Route.fromUrl url) model

        ( NewPostMsg subMsg, NewPostPage subModel ) ->
            let
                ( newModel, newCmdMsg ) =
                    Page.Post.New.update subMsg subModel
            in
            ( { model | page = NewPostPage newModel }, Cmd.map NewPostMsg newCmdMsg )

        ( ListPostsMsg subMsg, ListPosts subModel ) ->
            let
                ( newModel, newCmdMsg ) =
                    Page.Post.List.update subMsg subModel
            in
            ( { model | page = ListPosts newModel }, Cmd.map ListPostsMsg newCmdMsg )

        ( ShowPostMsg subMsg, ShowPost subModel ) ->
            let
                ( newModel, newCmdMsg ) =
                    Page.Post.Show.update subMsg subModel
            in
            ( { model | page = ShowPost newModel }, Cmd.map ShowPostMsg newCmdMsg )

        ( LoginMsg subMsg, Login subModel ) ->
            let
                ( newModel, newCmdMsg ) =
                    Page.Creds.Login.update subMsg subModel
            in
            ( { model | user = newModel, page = Home }, Cmd.map LoginMsg newCmdMsg )

        ( Logout, _ ) ->
            ( { model | page = Home, user = Page.Creds.Login.asGuest }, Cmd.none )

        ( _, _ ) ->
            ( { model | page = NotFound }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


navBarItems : Page.Creds.Login.User -> List (Html Msg)
navBarItems user =
    case Page.Creds.Login.getEmail user of
        Nothing ->
            [ ul [ class "right" ]
                [ li [] [ a [ class "btn", href <| Route.path Route.Login ] [ text "Login" ] ]
                , li [] [ a [ class "btn", href <| Route.path Route.SignUp ] [ text "Sign up" ] ]
                ]
            ]

        Just email ->
            [ ul []
                [ li [] [ a [ class "btn", href <| Route.path Route.NewPost ] [ text "New post" ] ]
                , li [] [ text email ]
                ]
            , ul [ class "right" ]
                [ li [] [ button [ class "btn", onClick Logout ] [ text "Logout" ] ]
                ]
            ]


view : Model -> Browser.Document Msg
view model =
    let
        navBar : Html Msg
        navBar =
            header []
                [ nav []
                    [ div [ class "nav-wrapper container" ] (navBarItems model.user)
                    ]
                ]
    in
    case model.page of
        Home ->
            { title = "Home"
            , body =
                [ navBar
                , Page.Home.view
                ]
            }

        Login subModel ->
            { title = "Login", body = [ Page.Creds.Login.view subModel |> Html.map LoginMsg ] }

        SignUp ->
            { title = "Sign up", body = [ Page.Creds.SignUp.view ] }

        NewPostPage subModel ->
            { title = "New post"
            , body =
                [ Page.Post.New.view subModel |> Html.map NewPostMsg
                ]
            }

        ListPosts listPostModel ->
            { title = "List posts"
            , body =
                [ navBar
                , Page.Post.List.view listPostModel |> Html.map ListPostsMsg
                ]
            }

        -- TODO: I should return the title from the Page.Post.Show
        ShowPost subModel ->
            { title = "Showing post"
            , body = [ navBar, Page.Post.Show.view subModel |> Html.map ShowPostMsg ]
            }

        NotFound ->
            { title = "Oops"
            , body =
                [ p [] [ text "Sorry, I could not find this page!" ]
                , p [] [ text "Go back to ", a [ href <| Route.path Route.Home ] [ text "HOME" ] ]
                ]
            }
