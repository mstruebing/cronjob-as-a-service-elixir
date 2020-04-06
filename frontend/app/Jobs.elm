module Jobs exposing (..)

import Api.Mutation as Mutation
import Api.Object
import Api.Object.Job
import Api.Query as Query
import Api.Scalar
import Api.ScalarCodecs
import Graphql.Http exposing (mutationRequest, queryRequest, send, withHeader)
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html)
import Html.Attributes exposing (class, placeholder, title, value)
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
    | ChangePreset String


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

        ChangePreset schedule ->
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
            [ viewNewJob newJob token
            , viewJobsTable jobs token
            ]


viewNewJob : NewJob -> String -> Html Msg
viewNewJob { schedule, url } token =
    Html.form [ class "newJob", onSubmit <| CreateJob token ]
        [ Html.p [] [ Html.text "Create new job" ]
        , Html.select [ onInput ChangePreset ]
            [ Html.option [ value "" ] [ Html.text "Select a preset" ]
            , Html.option [ value "* * * * *" ] [ Html.text "every minute" ]
            , Html.option [ value "*/10 * * * *" ] [ Html.text "every 10 minutes" ]
            , Html.option [ value "0 * * * *" ] [ Html.text "every hour" ]
            ]
        , Html.input [ placeholder "schedule", onInput UpdateNewJobSchedule, value schedule ] []
        , Html.input [ placeholder "url", onInput UpdateNewJobUrl, value url ] []
        , Html.button [] [ Html.text "create job" ]
        ]


viewJobsTable : List Job -> String -> Html Msg
viewJobsTable jobs token =
    viewJobTableHead
        :: List.map (\job -> viewJobElement job token) jobs
        |> Html.table [ class "jobList" ]


viewJobTableHead : Html Msg
viewJobTableHead =
    Html.tr []
        [ Html.th [] [ Html.text "url" ]
        , Html.th [] [ Html.text "schedule" ]
        , Html.th [] [ Html.text "last run" ]
        , Html.th [] [ Html.text "next run" ]
        , Html.th [] [ Html.text "delete" ]
        ]


viewJobElement : Job -> String -> Html Msg
viewJobElement job token =
    Html.tr []
        [ Html.td [ class "jobUrl", title job.url ] [ Html.text job.url ]
        , Html.td [] [ Html.text job.schedule ]
        , Html.td [] [ Html.text <| extractDateTime job.last_run ]
        , Html.td [] [ Html.text <| extractDateTime job.next_run ]
        , Html.td [] [ Html.button [ onClick <| DeleteJob token job.id ] [ Html.text "X" ] ]
        ]


extractDateTime : Api.Scalar.DateTime -> String
extractDateTime (Api.Scalar.DateTime s) =
    s
