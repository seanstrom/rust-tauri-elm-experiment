module Toda exposing (..)

import Browser exposing (Document)
import Browser.Events exposing (onAnimationFrame)
import Debug exposing (toString)
import Html exposing (button, div, text)
import Html.Events exposing (onClick)
import Task
import Time


type alias Model =
    { targetTime : Time.Posix
    , currentTime : Time.Posix
    , status : TimerStatus
    }


type Msg
    = InitTimer
    | PauseTimer
    | ResumeTimer
    | FlipTimer Time.Posix
    | FrameTime Time.Posix
    | TargetTime Time.Posix


type TimerStatus
    = Idle
    | Paused
    | Ticking
    | Flipping


oneSecond : Int
oneSecond =
    1000


oneMinute : Int
oneMinute =
    60 * oneSecond


twentyMinutes : Int
twentyMinutes =
    20 * oneMinute


getMinutes : Time.Posix -> Int
getMinutes posix =
    Time.toMinute Time.utc posix


getSeconds : Time.Posix -> Int
getSeconds posix =
    Time.toSecond Time.utc posix


init : () -> ( Model, Cmd Msg )
init () =
    ( { status = Idle
      , targetTime = Time.millisToPosix 0
      , currentTime = Time.millisToPosix 0
      }
    , Cmd.none
    )


emit : msg -> Cmd msg
emit msg =
    Task.perform (always msg) (Task.succeed ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitTimer ->
            ( { model
                | status = Ticking
                , targetTime = Time.millisToPosix twentyMinutes
              }
            , Task.perform TargetTime Time.now
            )

        ResumeTimer ->
            ( { model | status = Ticking }, Task.perform TargetTime Time.now )

        PauseTimer ->
            ( { model | status = Paused }, Cmd.none )

        FlipTimer currentPosix ->
            ( { model | status = Flipping, currentTime = currentPosix }, Cmd.none )

        TargetTime currentPosix ->
            let
                remainingTime =
                    Time.posixToMillis model.targetTime - Time.posixToMillis model.currentTime

                targetPosix =
                    Time.posixToMillis currentPosix
                        |> (+) remainingTime
                        |> Time.millisToPosix
            in
            ( { model
                | currentTime = currentPosix
                , targetTime = targetPosix
              }
            , Cmd.none
            )

        FrameTime currentPosix ->
            let
                timeDiff =
                    Time.posixToMillis currentPosix - Time.posixToMillis model.currentTime

                nextModel =
                    if timeDiff >= oneSecond then
                        { model | currentTime = currentPosix, status = Ticking }

                    else
                        model
            in
            ( nextModel, Cmd.none )


formatNumber : Int -> String
formatNumber number =
    if number < 10 then
        toString 0 ++ toString number

    else
        toString number


formatTimer : Model -> String
formatTimer model =
    let
        timeDiff =
            Time.posixToMillis model.targetTime - Time.posixToMillis model.currentTime

        timePosix =
            Time.millisToPosix timeDiff

        minutes =
            getMinutes timePosix

        seconds =
            getSeconds timePosix
    in
    (minutes |> formatNumber) ++ ":" ++ (seconds |> formatNumber)


view : Model -> Document Msg
view model =
    let
        event =
            if model.status == Idle then
                InitTimer

            else
                ResumeTimer
    in
    { title = "Totodoro"
    , body =
        [ div []
            [ model |> formatTimer |> text
            , button [ onClick event ] [ text "Start" ]
            , button [ onClick PauseTimer ] [ text "Stop" ]
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.status of
        Idle ->
            Sub.none

        Paused ->
            Sub.none

        Flipping ->
            onAnimationFrame FrameTime

        Ticking ->
            Time.every 980 FlipTimer
