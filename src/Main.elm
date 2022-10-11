module Main exposing (main)

import Browser
import Toda exposing (Model, Msg, init, update, view, subscriptions)

main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
