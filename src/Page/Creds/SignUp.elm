module Page.Creds.SignUp exposing (view)

import Html exposing (Html, a, text)
import Html.Attributes exposing (class)
import Page.Creds.Shared exposing (authentication, emailInput, passwordAgain, passwordInput)


view : Html msg
view =
    authentication
        [ emailInput
        , passwordInput
        , passwordAgain
        , a [ class "btn right" ] [ text "Sign Up" ]
        ]
