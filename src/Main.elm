module Main exposing (..)

import Browser
import Browser.Hash
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Page.Creds.Login
import Page.Creds.Shared exposing (User(..))
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
    | LoginPage Page.Creds.Login.Model
    | SignUpPage Page.Creds.SignUp.Model
    | NewPostPage Page.Post.New.Model
    | ListPostsPage Page.Post.List.Model
    | ShowPostPage Page.Post.Show.Model
    | NotFoundPage


type alias Model =
    { key : Nav.Key, page : Page, user : Page.Creds.Shared.User }


changePage : Maybe Route -> Model -> ( Model, Cmd Msg )
changePage maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFoundPage }, Cmd.none )

        Just Route.Home ->
            ( { model | page = Home }, Cmd.none )

        Just Route.Login ->
            let
                ( subModel, subCmdMsg ) =
                    Page.Creds.Login.init model.key
            in
            ( { model | page = LoginPage subModel }, Cmd.map LoginMsg subCmdMsg )

        Just Route.SignUp ->
            let
                ( subModel, subCmdMsg ) =
                    Page.Creds.SignUp.init model.key
            in
            ( { model | page = SignUpPage subModel }, Cmd.map SignUpMsg subCmdMsg )

        Just Route.NewPost ->
            let
                ( subModel, subCmdMsg ) =
                    Page.Post.New.init model.key
            in
            ( { model | page = NewPostPage subModel }, Cmd.map NewPostMsg subCmdMsg )

        Just Route.ListPosts ->
            let
                ( subModel, subCmdMsg ) =
                    Page.Post.List.init
            in
            ( { model | page = ListPostsPage subModel }, Cmd.map ListPostsMsg subCmdMsg )

        Just (Route.ShowPost id) ->
            let
                ( subModel, subCmdMsg ) =
                    Page.Post.Show.init id
            in
            ( { model | page = ShowPostPage subModel }, Cmd.map ShowPostMsg subCmdMsg )


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    let
        initModel =
            { page = NotFoundPage
            , key = navKey
            , user = Page.Creds.Shared.asGuest
            }
    in
    changePage (Route.fromUrl url) initModel



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | LoginMsg Page.Creds.Login.Msg
    | SignUpMsg Page.Creds.SignUp.Msg
    | Logout
    | NewPostMsg Page.Post.New.Msg
    | ListPostsMsg Page.Post.List.Msg
    | ShowPostMsg Page.Post.Show.Msg


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

        ( LoginMsg subMsg, LoginPage subModel ) ->
            Page.Creds.Login.update subMsg subModel
                |> updateWith LoginPage LoginMsg model

        ( SignUpMsg subMsg, SignUpPage subModel ) ->
            Page.Creds.SignUp.update subMsg subModel
                |> updateWith SignUpPage SignUpMsg model

        ( Logout, _ ) ->
            ( { model | page = Home, user = Page.Creds.Shared.asGuest }, Cmd.none )

        ( NewPostMsg subMsg, NewPostPage subModel ) ->
            Page.Post.New.update subMsg subModel
                |> updateWith NewPostPage NewPostMsg model

        ( ListPostsMsg subMsg, ListPostsPage subModel ) ->
            Page.Post.List.update subMsg subModel
                |> updateWith ListPostsPage ListPostsMsg model

        ( ShowPostMsg subMsg, ShowPostPage subModel ) ->
            Page.Post.Show.update subMsg subModel
                |> updateWith ShowPostPage ShowPostMsg model

        ( _, _ ) ->
            ( { model | page = NotFoundPage }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


navBarItems : Page.Creds.Shared.User -> List (Html Msg)
navBarItems user =
    case Page.Creds.Shared.getEmail user of
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

        LoginPage subModel ->
            { title = "Login", body = [ Page.Creds.Login.view subModel |> Html.map LoginMsg ] }

        SignUpPage subModel ->
            { title = "Sign up", body = [ Page.Creds.SignUp.view subModel |> Html.map SignUpMsg ] }

        NewPostPage subModel ->
            { title = "New post"
            , body =
                [ Page.Post.New.view subModel |> Html.map NewPostMsg
                ]
            }

        ListPostsPage listPostModel ->
            { title = "List posts"
            , body =
                [ navBar
                , Page.Post.List.view listPostModel |> Html.map ListPostsMsg
                ]
            }

        -- TODO: I should return the title from the Page.Post.Show
        ShowPostPage subModel ->
            { title = "Showing post"
            , body = [ navBar, Page.Post.Show.view subModel |> Html.map ShowPostMsg ]
            }

        NotFoundPage ->
            { title = "Oops"
            , body =
                [ p [] [ text "Sorry, I could not find this page!" ]
                , p [] [ text "Go back to ", a [ href <| Route.path Route.Home ] [ text "HOME" ] ]
                ]
            }



-- HELPERS
{-

      updateWith is a helper function whose purpose is to tidy the boilerplate in update.

      To clean things up, the next page's update function is applied directly with Main's update,
      and the result is given to updateWith

      More info here: https://discourse.elm-lang.org/t/pls-review-my-basic-spa-example/8425/9?u=benjamin-thomas


      update : Msg -> Model -> ( Model, Cmd Msg )
      update msg model =

          case ( msg, model.page ) of

          ( LoginMsg subMsg, LoginPage subModel ) ->
              let
                  ( newModel, newCmdMsg ) =
                      Page.Creds.Login.update
                          subMsg
                          subModel
              in
              ( { model | user = newModel.user, page = LoginPage newModel }, Cmd.map LoginMsg newCmdMsg )


          ( LoginMsg subMsg, LoginPage subModel ) ->
              Page.Creds.Login.update subMsg subModel
                  |> updateWith LoginPage LoginMsg model



   Another way to look at things, keeping for ref

          ( ShowPostMsg subMsg, ShowPostPage subModel ) ->
              --
              -- ORIG
              -- newPage ShowPostPage ( Page.Post.Show.update, subMsg, subModel ) ShowPostMsg
              --
              -- EXPANDED
              -- let
              --     ( newModel, newCmdMsg ) =
              --         Page.Post.Show.update subMsg subModel
              -- in
              -- updateWith ShowPostPage ShowPostMsg model ( newModel, newCmdMsg )
              --
              -- SIMPLIFIED
              -- Page.Post.Show.update subMsg subModel
                      -- |> updateWith ShowPostPage ShowPostMsg model

-}


updateWith :
    (model -> Page)
    -> (msg -> Msg)
    -> Model
    -> ( model, Cmd msg )
    -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( pageModel, pageCmd ) =
    ( { model | page = toModel pageModel }, Cmd.map toMsg pageCmd )
