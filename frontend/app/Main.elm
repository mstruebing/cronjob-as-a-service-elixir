module Main exposing (main)

import Auth
import Browser
import Html exposing (Html)
import Jobs


type alias Model =
    { auth : Auth.Model
    , jobs : Jobs.Model
    }


type Msg
    = AuthMsg Auth.Msg
    | JobsMsg Jobs.Msg
    | NoOp


init : () -> ( Model, Cmd Msg )
init _ =
    let
        ( authModel, authCmd ) =
            Auth.init

        ( jobsModel, jobsCmd ) =
            Jobs.init
    in
    ( { auth = authModel, jobs = jobsModel }
    , Cmd.batch
        [ Cmd.map AuthMsg <| authCmd
        , Cmd.map JobsMsg <| jobsCmd
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

                jobsCmd =
                    case subMsg of
                        Auth.LoggedIn (Ok (Just token)) ->
                            Jobs.fetchJobs authModel.token

                        _ ->
                            Cmd.none
            in
            ( { model | auth = authModel }
            , Cmd.batch
                [ Cmd.map AuthMsg <| authCmd
                , Cmd.map JobsMsg <| jobsCmd
                ]
            )

        JobsMsg subMsg ->
            let
                ( jobsModel, jobsCmd ) =
                    Jobs.update subMsg model.jobs
            in
            ( { model | jobs = jobsModel }
            , Cmd.batch
                [ Cmd.map
                    JobsMsg
                  <|
                    jobsCmd
                ]
            )


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
        [ authView model
        , jobsView model.auth.token model
        ]


authView : Model -> Html Msg
authView { auth } =
    Html.map AuthMsg <| Auth.view auth


jobsView : String -> Model -> Html Msg
jobsView token { jobs } =
    Html.map JobsMsg <| Jobs.view token jobs
