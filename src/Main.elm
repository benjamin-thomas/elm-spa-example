module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Creds.Login
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
    Browser.application
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
    | Login
    | SignUp
    | NewPost Page.Post.New.Model
    | ListPosts Page.Post.List.Model
    | ShowPost Page.Post.Show.Model
    | NotFound


type alias Email =
    String


type User
    = Visitor
    | User Email


type alias Model =
    { key : Nav.Key, page : Page, user : User }


changePage : Maybe Route -> Model -> ( Model, Cmd Msg )
changePage maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Route.Home ->
            ( { model | page = Home }, Cmd.none )

        Just Route.Login ->
            ( { model | page = Login }, Cmd.none )

        Just Route.SignUp ->
            ( { model | page = SignUp }, Cmd.none )

        Just Route.NewPost ->
            let
                ( subModel, subCmdMsg ) =
                    Page.Post.New.init
            in
            ( { model | page = NewPost subModel }, Cmd.map NewPostMsg subCmdMsg )

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
            , user = Visitor
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

        ( LoginMsg _, _ ) ->
            ( { model | page = Home }, Cmd.none )

        ( NewPostMsg subMsg, NewPost subModel ) ->
            let
                ( newModel, newCmdMsg ) =
                    Page.Post.New.update subMsg subModel
            in
            ( { model | page = NewPost newModel }, Cmd.map NewPostMsg newCmdMsg )

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

        ( _, _ ) ->
            ( { model | page = NotFound }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        navBar : Html msg
        navBar =
            header []
                [ nav []
                    [ div [ class "nav-wrapper container" ]
                        [ ul [ class "left" ]
                            [ li [] [ a [ class "btn", href <| Route.path Route.Home ] [ text "Home" ] ]
                            ]
                        , ul [ class "right" ]
                            [ li [] [ a [ class "btn", href <| Route.path Route.NewPost ] [ text "Create post" ] ]
                            , li [] [ a [ class "btn", href <| Route.path Route.Login ] [ text "Login" ] ]
                            , li [] [ a [ class "btn", href <| Route.path Route.SignUp ] [ text "Sign up" ] ]
                            ]
                        ]
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

        Login ->
            { title = "Login", body = [ Page.Creds.Login.view Nothing |> Html.map LoginMsg ] }

        SignUp ->
            { title = "Sign up", body = [ Page.Creds.SignUp.view ] }

        NewPost subModel ->
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
