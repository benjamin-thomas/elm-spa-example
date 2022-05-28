module Page.Creds.Login exposing (Msg, view)

import Html exposing (..)
import Html.Attributes exposing (class, type_, value)
import Html.Events exposing (onClick)
import Page.Creds.Shared exposing (authentication, emailInput, passwordInput)



-- MODEL


type alias Email =
    String


type alias Model =
    Maybe Email


init : ( Model, Cmd Msg )
init =
    ( Nothing, Cmd.none )



-- UPDATE


type Msg
    = Authenticate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Authenticate ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    authentication
        [ emailInput
        , passwordInput
        , input [ class "btn right", type_ "button", value "Login", onClick Authenticate ] []
        ]
