module Page.Creds.Shared exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, style, type_, value)
import Html.Events exposing (onInput)
import Route


type alias Email =
    String


type User
    = Guest
    | User Email


type alias Model =
    User


init : ( Model, Cmd msg )
init =
    ( Guest, Cmd.none )


authentication : List (Html msg) -> Html msg
authentication body =
    main_ [ class "container " ]
        [ div [ class "full-height row valign-wrapper" ]
            [ div [ class "col s12 m4 offset-m4" ]
                [ Html.form []
                    body
                , div [ style "text-align" "right", style "margin-top" "150px" ]
                    [ text "Go back to: "
                    , a [ href <| Route.path Route.Home ] [ text "HOME" ]
                    ]
                ]
            ]
        ]


emailInput : Maybe String -> Html msg
emailInput maybeEmail =
    let
        email =
            Maybe.withDefault "hello" maybeEmail
    in
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "email" ]
        , input [ placeholder "Email", type_ "text", value email ] []
        ]


passwordInput : Html msg
passwordInput =
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "lock" ]
        , input [ placeholder "Password is not required for this simple example", type_ "password" ] []
        ]


passwordAgain : Html msg
passwordAgain =
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "lock" ]
        , input [ placeholder "Password Again", type_ "password" ] []
        ]
