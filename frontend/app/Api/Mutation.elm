-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Mutation exposing (..)

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
import Json.Decode as Decode exposing (Decoder)


type alias CreateJobRequiredArguments =
    { schedule : String
    , url : String
    }


createJob : CreateJobRequiredArguments -> SelectionSet decodesTo Api.Object.Job -> SelectionSet (Maybe decodesTo) RootMutation
createJob requiredArgs object_ =
    Object.selectionForCompositeField "createJob" [ Argument.required "schedule" requiredArgs.schedule Encode.string, Argument.required "url" requiredArgs.url Encode.string ] object_ (identity >> Decode.nullable)


type alias CreateUserRequiredArguments =
    { email : String
    , password : String
    }


createUser : CreateUserRequiredArguments -> SelectionSet decodesTo Api.Object.User -> SelectionSet decodesTo RootMutation
createUser requiredArgs object_ =
    Object.selectionForCompositeField "createUser" [ Argument.required "email" requiredArgs.email Encode.string, Argument.required "password" requiredArgs.password Encode.string ] object_ identity


type alias DeleteJobRequiredArguments =
    { jobId : Api.ScalarCodecs.Id }


deleteJob : DeleteJobRequiredArguments -> SelectionSet decodesTo Api.Object.Job -> SelectionSet (Maybe decodesTo) RootMutation
deleteJob requiredArgs object_ =
    Object.selectionForCompositeField "deleteJob" [ Argument.required "jobId" requiredArgs.jobId (Api.ScalarCodecs.codecs |> Api.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias LoginRequiredArguments =
    { email : String
    , password : String
    }


login : LoginRequiredArguments -> SelectionSet decodesTo Api.Object.Session -> SelectionSet (Maybe decodesTo) RootMutation
login requiredArgs object_ =
    Object.selectionForCompositeField "login" [ Argument.required "email" requiredArgs.email Encode.string, Argument.required "password" requiredArgs.password Encode.string ] object_ (identity >> Decode.nullable)


logout : SelectionSet Bool RootMutation
logout =
    Object.selectionForField "Bool" "logout" [] Decode.bool
