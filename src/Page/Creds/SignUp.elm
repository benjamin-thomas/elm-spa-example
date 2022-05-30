module Page.Creds.SignUp exposing (view)

import Html exposing (Html, a, text)
import Html.Attributes exposing (class)
import Page.Creds.Shared exposing (authentication, emailInput, passwordAgain, passwordInput)


type Msg
    = NoOp


view : Html msg
view =
    authentication
        [ emailInput Nothing
        , passwordInput
        , passwordAgain
        , a [ class "btn right" ] [ text "Sign Up" ]
        ]
