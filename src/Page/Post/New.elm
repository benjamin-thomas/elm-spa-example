module Page.Post.New exposing (..)

import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Encode as Encode exposing (string)
import Process
import Route
import Task



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
    Encode.object
        [ ( "title", string model.title ) ]
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
    { key : Nav.Key
    , title : String
    , body : String
    , errors : List String
    , countDown : Maybe Int
    }


init : Nav.Key -> ( Model, Cmd Msg )
init key =
    ( { key = key
      , title = ""
      , body = ""
      , errors = []
      , countDown = Nothing
      }
    , Cmd.none
    )



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
        Ok { model | errors = [] }


type InputField
    = Title String
    | Body String


type Msg
    = ChangedForm InputField
    | Submit
    | PostData (Result Http.Error ())
    | RedirectOnCountDownZero Int


decCountDown : Int -> Cmd Msg
decCountDown n =
    Process.sleep 1000
        |> Task.perform (\_ -> RedirectOnCountDownZero (n - 1))


updateFormField formField model =
    case formField of
        Title str ->
            ( { model | title = str }, Cmd.none )

        Body str ->
            ( { model | body = str }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedForm formField ->
            updateFormField formField
                { model | errors = [] }

        Submit ->
            case validate model of
                Ok validModel ->
                    ( validModel, postData model )

                Err errMsg ->
                    ( { model | errors = [ errMsg ] }, Cmd.none )

        PostData result ->
            let
                secs =
                    5
            in
            case result of
                Ok _ ->
                    ( { model
                        | errors =
                            [ "HTTP POST success!"
                            , "Do note that the resource is not really updated on the server (but the HTTP call is real)."
                            ]
                        , title = ""
                        , body = ""
                        , countDown = Just secs
                      }
                    , decCountDown secs
                    )

                Err _ ->
                    ( { model | errors = [ "HTTP POST error something went wrong!" ] }, Cmd.none )

        RedirectOnCountDownZero remainingSecs ->
            if remainingSecs <= 0 then
                ( model, Nav.pushUrl model.key (Route.path Route.Home) )

            else
                ( { model | countDown = Just remainingSecs }, decCountDown remainingSecs )



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
            [ viewErrors model
            , div []
                [ p []
                    [ case model.countDown of
                        Nothing ->
                            text ""

                        Just n ->
                            text <| "Redirect in " ++ String.fromInt n ++ "s"
                    ]
                ]
            , Html.form [ class "col s12 m8 offset-m2" ]
                [ div [ class "input-field" ]
                    [ input
                        [ placeholder "Post Title"
                        , type_ "text"
                        , value model.title
                        , onInput (\str -> ChangedForm (Title str))
                        ]
                        []
                    , minLengthOrWarn titleMinLength (String.trim model.title)
                    ]
                , div [ class "input-field" ]
                    [ textarea
                        [ placeholder "Type lorem! to add bogus text..."
                        , onInput (\str -> ChangedForm (Body str))
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


viewErrors : Model -> Html Msg
viewErrors model =
    List.map (\x -> li [] [ text x ]) model.errors |> ul []
