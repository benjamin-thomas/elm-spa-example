module Page.Creds.Shared exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, style, type_)
import Route


authentication : List (Html msg) -> Html msg
authentication body =
    main_ [ class "container " ]
        [ div [ class "full-height row valign-wrapper" ]
            [ div [ class "col s12 m4 offset-m4" ]
                [ Html.form []
                    body
                , div [ style "text-align" "right", style "margin-top" "150px" ] [ text "Go back to: ", a [ href <| Route.path Route.Home ] [ text "HOME" ] ]
                ]
            ]
        ]


emailInput : Html msg
emailInput =
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "email" ]
        , input [ placeholder "Email", type_ "text" ] []
        ]


passwordInput : Html msg
passwordInput =
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "lock" ]
        , input [ placeholder "Password", type_ "password" ] []
        ]


passwordAgain : Html msg
passwordAgain =
    div [ class "input-field" ]
        [ i [ class "material-icons prefix" ] [ text "lock" ]
        , input [ placeholder "Password Again", type_ "password" ] []
        ]
