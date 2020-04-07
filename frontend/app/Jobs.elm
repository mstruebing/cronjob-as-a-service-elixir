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
import Html.Attributes exposing (class, disabled, href, placeholder, target, title, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Shared exposing (graphqlServerUrl)


type alias Model =
    { jobs : List Job
    , newJob : NewJob
    , newJobError : String
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
    { jobs = []
    , newJob = { schedule = "", url = "" }
    , newJobError = ""
    }


type alias Preset =
    { cronExpression : String, text : String }


presets : List Preset
presets =
    [ { cronExpression = "", text = "select a preset" }
    , { cronExpression = "* * * * *", text = "every minute" }
    , { cronExpression = "*/10 * * * *", text = "every 10 minutes" }
    , { cronExpression = "0 * * * *", text = "every hour" }
    , { cronExpression = "12 * * * *", text = "every 12 hours" }
    , { cronExpression = "0 0 * * *", text = "every day" }
    , { cronExpression = "0 0 * * 1-5", text = "every monday til friday" }
    , { cronExpression = "0 0 * * 0", text = "every week" }
    , { cronExpression = "0 0 1 1 *", text = "every year" }
    ]


viewPresets : List (Html Msg)
viewPresets =
    List.map
        (\preset -> Html.option [ value preset.cronExpression ] [ Html.text preset.text ])
        presets


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
view token model =
    if token == "" then
        Html.text ""

    else
        Html.div []
            [ viewNewJob model token
            , viewJobsTable model.jobs token
            ]


viewNewJob : Model -> String -> Html Msg
viewNewJob { jobs, newJob } token =
    let
        error =
            if List.length jobs >= 2 then
                "only two items allowed currently"

            else if newJob.schedule == "" then
                "schedule can't be empty"

            else if not (String.startsWith "http://" newJob.url) && not (String.startsWith "https://" newJob.url) then
                "url not valid"

            else
                ""
    in
    Html.form [ class "newJob", onSubmit <| CreateJob token ]
        [ Html.p [] [ Html.text "Create new job" ]
        , Html.a [ href "https://crontab.guru/", target "_blank" ] [ Html.text "better explanation of the syntax" ]
        , Html.select [ onInput ChangePreset ] viewPresets
        , Html.input [ placeholder "schedule", onInput UpdateNewJobSchedule, value newJob.schedule ] []
        , Html.input [ placeholder "url", onInput UpdateNewJobUrl, value newJob.url ] []
        , Html.button
            (if error /= "" then
                [ disabled True, title error ]

             else
                []
            )
            [ Html.text "create job" ]
        , if error /= "" then
            Html.p [ class "error" ] [ Html.text error ]

          else
            Html.text ""
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
