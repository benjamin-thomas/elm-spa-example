module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Post.List
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
    | ListPosts Page.Post.List.Model
    | NotFound


type alias Model =
    { key : Nav.Key, page : Page }


changePage : Maybe Route -> Model -> ( Model, Cmd Msg )
changePage maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | page = NotFound }, Cmd.none )

        Just Route.Home ->
            ( { model | page = Home }, Cmd.none )

        Just Route.ListPosts ->
            let
                ( subModel, subCmdMsg ) =
                    Page.Post.List.init
            in
            ( { model | page = ListPosts subModel }, Cmd.map ListPostsMsg subCmdMsg )

        Just (Route.ShowPost id) ->
            Debug.todo "branch 'Just (ShowPost _)' not implemented"


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    let
        initModel =
            { page = NotFound
            , key = navKey
            }
    in
    changePage (Route.fromUrl url) initModel



-- UPDATE


type Msg
    = UrlChanged Url
    | LinkClicked Browser.UrlRequest
    | ListPostsMsg Page.Post.List.Msg


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

        ( ListPostsMsg subMsg, ListPosts subModel ) ->
            let
                ( newModel, newCmdMsg ) =
                    Page.Post.List.update subMsg subModel
            in
            ( { model | page = ListPosts newModel }, Cmd.map ListPostsMsg newCmdMsg )

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
        nav : Html msg
        nav =
            div []
                [ ul []
                    [ li [] [ a [ href <| Route.path Route.Home ] [ text "Home" ] ]
                    , li [] [ a [ href <| Route.path Route.ListPosts ] [ text "Posts" ] ]
                    ]
                ]
    in
    case model.page of
        Home ->
            { title = "Home"
            , body = [ nav, p [] [ text "Your are at home!" ] ]
            }

        ListPosts listPostModel ->
            { title = "Lits posts"
            , body =
                [ nav
                , Page.Post.List.view listPostModel |> Html.map ListPostsMsg
                ]
            }

        NotFound ->
            { title = "Oops"
            , body =
                [ p [] [ text "Sorry, I could not find this page!" ]
                , p [] [ text "Go back to ", a [ href <| Route.path Route.Home ] [ text "HOME" ] ]
                ]
            }
