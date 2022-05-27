module Posts.List exposing (Model, Msg(..), init, path, update, view)

import Html exposing (Html, a, div, main_, p, text)
import Html.Attributes exposing (class, href)
import Http
import Json.Decode exposing (Decoder, field, int, list, map2, string)



-- ROUTING


path : Maybe Int -> String
path mid =
    let
        basePath =
            "/posts"
    in
    case mid of
        Just id ->
            basePath ++ "/" ++ String.fromInt id

        Nothing ->
            basePath



-- MODEL


type alias PostRecap =
    { id : Int
    , title : String
    }


type Model
    = Loading
    | Failure
    | Success (List PostRecap)


init : ( Model, Cmd Msg )
init =
    ( Loading, fetchData )



-- UPDATE


type Msg
    = GotData (Result Http.Error (List PostRecap))


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


postCard : PostRecap -> Html Msg
postCard post =
    div [ class "post-card" ]
        [ a [ href <| path <| Just post.id ]
            [ text <| "ID " ++ String.fromInt post.id ++ ": " ++ post.title ]
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
        { url = "https://jsonplaceholder.typicode.com/posts?_limit=10"
        , expect = Http.expectJson GotData dataDecoder
        }


itemDecoder : Decoder PostRecap
itemDecoder =
    map2 PostRecap
        (field "id" int)
        (field "title" string)


dataDecoder : Decoder (List PostRecap)
dataDecoder =
    list itemDecoder
