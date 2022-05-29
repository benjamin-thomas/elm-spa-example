module Page.Post.New exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Encode



-- VALIDATION


titleMinLength : Int
titleMinLength =
    8


bodyMinLength : Int
bodyMinLength =
    50


bodyMaxLength : Int
bodyMaxLength =
    100



-- HTTP


buildBody : Model -> Http.Body
buildBody model =
    Json.Encode.object
        [ ( "title", Json.Encode.string model.title ) ]
        |> Http.jsonBody


postData : Model -> Cmd Msg
postData model =
    Http.post
        { url = "https://jsonplaceholder.typicode.com/posts"
        , body = buildBody model
        , expect = Http.expectWhatever PostData
        }



-- MODEL


type alias Model =
    { title : String
    , body : String
    , notification : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" "" Nothing, Cmd.none )



-- UPDATE


validate : Model -> Result String Model
validate model =
    let
        title =
            String.trim model.title

        titleLenTooSmall =
            String.length title < titleMinLength

        body =
            String.trim model.body

        bodyLenTooSmall =
            String.length body < bodyMinLength

        bodyLenTooBig =
            String.length body > bodyMaxLength
    in
    if titleLenTooSmall then
        Err "Title rejected: not long enough!"

    else if bodyLenTooSmall then
        Err "Body rejected: not long enough!"

    else if bodyLenTooBig then
        Err "Body rejected: too long!"

    else
        Ok { model | notification = Nothing }


type Msg
    = ChandedTitle String
    | ChandedBody String
    | Submit
    | PostData (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChandedTitle title ->
            ( { model | title = title }, Cmd.none )

        ChandedBody body ->
            ( { model | body = body }, Cmd.none )

        Submit ->
            case validate model of
                Ok validModel ->
                    ( validModel, postData model )

                Err errMsg ->
                    ( { model | notification = Just errMsg }, Cmd.none )

        PostData result ->
            case result of
                Ok _ ->
                    ( { model
                        | notification =
                            Just "HTTP POST success!\nDo note that the resource is not really updated on the server (but the HTTP call is real)."
                        , title = ""
                        , body = ""
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | notification = Just "HTTP POST error something went wrong!" }, Cmd.none )



-- VIEW


pluralize : Int -> String -> String
pluralize n word =
    let
        words =
            String.fromInt n ++ " " ++ word
    in
    if n > 1 then
        words ++ "s"

    else
        words


minLengthOrWarn : Int -> String -> Html Msg
minLengthOrWarn min str =
    let
        remaining : Int
        remaining =
            min - String.length str
    in
    if str /= "" && String.length str < min then
        span []
            [ text <|
                "Provide "
                    ++ pluralize remaining "more character"
                    ++ ""
            ]

    else
        span [] []


warnMaxThreshold : Int -> Int -> String -> Html Msg
warnMaxThreshold fromSize maxSize str =
    let
        currLen =
            String.length str

        doWarn =
            currLen >= fromSize
    in
    if doWarn then
        let
            tooMany =
                currLen - maxSize
        in
        if tooMany > 0 then
            span [] [ text <| "Remove " ++ pluralize tooMany "character" ]

        else
            span [] [ text <| String.fromInt currLen ++ "/" ++ String.fromInt maxSize ]

    else
        span [] []


btnClasses : Model -> String
btnClasses model =
    case validate model of
        Ok _ ->
            "btn right"

        Err _ ->
            "btn right disabled"


view : Model -> Html Msg
view model =
    main_ [ class "container " ]
        [ div [ class "row" ]
            [ viewNotification model
            , Html.form [ class "col s12 m8 offset-m2" ]
                [ div [ class "input-field" ]
                    [ input
                        [ placeholder "Post Title"
                        , type_ "text"
                        , value model.title
                        , onInput ChandedTitle
                        ]
                        []
                    , minLengthOrWarn titleMinLength (String.trim model.title)
                    ]
                , div [ class "input-field" ]
                    [ textarea
                        [ placeholder "Enter post here..."
                        , onInput ChandedBody
                        , value model.body
                        ]
                        []
                    , minLengthOrWarn bodyMinLength (String.trim model.body)
                    , warnMaxThreshold bodyMinLength bodyMaxLength (String.trim model.body)
                    ]
                , div [ class "input-field" ]
                    [ button [ class (btnClasses model), type_ "button", onClick Submit ] [ text "Create (normal)" ]
                    , button [ class "btn", type_ "button", onClick Submit ] [ text "Create (alt)" ]
                    , div []
                        [ span [] [ text "Validation is done on Submit" ]
                        , span [ class "right" ] [ text "Validation is done on each view render" ]
                        ]
                    ]
                ]
            ]
        ]


viewNotification : Model -> Html Msg
viewNotification model =
    case model.notification of
        Nothing ->
            span [] []

        Just notification ->
            let
                lines : List String
                lines =
                    String.lines notification
            in
            List.map (\x -> li [] [ text x ]) lines |> ul []
