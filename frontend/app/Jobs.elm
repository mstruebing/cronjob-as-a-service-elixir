module Jobs exposing (..)

import Api.Object
import Api.Object.Job
import Api.Query as Query
import Api.ScalarCodecs
import Graphql.Http exposing (queryRequest, send, withHeader)
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Html exposing (Html)
import Html.Events exposing (onClick)
import Shared exposing (graphqlServerUrl)


type alias Model =
    { jobs : List Job }


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


emptyModel : Model
emptyModel =
    { jobs = [] }


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


fetchJobs : String -> Cmd Msg
fetchJobs token =
    jobsQuery
        |> queryRequest graphqlServerUrl
        |> withHeader "authorization" ("Bearer " ++ token)
        |> send JobsFetched


jobsQuery : SelectionSet (List Job) RootQuery
jobsQuery =
    Query.jobs jobListSelection


jobListSelection : SelectionSet Job Api.Object.Job
jobListSelection =
    SelectionSet.map6 Job
        Api.Object.Job.id
        Api.Object.Job.userId
        Api.Object.Job.lastRun
        Api.Object.Job.nextRun
        Api.Object.Job.schedule
        Api.Object.Job.url


view : Model -> Html Msg
view { jobs } =
    Html.div []
        [ Html.ul [ onClick NoOp ]
            (List.map
                (\job ->
                    Html.li []
                        [ Html.text <| "schedule: " ++ job.schedule ++ " url: " ++ job.url ]
                )
                jobs
            )
        ]
