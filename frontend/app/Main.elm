module Main exposing (main)

import Auth
import Browser
import Html exposing (Html)


type alias Model =
    { auth : Auth.Model
    }


type Msg
    = AuthMsg Auth.Msg
    | NoOp


init : () -> ( Model, Cmd Msg )
init _ =
    let
        ( authModel, authCmd ) =
            Auth.init
    in
    ( { auth = authModel }
    , Cmd.batch
        [ Cmd.map AuthMsg <| authCmd
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        AuthMsg subMsg ->
            let
                ( authModel, authCmd ) =
                    Auth.update subMsg model.auth
            in
            ( { model | auth = authModel }, Cmd.map AuthMsg <| authCmd )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    Html.div []
        [ viewLoginForm model
        ]


viewLoginForm : Model -> Html Msg
viewLoginForm { auth } =
    Html.map AuthMsg <| Auth.loginForm auth
