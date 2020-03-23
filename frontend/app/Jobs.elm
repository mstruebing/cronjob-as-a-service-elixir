module Jobs exposing (..)

import Api.Object
import Api.Object.Job
import Api.Query as Query
import Api.ScalarCodecs
import Graphql.Http exposing (queryRequest, send, withHeader)
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
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
    | JobsFetched (Result (Graphql.Http.Error (Maybe (List (Maybe Job)))) (Maybe (List (Maybe Job))))


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

        JobsFetched (Ok (Just jobs)) ->
            ( { model | jobs = makeJobs jobs }, Cmd.none )

        JobsFetched (Ok Nothing) ->
            ( model, Cmd.none )

        JobsFetched (Err _) ->
            ( model, Cmd.none )


makeJobs : List (Maybe Job) -> List Job
makeJobs maybeJobs =
    maybeJobs
        |> List.filterMap identity


fetchJobs : String -> Cmd Msg
fetchJobs token =
    jobsQuery
        |> queryRequest graphqlServerUrl
        |> withHeader "authorization" ("Bearer " ++ token)
        |> send JobsFetched


jobsQuery : SelectionSet (Maybe (List (Maybe Job))) RootQuery
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
