module Page.Creds.SignUp exposing (Model, init, view)

import Html exposing (Html, a, text)
import Html.Attributes exposing (class)
import Page.Creds.Shared exposing (Email(..), User(..), authentication, emailInput, passwordAgain, passwordInput)


type alias Model =
    User


init : ( Model, Cmd msg )
init =
    ( User (Email "user@example.com"), Cmd.none )


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
