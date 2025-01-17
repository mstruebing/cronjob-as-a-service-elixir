-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Object.Job exposing (..)

import Api.InputObject
import Api.Interface
import Api.Object
import Api.Scalar
import Api.ScalarCodecs
import Api.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


id : SelectionSet Api.ScalarCodecs.Id Api.Object.Job
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecId |> .decoder)


lastRun : SelectionSet Api.ScalarCodecs.DateTime Api.Object.Job
lastRun =
    Object.selectionForField "ScalarCodecs.DateTime" "lastRun" [] (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecDateTime |> .decoder)


nextRun : SelectionSet Api.ScalarCodecs.DateTime Api.Object.Job
nextRun =
    Object.selectionForField "ScalarCodecs.DateTime" "nextRun" [] (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecDateTime |> .decoder)


runs : SelectionSet Int Api.Object.Job
runs =
    Object.selectionForField "Int" "runs" [] Decode.int


schedule : SelectionSet String Api.Object.Job
schedule =
    Object.selectionForField "String" "schedule" [] Decode.string


url : SelectionSet String Api.Object.Job
url =
    Object.selectionForField "String" "url" [] Decode.string


userId : SelectionSet Api.ScalarCodecs.Id Api.Object.Job
userId =
    Object.selectionForField "ScalarCodecs.Id" "userId" [] (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapCodecs |> .codecId |> .decoder)
