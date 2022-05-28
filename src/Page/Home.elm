module Page.Home exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Route


view : Html msg
view =
    main_ [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col s12 m6 l4" ]
                [ h1 [] [ text "Welcome!" ]
                , p [] [ text "This is the home page." ]
                , p [] [ text "To read posts, ", a [ href <| Route.path Route.ListPosts ] [ text "go here" ] ]
                ]
            ]
        ]
