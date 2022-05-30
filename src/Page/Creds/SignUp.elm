module Page.Creds.SignUp exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, a, div, i, input, text)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Page.Creds.Shared exposing (Email(..), User(..), authentication, emailInput, getEmail, passwordAgain, passwordInput)


type alias Model =
    User


init : ( Model, Cmd msg )
init =
    ( User (Email "user@example.com"), Cmd.none )



-- UPDATE


type Msg
    = ChangeEmail String
    | Authenticate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Authenticate ->
            ( model, Cmd.none )

        ChangeEmail email ->
            ( User (Email email), Cmd.none )



-- VIEW


emailInput : Maybe String -> (String -> Msg) -> Html Msg
emailInput maybeEmail evt =
    let
        email =
            Maybe.withDefault "" maybeEmail
    in
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "email" ]
        , input [ placeholder "Email", type_ "text", value email, onInput evt ] []
        ]


view : Model -> Html Msg
view model =
    authentication
        [ emailInput (getEmail model) ChangeEmail
        , passwordInput
        , passwordAgain
        , input [ class "btn right", type_ "button", value "Login", onClick Authenticate ] []
        ]
