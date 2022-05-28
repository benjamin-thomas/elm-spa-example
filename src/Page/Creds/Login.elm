module Page.Creds.Login exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Page.Creds.Shared exposing (authentication, emailInput, passwordInput)


view : Html msg
view =
    authentication
        [ emailInput
        , passwordInput
        , a [ class "btn right" ] [ text "Login" ]
        ]
