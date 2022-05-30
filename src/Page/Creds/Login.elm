module Page.Creds.Login exposing (Model, Msg, User, asGuest, getEmail, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Page.Creds.Shared exposing (authentication, passwordInput)


getEmail : User -> Maybe String
getEmail user =
    case user of
        Guest ->
            Nothing

        User (Email email) ->
            Just email



-- MODEL


type Email
    = Email String


type User
    = Guest
    | User Email


type alias Model =
    User


asGuest : User
asGuest =
    Guest


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
            Maybe.withDefault "hello" maybeEmail
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
        , input [ class "btn right", type_ "button", value "Login", onClick Authenticate ] []
        ]
