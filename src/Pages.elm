module Pages exposing (..)

import Components exposing (authHeader, error, landingBody, layout, readPostBody)
import Html exposing (Html)
import Models exposing (Model)


landing : Model -> Html msg
landing model =
    layout authHeader <| landingBody model.posts


readPost : String -> Model -> Html msg
readPost id model =
    case List.head <| List.filter (\post -> post.id == id) model.posts of
        Just post ->
            layout authHeader <| readPostBody post

        Nothing ->
            error "404 not found"
