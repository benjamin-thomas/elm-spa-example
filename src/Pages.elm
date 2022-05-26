module Pages exposing (..)

import Browser exposing (Document)
import Components exposing (authHeader, createPostBody, error, landingBody, layout, readPostBody, userHeader)
import Html exposing (Html)
import Html.Attributes exposing (title)
import Messages exposing (Msg)
import Models exposing (Model)
import Route exposing (Route(..))


landing : Model -> Html Msg
landing model =
    layout authHeader <| landingBody model.posts


readPost : String -> Model -> Html msg
readPost id model =
    case List.head <| List.filter (\post -> post.id == id) model.posts of
        Just post ->
            layout authHeader <| readPostBody post

        Nothing ->
            error "404 not found"


createPost : Model -> Html msg
createPost model =
    layout (userHeader model.user) createPostBody


login : Model -> Html msg
login model =
    Components.login


signUp : Model -> Html msg
signUp model =
    Components.signUp


view : Model -> Document Msg
view model =
    let
        body =
            case model.route of
                Home ->
                    landing model

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
