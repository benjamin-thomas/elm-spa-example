module Components exposing (..)

import Debug exposing (toString)
import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (Post)


layout : Html msg -> Html msg -> Html msg
layout header main =
    div []
        [ header, main ]


authHeader : Html msg
authHeader =
    header []
        [ nav []
            [ div [ class "nav-wrapper container" ]
                [ ul [ class "right" ]
                    [ li [] [ a [ class "btn" ] [ text "Login" ] ]
                    , li [] [ a [ class "btn" ] [ text "Sign Up" ] ]
                    ]
                ]
            ]
        ]


landingBody : List Post -> Html msg
landingBody posts =
    main_ [ class "container" ]
        [ List.map postCard posts
            |> div [ class "row" ]
        ]


postCard : Post -> Html msg
postCard post =
    div [ class "col s12 m6 l4" ]
        [ div [ class "card small hoverable grey lighten-4" ]
            [ div [ class "card-content" ]
                [ span [ class "card-title medium" ]
                    [ text <| "ID " ++ post.id ++ ": " ++ post.title ]
                , p [] [ text post.body ]
                ]
            ]
        ]


readPostBody : Post -> Html msg
readPostBody post =
    main_ [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col l6 offset-l3" ]
                [ h1 [] [ text <| "ID " ++ post.id ++ ": " ++ post.title ]
                , List.repeat 10 post.body |> List.map (\par -> p [] [ text par ]) |> div []
                ]
            ]
        ]


error : a -> Html msg
error a =
    main_ [ class "container" ] [ text <| toString a ]
