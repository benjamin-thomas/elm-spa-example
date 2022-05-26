module Messages exposing (..)

import Url exposing (Url)


type Msg
    = OnUrlChange Url
    | UpdateRoute Url
