module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import ListPosts
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


type alias Model =
    { key : Nav.Key
    , route : Route
    }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( Model key (Route.fromUrl url), Cmd.none )



-- UPDATE


type Msg
    = UrlChanged Url
    | LinkClicked Browser.UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            ( { model | route = Route.fromUrl url }, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        showLinks : Html msg
        showLinks =
            div []
                [ ul []
                    [ li [] [ a [ href "/" ] [ text "Home" ] ]
                    , li [] [ a [ href "/posts" ] [ text "Posts" ] ]
                    ]
                ]

        pageBody =
            case model.route of
                Route.Home ->
                    p [] [ text "extra home" ]

                Route.ListPosts ->
                    p [] [ text "extra list posts" ]

                _ ->
                    p [] [ text "extra other" ]
    in
    { title = "Blog", body = [ showLinks, pageBody ] }
