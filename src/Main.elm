module Main exposing (..)

import Browser
import Models exposing (Model, initModel)
import Pages


main : Program () Model msg
main =
    Browser.element
        { init = \() -> ( initModel, Cmd.none )
        , view = Pages.landing
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
