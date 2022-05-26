module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Messages exposing (Msg)
import Models exposing (Model, initModel)
import Pages
import Route exposing (parseRoute, parseUrl, parseUrlRequest)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = \() url key -> ( initModel key, Cmd.none )
        , view = Pages.view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlChange = onUrlChange
        , onUrlRequest = onUrlRequest
        }


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest request =
    Messages.UpdateRoute (parseRoute <| parseUrlRequest request)


onUrlChange : Url -> Msg
onUrlChange url =
    Messages.OnUrlChange url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Messages.OnUrlChange url ->
            let
                route =
                    parseUrl url
            in
            ( { model | route = route }, Cmd.none )

        Messages.UpdateRoute url ->
            ( model, Nav.pushUrl model.key (Url.toString url) )
