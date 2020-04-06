module Shared exposing (errorToString, graphqlServerUrl)

import Graphql.Http
import Graphql.Http.GraphqlError


graphqlServerUrl : String
graphqlServerUrl =
    "http://localhost:4000/graphql"


errorToString : Graphql.Http.Error parsedData -> String
errorToString errorData =
    case errorData of
        Graphql.Http.GraphqlError _ graphqlErrors ->
            graphqlErrors
                |> List.map graphqlErrorToString
                |> String.join "\n"

        Graphql.Http.HttpError httpError ->
            "Http Error"


graphqlErrorToString : Graphql.Http.GraphqlError.GraphqlError -> String
graphqlErrorToString error =
    error.message
