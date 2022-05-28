module Page.Post.List exposing (Model(..), Msg(..), init, update, view)

import Html exposing (Html, a, div, main_, p, span, text)
import Html.Attributes exposing (class, href)
import Http
import Json.Decode exposing (Decoder, list)
import Page.Post.Shared exposing (Post, postDecoder)
import Route



-- MODEL


type Model
    = Loading
    | Failure
    | Success (List Post)


init : ( Model, Cmd Msg )
init =
    ( Loading, fetchData )



-- UPDATE


type Msg
    = GotData (Result Http.Error (List Post))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        GotData result ->
            case result of
                Ok data ->
                    ( Success data, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- VIEW


postCard : Post -> Html Msg
postCard post =
    div [ class "col s12 m6 l4" ]
        [ div [ class "card small hoverable grey lighten-4" ]
            [ a [ class "card-content", href <| Route.path <| Route.ShowPost post.id ]
                [ span [ class "card-title medium" ]
                    [ text <| "ID " ++ String.fromInt post.id ++ ": " ++ post.title ]
                , p [] [ text post.body ]
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

            Success posts ->
                List.map postCard posts |> div [ class "row" ]
        ]



-- HTTP


fetchData : Cmd Msg
fetchData =
    Http.get
        { url = "https://jsonplaceholder.typicode.com/posts?_limit=9"
        , expect = Http.expectJson GotData (list postDecoder)
        }
