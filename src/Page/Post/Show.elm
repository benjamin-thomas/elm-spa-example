module Page.Post.Show exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import Page.Post.Shared exposing (Post, postDecoder)



-- MODEL


type Model
    = Loading
    | Failure
    | Success Post


init : Int -> ( Model, Cmd Msg )
init postID =
    ( Loading, fetchData postID )



-- UPDATE


type Msg
    = GotData (Result Http.Error Post)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        GotData result ->
            case result of
                Ok value ->
                    ( Success value, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- VIEW


viewPost : Post -> Html msg
viewPost post =
    main_ [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col l12" ]
                [ h1 [] [ text <| "ID " ++ String.fromInt post.id ++ ": " ++ post.title ]
                , List.repeat 10 post.body |> List.map (\par -> p [] [ text par ]) |> div []
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    main_ [ class "container" ]
        [ case model of
            Loading ->
                p [] [ text "Loading..." ]

            Failure ->
                p [] [ text "Failed to fetch posts!" ]

            Success post ->
                viewPost post
        ]



-- HTTP


fetchData : Int -> Cmd Msg
fetchData postID =
    Http.get
        { url = "https://jsonplaceholder.typicode.com/posts/" ++ String.fromInt postID
        , expect = Http.expectJson GotData postDecoder
        }
