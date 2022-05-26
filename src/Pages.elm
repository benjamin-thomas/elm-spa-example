module Pages exposing (..)

import Components exposing (authHeader, landingBody, layout)
import Html exposing (Html)
import Models exposing (Model)


landing : Model -> Html msg
landing model =
    layout authHeader <| landingBody model.posts
