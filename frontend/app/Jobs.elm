module Jobs exposing (..)

import Api.Mutation as Mutation
import Api.Object
import Api.Object.Job
import Api.Query as Query
import Api.ScalarCodecs
import Graphql.Http exposing (mutationRequest, queryRequest, send, withHeader)
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Shared exposing (graphqlServerUrl)


type alias Model =
    { jobs : List Job
    , newJob : NewJob
    }


type alias NewJob =
    { schedule : String
    , url : String
    }


type alias Job =
    { id : Api.ScalarCodecs.Id
    , user_id : Api.ScalarCodecs.Id
    , last_run : Api.ScalarCodecs.DateTime
    , next_run : Api.ScalarCodecs.DateTime
    , schedule : String
    , url : String
    }


type Msg
    = NoOp
    | JobsFetched (Result (Graphql.Http.Error (List Job)) (List Job))
    | DeleteJob String Api.ScalarCodecs.Id
    | JobDeleted (Result (Graphql.Http.Error Job) Job)
    | CreateJob String
    | JobCreated (Result (Graphql.Http.Error Job) Job)
    | UpdateNewJobUrl String
    | UpdateNewJobSchedule String


emptyModel : Model
emptyModel =
    { jobs = [], newJob = { schedule = "", url = "" } }


init : ( Model, Cmd Msg )
init =
    ( emptyModel
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        JobsFetched (Ok jobs) ->
            ( { model | jobs = jobs }, Cmd.none )

        JobsFetched (Err _) ->
            ( model, Cmd.none )

        DeleteJob token id ->
            ( model, Cmd.batch [ deleteJob token id ] )

        JobDeleted (Ok job) ->
            ( { model | jobs = List.filter (\j -> j.id /= job.id) model.jobs }, Cmd.none )

        JobDeleted _ ->
            ( model, Cmd.none )

        CreateJob token ->
            ( model, Cmd.batch [ createJob token model.newJob ] )

        JobCreated (Ok job) ->
            ( { model | jobs = job :: model.jobs, newJob = { schedule = "", url = "" } }, Cmd.none )

        JobCreated _ ->
            ( model, Cmd.none )

        UpdateNewJobUrl url ->
            let
                oldNewJob =
                    model.newJob

                newNewJob =
                    { oldNewJob | url = url }
            in
            ( { model | newJob = newNewJob }, Cmd.none )

        UpdateNewJobSchedule schedule ->
            let
                oldNewJob =
                    model.newJob

                newNewJob =
                    { oldNewJob | schedule = schedule }
            in
            ( { model | newJob = newNewJob }, Cmd.none )


jobSelection : SelectionSet Job Api.Object.Job
jobSelection =
    SelectionSet.map6 Job
        Api.Object.Job.id
        Api.Object.Job.userId
        Api.Object.Job.lastRun
        Api.Object.Job.nextRun
        Api.Object.Job.schedule
        Api.Object.Job.url


fetchJobs : String -> Cmd Msg
fetchJobs token =
    Query.jobs jobSelection
        |> queryRequest graphqlServerUrl
        |> withHeader "authorization" ("Bearer " ++ token)
        |> send JobsFetched


deleteJob : String -> Api.ScalarCodecs.Id -> Cmd Msg
deleteJob token id =
    Mutation.deleteJob { id = id } jobSelection
        |> mutationRequest graphqlServerUrl
        |> withHeader "authorization" ("Bearer " ++ token)
        |> send JobDeleted


createJob : String -> NewJob -> Cmd Msg
createJob token { schedule, url } =
    Mutation.createJob { schedule = schedule, url = url } jobSelection
        |> mutationRequest graphqlServerUrl
        |> withHeader "authorization" ("Bearer " ++ token)
        |> send JobCreated


view : String -> Model -> Html Msg
view token { jobs, newJob } =
    if token == "" then
        Html.text ""

    else
        Html.div []
            [ newJobForm token newJob
            , Html.ul []
                (List.map
                    (\job ->
                        Html.li []
                            [ Html.text <| "schedule: " ++ job.schedule ++ " url: " ++ job.url
                            , Html.button [ onClick <| DeleteJob token job.id ] [ Html.text "X" ]
                            ]
                    )
                    jobs
                )
            ]


newJobForm : String -> NewJob -> Html Msg
newJobForm token { schedule, url } =
    Html.form [ onSubmit <| CreateJob token ]
        [ Html.input [ placeholder "schedule", onInput UpdateNewJobSchedule, value schedule ] []
        , Html.input [ placeholder "url", onInput UpdateNewJobUrl, value url ] []
        , Html.button [] [ Html.text "create job" ]
        ]
